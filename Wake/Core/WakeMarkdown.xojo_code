#tag Class
Protected Class WakeMarkdown
	#tag Method, Flags = &h21
		Private Sub AddChanges(out() As String)
		  out.Add("## File changes")
		  out.Add("")
		  
		  Var count As Integer
		  For i As Integer = 0 To mEvents.LastIndex
		    Var e As WakeEvent = mEvents(i)
		    If e.Kind <> WakeEvent.Kinds.FileEdit Then Continue
		    count = count + 1
		    
		    Var added, removed As Integer
		    For Each patchLine As String In e.Patch.Split(&u0A)
		      If patchLine.BeginsWith("+") Then
		        added = added + 1
		      ElseIf patchLine.BeginsWith("-") Then
		        removed = removed + 1
		      End If
		    Next
		    
		    Var heading As String = "### " + Code(e.FilePath) + " (" + e.ToolName + ", +" + added.ToString + " −" + removed.ToString
		    If e.HasResult And e.ResultIsError Then heading = heading + ", failed"
		    If mOrigins(i) <> "" Then heading = heading + ", in " + mOrigins(i)
		    out.Add(heading + ")")
		    out.Add("")
		    If e.Patch = "" Then
		      out.Add("No diff recorded.")
		    Else
		      out.Add(Fence(e.Patch, "diff"))
		    End If
		    out.Add("")
		  Next
		  
		  If count = 0 Then
		    out.Add("None.")
		    out.Add("")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddCommands(out() As String)
		  // Every shell command in order, in one block. Commands run by a subagent follow a comment
		  // that names it, and failed commands end with a comment.
		  out.Add("## Commands")
		  out.Add("")
		  
		  Var lines() As String
		  Var origin As String
		  For i As Integer = 0 To mEvents.LastIndex
		    Var e As WakeEvent = mEvents(i)
		    If e.Kind <> WakeEvent.Kinds.ShellCommand Then Continue
		    
		    If mOrigins(i) <> origin Then
		      origin = mOrigins(i)
		      lines.Add(If(origin = "", "# back in the main session", "# in " + origin))
		    End If
		    
		    Var command As String = "$ " + e.Command.ReplaceLineEndings(&u0A)
		    If e.HasResult And e.ResultIsError Then command = command + "  # failed"
		    lines.Add(command)
		  Next
		  
		  If lines.Count = 0 Then
		    out.Add("None.")
		  Else
		    out.Add(Fence(String.FromArray(lines, &u0A), "sh"))
		  End If
		  out.Add("")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddPrompts(out() As String)
		  out.Add("## Prompts")
		  out.Add("")
		  
		  Var number As Integer
		  For Each e As WakeEvent In mSession.Events
		    If e.Kind <> WakeEvent.Kinds.UserPrompt Then Continue
		    number = number + 1
		    
		    out.Add("### " + number.ToString + ". " + TimeText(e.Timestamp))
		    out.Add("")
		    For Each promptLine As String In e.Text.ReplaceLineEndings(&u0A).Split(&u0A)
		      out.Add(If(promptLine = "", ">", "> " + promptLine))
		    Next
		    out.Add("")
		  Next
		  
		  If number = 0 Then
		    out.Add("None.")
		    out.Add("")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddSummary(out() As String)
		  Var s As WakeSession = mSession
		  
		  out.Add("# " + Title)
		  out.Add("")
		  out.Add("| | |")
		  out.Add("|---|---|")
		  If s.ProjectPath <> "" Then out.Add("| Project | " + Cell(Code(s.ProjectPath)) + " |")
		  
		  Var agent As String = s.AgentID
		  Var parser As IAgentParser = AgentRegistry.ParserFor(s.AgentID)
		  If parser <> Nil Then agent = parser.DisplayName
		  If s.AgentVersion <> "" Then agent = agent + " " + s.AgentVersion
		  out.Add("| Agent | " + Cell(agent) + " |")
		  
		  If s.GitBranch <> "" Then out.Add("| Branch | " + Cell(Code(s.GitBranch)) + " |")
		  out.Add("| Started | " + TimeText(s.StartTime) + " |")
		  out.Add("| Ended | " + TimeText(s.EndTime) + " |")
		  If s.StartTime <> Nil And s.EndTime <> Nil Then out.Add("| Duration | " + WakeFormat.Duration(s.DurationSeconds) + " |")
		  If s.ActiveDurationMs > 0 Then out.Add("| Active time | " + WakeFormat.Duration(s.ActiveDurationMs / 1000) + " |")
		  out.Add("| Prompts | " + WakeFormat.Count(s.PromptCount) + " |")
		  
		  Var toolCalls, commands, edits As Integer
		  For Each e As WakeEvent In mEvents
		    If e.IsToolCall Then toolCalls = toolCalls + 1
		    If e.Kind = WakeEvent.Kinds.ShellCommand Then commands = commands + 1
		    If e.Kind = WakeEvent.Kinds.FileEdit Then edits = edits + 1
		  Next
		  out.Add("| Tool calls | " + WakeFormat.Count(toolCalls) + " (" + WakeFormat.Count(commands) + " commands, " + _
		  WakeFormat.Count(edits) + " file changes) |")
		  If s.Subagents.Count > 0 Then out.Add("| Subagents | " + WakeFormat.Count(s.Subagents.Count) + " |")
		  If s.SourceFile <> Nil Then out.Add("| Transcript | " + Cell(Code(s.SourceFile.NativePath)) + " |")
		  out.Add("")
		  
		  If s.Report.FileError <> "" Then
		    out.Add("> **Could not read the transcript:** " + s.Report.FileError)
		    out.Add("")
		  ElseIf s.Report.IsPartial Then
		    out.Add("> **Partially parsed:** " + s.Report.Summary)
		    out.Add("")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddTokens(out() As String)
		  // Usage per model, subagents included, with Wake's cost estimate when there is a price table.
		  out.Add("## Tokens")
		  out.Add("")
		  
		  Var usage As WakeUsageGroup = mSession.TotalUsageByModel
		  If usage.ByModel.KeyCount = 0 Then
		    out.Add("No tokens recorded.")
		    out.Add("")
		    Return
		  End If
		  
		  Var models() As String
		  For Each key As Variant In usage.ByModel.Keys
		    models.Add(key.StringValue)
		  Next
		  models.Sort
		  
		  out.Add("| Model | Input | Output | Cache write | Cache read | Total | Estimated cost |")
		  out.Add("|---|--:|--:|--:|--:|--:|--:|")
		  For Each model As String In models
		    Var amount As WakeTokenUsage = WakeTokenUsage(usage.ByModel.Value(model).ObjectValue)
		    Var price As WakeModelPrice = If(mPrices Is Nil, Nil, mPrices.PriceFor(model))
		    out.Add(TokenRow(Cell(Code(model)), amount, If(price Is Nil, WakeFormat.kNoPrice, WakeFormat.USD(price.Cost(amount)))))
		  Next
		  
		  Var table As WakePriceTable = If(mPrices Is Nil, New WakePriceTable, mPrices)
		  Var estimate As WakeCostEstimate = table.Estimate(usage.ByModel)
		  out.Add(TokenRow("**Total**", usage.Total, "**" + WakeFormat.Cost(estimate) + "**"))
		  out.Add("")
		  
		  If usage.Total.CacheWrite1hTokens > 0 Then
		    out.Add(WakeFormat.Count(usage.Total.CacheWrite1hTokens) + " of the cache-write tokens were cached for an hour.")
		    out.Add("")
		  End If
		  If mSession.HasAgentReportedCost Then
		    out.Add("Cost reported by agent: " + WakeFormat.USD(mSession.AgentReportedCostUSD) + ".")
		    out.Add("")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Cell(text As String) As String
		  // Text that stays inside one table cell.
		  Return WakeFormat.OneLine(text, 0).ReplaceAll("|", "\|")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Code(text As String) As String
		  // Inline code that holds any text: the delimiter is longer than any backtick run inside.
		  Var ticks As String = "`"
		  While text.IndexOf(ticks) >= 0
		    ticks = ticks + "`"
		  Wend
		  Var padding As String = If(text.BeginsWith("`") Or text.EndsWith("`"), " ", "")
		  Return ticks + padding + text + padding + ticks
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CollectEvents(session As WakeSession, origin As String)
		  // The events of the session and its subagents in order, each subagent's right after the
		  // tool call that started it. origin names the subagent, or is empty for the main session.
		  For Each e As WakeEvent In session.Events
		    mEvents.Add(e)
		    mOrigins.Add(origin)
		    
		    If e.Subagent <> Nil Then
		      Var child As WakeSession = e.Subagent
		      Var name As String = "subagent " + If(child.SubagentType <> "", child.SubagentType, child.SubagentID)
		      If child.SubagentDescription <> "" Then name = name + " (" + WakeFormat.OneLine(child.SubagentDescription, 80) + ")"
		      CollectEvents(child, name)
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(session As WakeSession, prices As WakePriceTable = Nil)
		  // prices Nil leaves costs out: every model shows "no price set".
		  mSession = session
		  mPrices = prices
		  CollectEvents(session, "")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Fence(text As String, language As String) As String
		  // A fenced code block that holds any text: the fence is longer than any backtick run inside.
		  Var fenceMark As String = "```"
		  While text.IndexOf(fenceMark) >= 0
		    fenceMark = fenceMark + "`"
		  Wend
		  
		  Var body As String = text.ReplaceLineEndings(&u0A)
		  If body.EndsWith(&u0A) Then body = body.Left(body.Length - 1)
		  Return fenceMark + language + &u0A + body + &u0A + fenceMark
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Markdown() As String
		  // The whole report: summary, tokens, prompts, commands and file changes.
		  Var out() As String
		  AddSummary(out)
		  AddTokens(out)
		  AddPrompts(out)
		  AddCommands(out)
		  AddChanges(out)
		  out.Add("_Exported by Wake._")
		  Return String.FromArray(out, &u0A) + &u0A
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TimeText(d As DateTime) As String
		  // Local time as "2026-09-01 12:00:02". Parsed timestamps keep the zone they were written in.
		  If d Is Nil Then Return WakeFormat.kUnknown
		  Var localTime As New DateTime(d.SecondsFrom1970, TimeZone.Current)
		  Return localTime.SQLDateTime
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Title() As String
		  // The agent's title, else the first prompt, on one line.
		  If mSession.Title <> "" Then Return WakeFormat.OneLine(mSession.Title, 200)
		  If mSession.FirstPrompt <> "" Then Return WakeFormat.OneLine(mSession.FirstPrompt, 120)
		  Return "Untitled session"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TokenRow(label As String, amount As WakeTokenUsage, cost As String) As String
		  Return "| " + label + " | " + WakeFormat.Count(amount.InputTokens) + " | " + WakeFormat.Count(amount.OutputTokens) + " | " + _
		  WakeFormat.Count(amount.CacheWriteTokens) + " | " + WakeFormat.Count(amount.CacheReadTokens) + " | " + _
		  WakeFormat.Count(amount.Total) + " | " + cost + " |"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mEvents() As WakeEvent
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOrigins() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPrices As WakePriceTable
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSession As WakeSession
	#tag EndProperty


End Class
#tag EndClass
