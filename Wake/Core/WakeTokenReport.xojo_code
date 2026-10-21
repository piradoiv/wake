#tag Class
Protected Class WakeTokenReport
	#tag Method, Flags = &h21
		Private Sub AddExamples(out() As String, key As String)
		  // The most expensive calls of a pattern, exactly as the agent made them.
		  Var calls() As WakeToolCallInfo = mCatalog.ToolCalls(WakeCatalog.ToolGroupings.Pattern, key, mFromTime, kExampleCount)
		  If calls.Count = 0 Then Return
		  
		  out.Add("Most expensive calls:")
		  out.Add("")
		  For i As Integer = 0 To calls.LastIndex
		    Var c As WakeToolCallInfo = calls(i)
		    Var number As Integer = i + 1
		    Var line As String = number.ToString + ". ≈" + WakeFormat.Tokens(c.AddedTokens + c.CarriedTokens) + " tokens"
		    If c.Session <> Nil Then line = line + " in " + WakeMarkdown.Cell(c.Session.DisplayTitle)
		    If c.Timestamp <> Nil Then line = line + ", " + c.Timestamp.ToString(DateTime.FormatStyles.Medium, DateTime.FormatStyles.Short)
		    out.Add(line)
		    out.Add("")
		    out.Add(Indent(WakeMarkdown.Fence(c.Description, "")))
		    out.Add("")
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddFiles(out() As String, key As String)
		  // The files a pattern cost the most on.
		  Var files() As WakeToolUsageGroup = mCatalog.ToolUsage(WakeCatalog.ToolGroupings.File, mFromTime, _
		  WakeCatalog.ToolGroupings.Pattern, key)
		  If files.Count = 0 Then Return
		  
		  out.Add("| File | Calls | ≈ Tokens |")
		  out.Add("|---|---:|---:|")
		  For i As Integer = 0 To Min(files.LastIndex, kTopFileCount - 1)
		    Var f As WakeToolUsageGroup = files(i)
		    out.Add("| " + WakeMarkdown.Cell(WakeMarkdown.Code(f.Key)) + " | " + WakeFormat.Count(f.Calls) + " | " + _
		    WakeFormat.Tokens(f.AddedTokens + f.CarriedTokens) + " |")
		  Next
		  If files.Count > kTopFileCount Then
		    out.Add("")
		    out.Add("_And " + WakeFormat.Count(files.Count - kTopFileCount) + " more files._")
		  End If
		  out.Add("")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddLongSessions(out() As String)
		  // The sessions that paid most to re-send their earlier turns, and where that began to
		  // outweigh each turn's own work.
		  Var sessions() As WakeLongSession = mCatalog.LongSessions(mFromTime, kLongSessionCount)
		  If sessions.Count = 0 Then Return
		  
		  out.Add("## Long sessions")
		  out.Add("")
		  out.Add("Every response sends the whole context again, so a long session pays for its early turns on every " + _
		  "later one. **≈ Carried** is what a session's turns paid to re-send context from earlier turns, beyond " + _
		  "what the session started with.")
		  out.Add("")
		  out.Add("**What to change:** " + LongSessionAdvice)
		  out.Add("")
		  
		  For i As Integer = 0 To sessions.LastIndex
		    Var g As WakeLongSession = sessions(i)
		    Var number As Integer = i + 1
		    out.Add("### " + number.ToString + ". " + WakeMarkdown.Cell(g.Label) + ": ≈" + WakeFormat.Tokens(g.CarriedTokens) + " carried")
		    out.Add("")
		    
		    Var facts() As String
		    facts.Add(WakeFormat.Count(g.TurnCount) + If(g.TurnCount = 1, " turn", " turns"))
		    If g.Session <> Nil Then
		      If g.Session.StartTime <> Nil Then facts.Add(g.Session.StartTime.ToString(DateTime.FormatStyles.Medium, DateTime.FormatStyles.Short))
		      facts.Add("started with " + WakeFormat.Tokens(g.Session.StartingContextTokens) + " of context")
		    End If
		    facts.Add("peak context " + WakeFormat.Tokens(g.PeakContextTokens))
		    Var estimate As WakeCostEstimate = mPrices.Estimate(g.ByModel)
		    If estimate.PricedTokens > 0 Then facts.Add("estimated cost of carrying " + WakeFormat.Cost(estimate))
		    out.Add(String.FromArray(facts, " · "))
		    out.Add("")
		    
		    If g.TippingTurn > 0 Then
		      Var line As String = "From turn " + g.TippingTurn.ToString + " on, re-sending earlier turns cost more " + _
		      "than a turn's own work"
		      If g.TippingPrompt <> "" Then
		        out.Add(line + ". That turn began with:")
		        out.Add("")
		        out.Add(WakeMarkdown.Fence(WakeFormat.OneLine(g.TippingPrompt, kPromptLength), ""))
		      Else
		        out.Add(line + ".")
		      End If
		      out.Add("")
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddPattern(out() As String, number As Integer, g As WakeToolUsageGroup)
		  // One section per pattern: what it cost, what to change, where, and examples.
		  Var tokens As Int64 = g.AddedTokens + g.CarriedTokens
		  out.Add("## " + number.ToString + ". " + g.Label + ": ≈" + WakeFormat.Tokens(tokens) + " tokens")
		  out.Add("")
		  
		  Var facts() As String
		  facts.Add(WakeFormat.Count(g.Calls) + If(g.Calls = 1, " call", " calls") + " in " + _
		  WakeFormat.Count(g.SessionCount) + If(g.SessionCount = 1, " session", " sessions"))
		  facts.Add("≈" + WakeFormat.Tokens(g.AddedTokens) + " added")
		  facts.Add("≈" + WakeFormat.Tokens(g.CarriedTokens) + " re-read")
		  Var estimate As WakeCostEstimate = mPrices.Estimate(g.ByModel)
		  If estimate.PricedTokens > 0 Then facts.Add("estimated cost " + WakeFormat.Cost(estimate))
		  If mTotalTokens > 0 Then facts.Add(WakeFormat.Percent(tokens, mTotalTokens) + " of all tool tokens")
		  out.Add(String.FromArray(facts, " · "))
		  out.Add("")
		  
		  out.Add("**What to change:** " + WakeCallPattern.Advice(g.Key))
		  out.Add("")
		  
		  AddFiles(out, g.Key)
		  AddExamples(out, g.Key)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(catalog As WakeCatalog, prices As WakePriceTable, fromTime As DateTime, periodLabel As String)
		  // A report of where the tokens went in a period, from fromTime on (Nil for all time).
		  // prices Nil leaves costs out.
		  mCatalog = catalog
		  mPrices = If(prices Is Nil, New WakePriceTable, prices)
		  mFromTime = fromTime
		  mPeriodLabel = periodLabel
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Indent(text As String) As String
		  // Text indented to sit inside a numbered list item.
		  Return "   " + text.ReplaceAll(&u0A, &u0A + "   ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function LongSessionAdvice() As String
		  Return "Start a new session, or compact, at a task boundary. Once a task is done, its context is sent " + _
		  "again with every later response but is rarely needed. Carry over only what the next task needs, such " + _
		  "as a short note of the decisions made and what is still open."
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Markdown() As String
		  // Totals, then one section per pattern with the most tokens first, then the sessions that
		  // carried most. Re-reads have their own section. Patterns with no calls have none.
		  // Raises DatabaseException.
		  Var groups() As WakeToolUsageGroup = mCatalog.ToolUsage(WakeCatalog.ToolGroupings.Pattern, mFromTime)
		  
		  Var all As New WakeUsageGroup
		  Var calls As Integer
		  Var added, carried As Int64
		  For Each g As WakeToolUsageGroup In groups
		    calls = calls + g.Calls
		    added = added + g.AddedTokens
		    carried = carried + g.CarriedTokens
		    For Each model As Variant In g.ByModel.Keys
		      all.Add(model.StringValue, WakeTokenUsage(g.ByModel.Value(model).ObjectValue))
		    Next
		  Next
		  mTotalTokens = added + carried
		  
		  Var out() As String
		  out.Add("# Where the tokens went: " + mPeriodLabel)
		  out.Add("")
		  out.Add("| | |")
		  out.Add("|---|---|")
		  out.Add("| Tool calls | " + WakeFormat.Count(calls) + " |")
		  out.Add("| ≈ Tokens their results added | " + WakeFormat.Tokens(added) + " |")
		  out.Add("| ≈ Tokens re-read from the cache | " + WakeFormat.Tokens(carried) + " |")
		  Var estimate As WakeCostEstimate = mPrices.Estimate(all.ByModel)
		  If estimate.PricedTokens > 0 Then out.Add("| Estimated cost | " + WakeMarkdown.Cell(WakeFormat.Cost(estimate)) + " |")
		  out.Add("")
		  out.Add("Token figures per call are estimates, from how the context grew between the agent's responses. " + _
		  "Each section below is one kind of call, with what to change, the files it cost most on, and the most " + _
		  "expensive calls as the agent made them.")
		  out.Add("")
		  
		  If groups.Count = 0 Then
		    out.Add("_No tool calls in this period._")
		    out.Add("")
		  End If
		  
		  For i As Integer = 0 To groups.LastIndex
		    AddPattern(out, i + 1, groups(i))
		  Next
		  
		  AddLongSessions(out)
		  
		  out.Add("_Exported by Wake._")
		  Return String.FromArray(out, &u0A) + &u0A
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mCatalog As WakeCatalog
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFromTime As DateTime
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPeriodLabel As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPrices As WakePriceTable
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTotalTokens As Int64
	#tag EndProperty


	#tag Constant, Name = kExampleCount, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLongSessionCount, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPromptLength, Type = Double, Dynamic = False, Default = \"200", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTopFileCount, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant


End Class
#tag EndClass
