#tag Class
Protected Class WakeSession
	#tag Method, Flags = &h0
		Function AddEvent(kind As WakeEvent.Kinds, timestamp As DateTime) As WakeEvent
		  Var e As New WakeEvent
		  e.Kind = kind
		  e.Timestamp = timestamp
		  e.Sequence = Events.Count
		  Events.Add(e)
		  If kind = WakeEvent.Kinds.UserPrompt Then mLastPrompt = e
		  Return e
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddResponse(model As String, amount As WakeTokenUsage, timestamp As DateTime) As WakeResponse
		  // Counts one model response. It answers the inputs noted since the previous response, and
		  // its time runs from the last thing that happened before it.
		  AddUsage(model, amount, timestamp)
		  
		  Var response As New WakeResponse(model, amount.Clone, mLastActivity, timestamp)
		  response.InputSequences = mPendingInputs
		  Var none() As Integer
		  mPendingInputs = none
		  Responses.Add(response)
		  
		  If timestamp <> Nil Then mLastActivity = timestamp
		  Return response
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddUsage(model As String, amount As WakeTokenUsage, timestamp As DateTime = Nil)
		  // Counts one model response. Each response is also kept with its time, for usage per day.
		  Usage.Add(amount)
		  UsageEntries.Add(New WakeUsageEntry(timestamp, model, amount.Clone))
		  
		  Var perModel As WakeTokenUsage
		  If UsageByModel.HasKey(model) Then
		    perModel = WakeTokenUsage(UsageByModel.Value(model).ObjectValue)
		  Else
		    perModel = New WakeTokenUsage
		    UsageByModel.Value(model) = perModel
		  End If
		  perModel.Add(amount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AttributeGrowth(response As WakeResponse, growth As Int64)
		  // Splits the context growth before a response among the inputs it answered, by the size of
		  // their text. The response read new tokens as plain input or as cache writes, so each share
		  // is split the same way.
		  Var sizes() As Int64
		  Var totalSize As Int64
		  For Each sequence As Integer In response.InputSequences
		    Var size As Int64 = InputSize(Events(sequence))
		    sizes.Add(size)
		    totalSize = totalSize + size
		  Next
		  
		  Var fresh As Int64 = response.Usage.InputTokens + response.Usage.CacheWriteTokens
		  Var given As Int64
		  
		  For i As Integer = 0 To response.InputSequences.LastIndex
		    Var share As Int64
		    If i = response.InputSequences.LastIndex Then
		      share = growth - given
		    Else
		      share = growth * sizes(i) \ totalSize
		    End If
		    given = given + share
		    
		    Var part As New WakeTokenUsage
		    If fresh > 0 Then
		      part.InputTokens = share * response.Usage.InputTokens \ fresh
		      part.CacheWriteTokens = share - part.InputTokens
		      If response.Usage.CacheWriteTokens > 0 Then
		        part.CacheWrite1hTokens = part.CacheWriteTokens * response.Usage.CacheWrite1hTokens \ response.Usage.CacheWriteTokens
		      End If
		    Else
		      part.InputTokens = share
		    End If
		    
		    Var e As WakeEvent = Events(response.InputSequences(i))
		    e.AddedTokens = e.AddedTokens + share
		    If e.AddedUsage Is Nil Then e.AddedUsage = New WakeUsageGroup
		    e.AddedUsage.Add(response.Model, part)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ComputeContextGrowth()
		  // Every response re-sends the whole context. A turn's older context is what the context
		  // held before its first response, and every response of the turn sends it again. What it
		  // holds beyond the session's starting context (the system prompt and tools) is what the
		  // turn carried. A compaction inside a turn drops the older context, so the rest of the turn
		  // carries nothing. Subagents have contexts of their own and don't count here.
		  If Responses.Count = 0 Then Return
		  StartingContextTokens = Responses(0).ContextTokens
		  CarriedUsage = New WakeUsageGroup
		  
		  Var prompt, turnPrompt As WakeEvent
		  Var scan As Integer
		  Var older As Int64
		  Var carrying As Boolean
		  
		  For i As Integer = 0 To Responses.LastIndex
		    Var response As WakeResponse = Responses(i)
		    While response.FirstSequence >= 0 And scan <= response.FirstSequence And scan <= Events.LastIndex
		      If Events(scan).Kind = WakeEvent.Kinds.UserPrompt Then prompt = Events(scan)
		      scan = scan + 1
		    Wend
		    If prompt Is Nil Then Continue
		    response.TurnSequence = prompt.Sequence
		    
		    If prompt <> turnPrompt Then
		      turnPrompt = prompt
		      prompt.TurnContextTokens = response.ContextTokens
		      If i = 0 Or response.StartsNewContext Then
		        older = response.ContextTokens
		        prompt.TurnStartsNewContext = response.StartsNewContext
		      Else
		        Var previous As WakeResponse = Responses(i - 1)
		        older = previous.ContextTokens + previous.Usage.OutputTokens
		        If older > response.ContextTokens Then older = response.ContextTokens
		      End If
		      carrying = True
		    ElseIf response.StartsNewContext Then
		      carrying = False
		      prompt.TurnStartsNewContext = True
		    End If
		    
		    Var carried As Int64 = older - StartingContextTokens
		    If Not carrying Or carried <= 0 Then Continue
		    
		    Var resent As New WakeTokenUsage
		    resent.CacheReadTokens = carried
		    If prompt.TurnCarriedUsage Is Nil Then prompt.TurnCarriedUsage = New WakeUsageGroup
		    prompt.TurnCarriedUsage.Add(response.Model, resent)
		    prompt.TurnCarriedTokens = prompt.TurnCarriedTokens + carried
		    CarriedUsage.Add(response.Model, resent)
		    CarriedTokens = CarriedTokens + carried
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ComputeStats()
		  // Estimates what each input cost and totals each turn. Run it once the session and its
		  // subagents are parsed.
		  // Usage is recorded per response, never per tool result. A response's context (input, cache
		  // writes and cache reads) minus the previous one's context and output is roughly what the
		  // inputs in between added. Later responses read those tokens again from the cache, until
		  // the context shrinks to less than half, which means it was compacted.
		  If mStatsComputed Then Return
		  mStatsComputed = True
		  
		  For i As Integer = 1 To Responses.LastIndex
		    Var response As WakeResponse = Responses(i)
		    Var previous As WakeResponse = Responses(i - 1)
		    
		    If response.ContextTokens * 2 < previous.ContextTokens Then
		      response.StartsNewContext = True
		      Continue
		    End If
		    
		    Var growth As Int64 = response.ContextTokens - previous.ContextTokens - previous.Usage.OutputTokens
		    If growth > 0 And response.InputSequences.Count > 0 Then AttributeGrowth(response, growth)
		  Next
		  
		  For i As Integer = 1 To Responses.LastIndex
		    For Each sequence As Integer In Responses(i).InputSequences
		      Var e As WakeEvent = Events(sequence)
		      If e.AddedTokens <= 0 Then Continue
		      
		      Var reread As New WakeTokenUsage
		      reread.CacheReadTokens = e.AddedTokens
		      For j As Integer = i + 1 To Responses.LastIndex
		        If Responses(j).StartsNewContext Then Exit
		        If e.CarriedUsage Is Nil Then e.CarriedUsage = New WakeUsageGroup
		        e.CarriedUsage.Add(Responses(j).Model, reread)
		        e.CarriedTokens = e.CarriedTokens + e.AddedTokens
		      Next
		    Next
		  Next
		  
		  // Each tool call's pattern, and reads of a file already read in this context: since the
		  // session started or was last compacted, and with no change to the file in between.
		  Var read As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  For Each e As WakeEvent In Events
		    If e.Response <> Nil And e.Response.StartsNewContext And e.Response.FirstSequence = e.Sequence Then read.RemoveAll
		    If Not e.IsToolCall Then Continue
		    
		    e.Pattern = WakeCallPattern.Classify(e)
		    Var target As String = e.ResolvedTargetPath(ProjectPath)
		    If target = "" Then Continue
		    
		    If WakeCallPattern.IsRead(e.Pattern) Then
		      e.IsReread = read.HasKey(target)
		      read.Value(target) = True
		    ElseIf e.Pattern = WakeCallPattern.Patterns.Edit Then
		      If read.HasKey(target) Then read.Remove(target)
		    End If
		  Next
		  
		  // A turn runs from a prompt to the next one, and includes the subagents it started.
		  Var prompt As WakeEvent
		  For Each e As WakeEvent In Events
		    If e.Kind = WakeEvent.Kinds.UserPrompt Then
		      prompt = e
		      prompt.TurnUsage = New WakeUsageGroup
		      prompt.TurnResponses = 0
		    End If
		    If prompt Is Nil Then Continue
		    
		    If e.Response <> Nil And e.Response.FirstSequence = e.Sequence Then
		      prompt.TurnUsage.Add(e.Response.Model, e.Response.Usage)
		      prompt.TurnResponses = prompt.TurnResponses + 1
		    End If
		    
		    If e.Subagent <> Nil Then
		      Var childUsage As WakeUsageGroup = e.Subagent.TotalUsageByModel
		      For Each key As Variant In childUsage.ByModel.Keys
		        prompt.TurnUsage.Add(key.StringValue, WakeTokenUsage(childUsage.ByModel.Value(key).ObjectValue))
		      Next
		    End If
		  Next
		  
		  ComputeContextGrowth
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Usage = New WakeTokenUsage
		  UsageByModel = WakeCore.NewCaseSensitiveDictionary
		  Report = New WakeParseReport
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DurationSeconds() As Double
		  // Wall-clock time from the first to the last timestamped record, idle time included.
		  If StartTime Is Nil Or EndTime Is Nil Then Return 0
		  Return EndTime.SecondsFrom1970 - StartTime.SecondsFrom1970
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FirstPrompt() As String
		  For Each e As WakeEvent In Events
		    If e.Kind = WakeEvent.Kinds.UserPrompt Then Return e.Text
		  Next
		  
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InputSize(e As WakeEvent) As Int64
		  // The length of the text an input sent to the model, at least 1 so every input gets a share.
		  Var size As Int64 = If(e.IsToolCall Or e.Kind = WakeEvent.Kinds.ToolResult, e.ResultText.Length, e.Text.Length)
		  Return If(size < 1, 1, size)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsCommandOnly() As Boolean
		  // True when the session has no prompt and no response: only slash commands such as
		  // /clear, or nothing at all. The browse UI hides these by default.
		  If PromptCount > 0 Then Return False
		  
		  For Each e As WakeEvent In Events
		    Select Case e.Kind
		    Case WakeEvent.Kinds.AssistantText, WakeEvent.Kinds.Thinking, WakeEvent.Kinds.ToolCall, _
		      WakeEvent.Kinds.ShellCommand, WakeEvent.Kinds.FileEdit
		      Return False
		    End Select
		  Next
		  
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NoteInput(e As WakeEvent, timestamp As DateTime)
		  // Something sent to the model: a prompt, a command or a tool result. The next response
		  // answers it.
		  If e Is Nil Then Return
		  mPendingInputs.Add(e.Sequence)
		  If timestamp <> Nil Then mLastActivity = timestamp
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NoteTimestamp(timestamp As DateTime)
		  If timestamp Is Nil Then Return
		  
		  If StartTime Is Nil Or timestamp.SecondsFrom1970 < StartTime.SecondsFrom1970 Then StartTime = timestamp
		  If EndTime Is Nil Or timestamp.SecondsFrom1970 > EndTime.SecondsFrom1970 Then EndTime = timestamp
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NoteTurnDuration(milliseconds As Int64)
		  // The agent's own measure of the active time of the turn that just ended.
		  ActiveDurationMs = ActiveDurationMs + milliseconds
		  If mLastPrompt <> Nil Then mLastPrompt.TurnActiveMs = mLastPrompt.TurnActiveMs + milliseconds
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TotalUsage() As WakeTokenUsage
		  // This session's own usage plus that of all its subagents.
		  Var result As WakeTokenUsage = Usage.Clone
		  
		  For Each child As WakeSession In Subagents
		    result.Add(child.TotalUsage)
		  Next
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TotalUsageByModel() As WakeUsageGroup
		  // Usage per model, this session's own plus that of all its subagents.
		  Var result As New WakeUsageGroup
		  For Each key As Variant In UsageByModel.Keys
		    result.Add(key.StringValue, WakeTokenUsage(UsageByModel.Value(key).ObjectValue))
		  Next
		  
		  For Each child As WakeSession In Subagents
		    Var childUsage As WakeUsageGroup = child.TotalUsageByModel
		    For Each key As Variant In childUsage.ByModel.Keys
		      result.Add(key.StringValue, WakeTokenUsage(childUsage.ByModel.Value(key).ObjectValue))
		    Next
		  Next
		  
		  Return result
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		ActiveDurationMs As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		AgentID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		AgentReportedCostUSD As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		AgentVersion As String
	#tag EndProperty

	#tag Property, Flags = &h0
		CarriedTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		CarriedUsage As WakeUsageGroup
	#tag EndProperty

	#tag Property, Flags = &h0
		EndTime As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		Events() As WakeEvent
	#tag EndProperty

	#tag Property, Flags = &h0
		GitBranch As String
	#tag EndProperty

	#tag Property, Flags = &h0
		HasAgentReportedCost As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		ID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		IsSubagent As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastActivity As DateTime
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastPrompt As WakeEvent
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPendingInputs() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStatsComputed As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		ParentToolUseID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ProjectPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PromptCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Report As WakeParseReport
	#tag EndProperty

	#tag Property, Flags = &h0
		Responses() As WakeResponse
	#tag EndProperty

	#tag Property, Flags = &h0
		SourceFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		StartingContextTokens As Int64
	#tag EndProperty

	#tag Property, Flags = &h0
		StartTime As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		SubagentDescription As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SubagentID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Subagents() As WakeSession
	#tag EndProperty

	#tag Property, Flags = &h0
		SubagentType As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Title As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Usage As WakeTokenUsage
	#tag EndProperty

	#tag Property, Flags = &h0
		UsageByModel As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		UsageEntries() As WakeUsageEntry
	#tag EndProperty


End Class
#tag EndClass
