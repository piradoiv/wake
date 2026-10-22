#tag Class
Protected Class WakeFileHistory
Inherits WakeTimeline
	#tag Method, Flags = &h21
		Private Shared Function ActionLabel(action As String) As String
		  Select Case action
		  Case WakeEvent.kChangeCreate
		    Return "created"
		  Case WakeEvent.kChangeWrite
		    Return "rewritten"
		  End Select
		  Return "edited"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddEntry(out() As String, entry As WakeHistoryEntry)
		  // A change shows its diff, open. A read is one line, shown only when the page shows reads.
		  Var e As WakeEvent = entry.ToolEvent
		  Var anchor As String = NewAnchor(entry.SessionUID, e.Sequence)
		  Var badges As String = If(entry.InSubagent, "<span class=""badge"">subagent</span>", "")
		  
		  If entry.IsRead Then
		    Var how As String = WakeCallPattern.Label(WakeCallPattern.Key(e.Pattern))
		    If e.Kind = WakeEvent.Kinds.ShellCommand Then how = how + " · $ " + WakeFormat.OneLine(e.Command, 160)
		    If e.IsReread Then badges = badges + "<span class=""badge"">re-read</span>"
		    If e.LedNowhere Then badges = badges + "<span class=""badge"">led nowhere</span>"
		    out.Add("<div class=""ev read"" id=""" + anchor + """><div class=""line"">" + ToolStats(e) + TimeHTML(e.Timestamp) + _
		    "<span class=""tool"">" + EscapeHTML(e.ToolName) + "</span> " + EscapeHTML(how) + badges + "</div></div>")
		    Return
		  End If
		  
		  Var counts As Pair = e.ChangedLineCounts
		  Var summary As String = ToolStats(e) + TimeHTML(e.Timestamp) + "<span class=""tool"">" + EscapeHTML(e.ToolName) + "</span> " + _
		  ActionLabel(e.ChangeAction) + " <span class=""add"">+" + counts.Left.StringValue + "</span> <span class=""del"">−" + _
		  counts.Right.StringValue + "</span>" + badges
		  Var body As String = If(e.Patch = "", "<p class=""muted"">No diff recorded.</p>", Block(e.Patch, True, ""))
		  
		  out.Add("<div class=""ev"" id=""" + anchor + """><details class=""tool-call"" open><summary>" + summary + "</summary>" + _
		  "<div class=""body"">" + body + "</div></details></div>")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddHeader(out() As String)
		  // The file, its totals, and what the history can't know.
		  out.Add("<div class=""file-head""><div class=""name"">" + EscapeHTML(FileName) + "</div>" + _
		  "<div class=""path muted"">" + EscapeHTML(mTargetPath) + "</div>" + _
		  "<div class=""facts"">" + EscapeHTML(FactsText) + "</div></div>")
		  out.Add("<div class=""note"">" + EscapeHTML(LimitsText) + "</div>")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function AddMatch(turn As WakeHistoryTurn, e As WakeEvent, folder As String, sessionUID As String, inSubagent As Boolean) As Boolean
		  // Adds e to the turn when it changed or read the file, by the index's rules: edit and write
		  // calls that didn't fail, and reads, matched by their path resolved against the session's
		  // folder. True when e changed the file.
		  Var isChange As Boolean = e.Kind = WakeEvent.Kinds.FileEdit And e.ChangeAction <> "" And Not e.ResultIsError
		  If Not isChange And Not WakeCallPattern.IsRead(e.Pattern) Then Return False
		  If e.ResolvedTargetPath(folder).Compare(mTargetPath, ComparisonOptions.CaseSensitive) <> 0 Then Return False
		  
		  Var entry As New WakeHistoryEntry
		  entry.ToolEvent = e
		  entry.SessionUID = sessionUID
		  entry.InSubagent = inSubagent
		  entry.IsRead = Not isChange
		  turn.Entries.Add(entry)
		  Return isChange
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddSessionHead(out() As String, first As Integer)
		  // A session's title and start, with its changes. Pressing it opens the session's timeline at
		  // the first change.
		  Var info As WakeSessionInfo = mTurns(first).Info
		  Var changes As Integer
		  Var target As WakeHistoryEntry
		  For i As Integer = first To mTurns.LastIndex
		    If Not (mTurns(i).Info Is info) Then Exit
		    changes = changes + mTurns(i).ChangeCount
		    If target Is Nil Or (target.IsRead And mTurns(i).ChangeCount > 0) Then target = mTurns(i).FirstChange
		  Next
		  
		  Var facts() As String
		  If info.StartTime <> Nil Then facts.Add(LocalTime(info.StartTime).ToString(DateTime.FormatStyles.Medium, DateTime.FormatStyles.Short))
		  facts.Add(If(changes = 1, "1 change", WakeFormat.Count(changes) + " changes"))
		  
		  Var opener As String
		  If target <> Nil Then
		    opener = " onclick=""wakeOpen('" + NewLink(info, target) + "')"" title=""Open the session's timeline at its first change"""
		  End If
		  
		  out.Add("<div class=""session""><div class=""session-head""" + opener + "><span class=""title"">" + _
		  EscapeHTML(info.DisplayTitle) + "</span><span class=""muted"">" + EscapeHTML(String.FromArray(facts, " · ")) + "</span></div>")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddSession(info As WakeSessionInfo, session As WakeSession)
		  // Adds the turns of a parsed session that changed or read the file, placed among the other
		  // sessions by start time, oldest first. info is the session as the index has it.
		  mPage = ""
		  Var turns() As WakeHistoryTurn
		  Var folder As String = session.ProjectPath
		  
		  If session.Report.FileError <> "" Then
		    Var failed As New WakeHistoryTurn
		    failed.Info = info
		    failed.Note = "Wake couldn't read this session: " + session.Report.Summary
		    turns.Add(failed)
		  Else
		    // Each prompt starts a turn. Events before the first prompt form a turn without one.
		    Var prompt As WakeEvent
		    Var events() As WakeEvent
		    Var started As New Dictionary
		    For Each e As WakeEvent In session.Events
		      If e.Kind = WakeEvent.Kinds.UserPrompt Then
		        AddTurn(turns, info, folder, UIDOf(session), False, prompt, events)
		        prompt = e
		        events.RemoveAll
		        Continue
		      End If
		      events.Add(e)
		      If e.Subagent <> Nil Then started.Value(e.Subagent) = True
		    Next
		    AddTurn(turns, info, folder, UIDOf(session), False, prompt, events)
		    
		    // A subagent that no tool call started has no prompt, as in the index.
		    For Each subagent As WakeSession In session.Subagents
		      If Not started.HasKey(subagent) Then AddTurn(turns, info, folder, UIDOf(subagent), True, Nil, subagent.Events)
		    Next
		  End If
		  
		  Var position As Integer = mTurns.Count
		  For i As Integer = 0 To mTurns.LastIndex
		    If StartsBefore(info, mTurns(i).Info) Then
		      position = i
		      Exit
		    End If
		  Next
		  
		  For Each turn As WakeHistoryTurn In turns
		    mTurns.AddAt(position, turn)
		    position = position + 1
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddTurn(turns() As WakeHistoryTurn, info As WakeSessionInfo, folder As String, sessionUID As String, inSubagent As Boolean, prompt As WakeEvent, events() As WakeEvent)
		  // Keeps a turn that changed or read the file, with the agent's first answer after its last
		  // change as the why. A subagent's changes count at the tool call that started it.
		  Var turn As New WakeHistoryTurn
		  turn.Info = info
		  turn.Prompt = prompt
		  Var lastChange As Integer = -1
		  
		  For i As Integer = 0 To events.LastIndex
		    Var e As WakeEvent = events(i)
		    If AddMatch(turn, e, folder, sessionUID, inSubagent) Then lastChange = i
		    If e.Subagent <> Nil Then
		      For Each child As WakeEvent In e.Subagent.Events
		        If AddMatch(turn, child, folder, UIDOf(e.Subagent), True) Then lastChange = i
		      Next
		    End If
		  Next
		  If turn.Entries.Count = 0 Then Return
		  
		  If lastChange >= 0 Then
		    For i As Integer = lastChange + 1 To events.LastIndex
		      If events(i).Kind = WakeEvent.Kinds.AssistantText And events(i).Text.Trim <> "" Then
		        turn.Why = events(i).Text
		        Exit
		      End If
		    Next
		  End If
		  
		  turns.Add(turn)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddTurnHTML(out() As String, turn As WakeHistoryTurn)
		  // The prompt, the changes and reads it led to, and the agent's answer after them. A turn
		  // with only reads is hidden with the reads.
		  If turn.Note <> "" Then
		    out.Add("<div class=""warning"">" + EscapeHTML(turn.Note) + "</div>")
		    Return
		  End If
		  
		  out.Add("<section class=""turn" + If(turn.ChangeCount = 0, " reads-only", "") + """>")
		  
		  Var opener As String
		  Var target As WakeHistoryEntry = turn.FirstChange
		  If target <> Nil Then
		    opener = " link"" onclick=""wakeOpen('" + NewLink(turn.Info, target) + "')"" title=""Open the session's timeline here"
		  End If
		  
		  If turn.Prompt Is Nil Then
		    out.Add("<section class=""card user""><div class=""head" + opener + """><span class=""who"">Before the first prompt</span></div></section>")
		  Else
		    out.Add("<section class=""card user""><div class=""head" + opener + """><span class=""who"">You</span><span>" + _
		    TimeHTML(turn.Prompt.Timestamp) + "</span></div>" + Block(turn.Prompt.Text, False, "prose", kPromptLines, kPromptCharacters) + "</section>")
		  End If
		  
		  For Each entry As WakeHistoryEntry In turn.Entries
		    AddEntry(out, entry)
		  Next
		  
		  If turn.Why <> "" Then
		    out.Add("<section class=""card why""><div class=""head"" title=""The agent's first answer after these changes""><span class=""who"">Why</span></div>" + _
		    Block(turn.Why, False, "prose", kWhyLines, kWhyCharacters) + "</section>")
		  End If
		  
		  out.Add("</section>")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChangeCount() As Integer
		  Var total As Integer
		  For Each turn As WakeHistoryTurn In mTurns
		    total = total + turn.ChangeCount
		  Next
		  Return total
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChangeFor(linkID As String) As WakeFileChangeInfo
		  // The session and event a header of the page opens, from the id it passes to wakeOpen, or
		  // Nil when there is no such header.
		  Call HTML
		  If Not mLinks.HasKey(linkID) Then Return Nil
		  Return WakeFileChangeInfo(mLinks.Value(linkID).ObjectValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(targetPath As String, displayPath As String)
		  // targetPath is the file's resolved path, as the index stores it, and displayPath the path
		  // shown, relative to its project when inside it.
		  Super.Constructor(Nil)
		  mTargetPath = targetPath
		  mDisplayPath = If(displayPath = "", targetPath, displayPath)
		  mLinks = WakeCore.NewCaseSensitiveDictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FactsText() As String
		  Var changes As Integer = ChangeCount
		  Var sessions As Integer = SessionCount
		  Var added, removed As Integer
		  For Each turn As WakeHistoryTurn In mTurns
		    For Each entry As WakeHistoryEntry In turn.Entries
		      If entry.IsRead Then Continue
		      Var counts As Pair = entry.ToolEvent.ChangedLineCounts
		      added = added + counts.Left.IntegerValue
		      removed = removed + counts.Right.IntegerValue
		    Next
		  Next
		  
		  Var parts() As String
		  parts.Add(If(changes = 1, "1 change", WakeFormat.Count(changes) + " changes") + " in " + _
		  If(sessions = 1, "1 session", WakeFormat.Count(sessions) + " sessions"))
		  parts.Add("+" + WakeFormat.Count(added) + " −" + WakeFormat.Count(removed))
		  Var reads As Integer = ReadCount
		  parts.Add(If(reads = 1, "1 read", WakeFormat.Count(reads) + " reads"))
		  Return String.FromArray(parts, " · ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FileName() As String
		  // The file's name, without its folders.
		  Var separator As String = If(mDisplayPath.IndexOf("/") < 0 And mDisplayPath.IndexOf("\") >= 0, "\", "/")
		  Return mDisplayPath.NthField(separator, mDisplayPath.CountFields(separator))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTML() As String
		  // The same kind of page as the timeline: self-contained, no remote resources, transcript text
		  // escaped, costs filled in by wakeSetCosts after load. Reads are hidden until wakeShowReads.
		  If mPage <> "" Then Return mPage
		  mLinks = WakeCore.NewCaseSensitiveDictionary

		  Var out() As String
		  out.Add("<!DOCTYPE html><html><head><meta charset=""utf-8"">")
		  out.Add("<meta http-equiv=""Content-Security-Policy"" content=""default-src 'none'; style-src 'unsafe-inline'; " + _
		  "script-src 'unsafe-inline'; img-src data:"">")
		  out.Add("<style>" + StyleSheet + &u0A + HistoryStyleSheet + "</style>")
		  out.Add("<script>" + ScriptSource + &u0A + HistoryScript + "</script>")
		  out.Add("</head><body class=""hide-reads"">")
		  AddHeader(out)
		  
		  Var current As WakeSessionInfo
		  For i As Integer = 0 To mTurns.LastIndex
		    If Not (mTurns(i).Info Is current) Then
		      If current <> Nil Then out.Add("</div>")
		      current = mTurns(i).Info
		      AddSessionHead(out, i)
		    End If
		    AddTurnHTML(out, mTurns(i))
		  Next
		  If current <> Nil Then out.Add("</div>")
		  
		  If mTurns.Count = 0 Then out.Add("<p class=""muted"">No changes to this file were found in the transcripts.</p>")
		  out.Add("</body></html>")
		  
		  mPage = String.FromArray(out, &u0A)
		  Return mPage
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function HistoryScript() As String
		  Var js() As String
		  js.Add("function wakeShowReads(on) {")
		  js.Add("  document.body.classList.toggle('hide-reads', !on);")
		  js.Add("}")
		  js.Add("function wakeOpen(id) {")
		  js.Add("  if (typeof executeInXojoSync === 'function') executeInXojoSync('open', id);")
		  js.Add("}")
		  Return String.FromArray(js, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function HistoryStyleSheet() As String
		  Var css() As String
		  css.Add(".file-head { margin: 0 0 8px; }")
		  css.Add(".file-head .name { font-size: 18px; font-weight: 600; }")
		  css.Add(".file-head .path { font: 12px ui-monospace, Menlo, monospace; overflow-wrap: anywhere; }")
		  css.Add(".note { background: var(--card); color: var(--muted); border-radius: 6px; padding: 8px 12px; margin: 8px 0 16px; }")
		  css.Add(".session { margin: 24px 0 0; }")
		  css.Add(".session-head { display: flex; justify-content: space-between; gap: 12px; padding: 4px 8px;")
		  css.Add("  border-bottom: 2px solid var(--line); border-radius: 5px 5px 0 0; }")
		  css.Add(".session-head .title { font-weight: 600; font-size: 14px; }")
		  css.Add(".session-head[onclick], .head.link { cursor: pointer; }")
		  css.Add(".session-head[onclick]:hover, .head.link:hover { background: var(--card); }")
		  css.Add(".head.link { border-radius: 4px; }")
		  css.Add(".turn { padding: 4px 0 8px; }")
		  css.Add(".read .line { color: var(--muted); }")
		  css.Add(".hide-reads .read, .hide-reads .turn.reads-only { display: none; }")
		  Return String.FromArray(css, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LimitsText() As String
		  Return "Built from agent transcripts only: it doesn't show your own edits, and a change here may no longer be in the file."
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Load(targetPath As String, displayPath As String, changes() As WakeFileChangeInfo) As WakeFileHistory
		  // Re-parses only the sessions that changed the file, each once and read-only. changes are
		  // the file's changes as WakeCatalog.FileChanges returns them.
		  Var history As New WakeFileHistory(targetPath, displayPath)
		  Var loaded As New Dictionary
		  For Each c As WakeFileChangeInfo In changes
		    If c.Session Is Nil Or loaded.HasKey(c.Session.ID) Then Continue
		    loaded.Value(c.Session.ID) = True
		    history.AddSession(c.Session, WakeCore.LoadSession(c.Session.AgentID, c.Session.FilePath))
		  Next
		  Return history
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Markdown() As String
		  // The prompts and the diffs they led to, oldest first. Reads and answers are left out, as in
		  // a session's export.
		  Var out() As String
		  out.Add("# History of " + WakeMarkdown.Code(mDisplayPath))
		  out.Add("")
		  out.Add(FactsText + ". File: " + WakeMarkdown.Code(mTargetPath))
		  out.Add("")
		  out.Add(LimitsText)
		  out.Add("")
		  
		  Var current As WakeSessionInfo
		  For Each turn As WakeHistoryTurn In mTurns
		    If Not (turn.Info Is current) Then
		      current = turn.Info
		      out.Add("## " + WakeFormat.OneLine(current.DisplayTitle, 200) + " (" + TimeText(current.StartTime) + ")")
		      out.Add("")
		    End If
		    
		    If turn.Note <> "" Then
		      out.Add(turn.Note)
		      out.Add("")
		      Continue
		    End If
		    If turn.ChangeCount = 0 Then Continue
		    
		    If turn.Prompt Is Nil Then
		      out.Add("### Before the first prompt")
		      out.Add("")
		    Else
		      out.Add("### Prompt, " + TimeText(turn.Prompt.Timestamp))
		      out.Add("")
		      For Each promptLine As String In turn.Prompt.Text.ReplaceLineEndings(&u0A).Split(&u0A)
		        out.Add(If(promptLine = "", ">", "> " + promptLine))
		      Next
		      out.Add("")
		    End If
		    
		    For Each entry As WakeHistoryEntry In turn.Entries
		      If entry.IsRead Then Continue
		      Var e As WakeEvent = entry.ToolEvent
		      Var counts As Pair = e.ChangedLineCounts
		      out.Add(e.ToolName + ", " + ActionLabel(e.ChangeAction) + ", +" + counts.Left.StringValue + " −" + counts.Right.StringValue + _
		      If(entry.InSubagent, ", by a subagent", "") + ", " + TimeText(e.Timestamp))
		      out.Add("")
		      out.Add(If(e.Patch = "", "No diff recorded.", WakeMarkdown.Fence(e.Patch, "diff")))
		      out.Add("")
		    Next
		  Next
		  
		  out.Add("_Exported by Wake._")
		  Return String.FromArray(out, &u0A) + &u0A
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function NewLink(info As WakeSessionInfo, entry As WakeHistoryEntry) As String
		  // An id for wakeOpen that ChangeFor turns back into the session and event to show.
		  Var c As New WakeFileChangeInfo
		  c.Session = info
		  c.EventSessionUID = entry.SessionUID
		  c.Sequence = entry.ToolEvent.Sequence
		  c.InSubagent = entry.InSubagent
		  c.TargetPath = mTargetPath
		  c.Path = mDisplayPath
		  
		  Var number As Integer = mLinks.KeyCount + 1
		  Var id As String = "g" + number.ToString
		  mLinks.Value(id) = c
		  Return id
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReadCount() As Integer
		  Var total As Integer
		  For Each turn As WakeHistoryTurn In mTurns
		    total = total + turn.Entries.Count - turn.ChangeCount
		  Next
		  Return total
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SessionCount() As Integer
		  // The sessions that changed the file.
		  Var counted() As WakeSessionInfo
		  For Each turn As WakeHistoryTurn In mTurns
		    If turn.ChangeCount > 0 And counted.IndexOf(turn.Info) < 0 Then counted.Add(turn.Info)
		  Next
		  Return counted.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function StartsBefore(a As WakeSessionInfo, b As WakeSessionInfo) As Boolean
		  // Whether session a started before session b. A session with no start time goes last.
		  If a.StartTime Is Nil Then Return False
		  If b.StartTime Is Nil Then Return True
		  Return a.StartTime.SecondsFrom1970 < b.StartTime.SecondsFrom1970
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TargetPath() As String
		  Return mTargetPath
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TimeText(d As DateTime) As String
		  // Local time as "2026-09-01 12:00:02", as in a session's export.
		  If d Is Nil Then Return WakeFormat.kUnknown
		  Return LocalTime(d).SQLDateTime
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Turns() As WakeHistoryTurn()
		  // The turns that changed or read the file, grouped by session, oldest session first.
		  Return mTurns
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function UIDOf(session As WakeSession) As String
		  // The uid the index stores for a session or subagent, as the timeline's anchors use it.
		  Return If(session.IsSubagent And session.SubagentID <> "", session.SubagentID, session.ID)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mDisplayPath As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLinks As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPage As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTargetPath As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTurns() As WakeHistoryTurn
	#tag EndProperty


	#tag Constant, Name = kPromptCharacters, Type = Double, Dynamic = False, Default = \"1200", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPromptLines, Type = Double, Dynamic = False, Default = \"12", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWhyCharacters, Type = Double, Dynamic = False, Default = \"500", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWhyLines, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant


End Class
#tag EndClass
