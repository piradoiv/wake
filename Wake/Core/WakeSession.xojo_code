#tag Class
Protected Class WakeSession
	#tag Method, Flags = &h0
		Sub AddUsage(model As String, amount As WakeTokenUsage)
		  Usage.Add(amount)

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

	#tag Method, Flags = &h0
		Function AddEvent(kind As WakeEvent.Kinds, timestamp As DateTime) As WakeEvent
		  Var e As New WakeEvent
		  e.Kind = kind
		  e.Timestamp = timestamp
		  e.Sequence = Events.Count
		  Events.Add(e)
		  Return e
		End Function
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
		Sub NoteTimestamp(timestamp As DateTime)
		  If timestamp Is Nil Then Return

		  If StartTime Is Nil Or timestamp.SecondsFrom1970 < StartTime.SecondsFrom1970 Then StartTime = timestamp
		  If EndTime Is Nil Or timestamp.SecondsFrom1970 > EndTime.SecondsFrom1970 Then EndTime = timestamp
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
		SourceFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		StartTime As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		Subagents() As WakeSession
	#tag EndProperty

	#tag Property, Flags = &h0
		SubagentDescription As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SubagentID As String
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


End Class
#tag EndClass
