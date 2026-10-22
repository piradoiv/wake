#tag Class
Protected Class WakeFileHistoryTests
Inherits TestGroup
	#tag Method, Flags = &h21
		Private Function Actions(turn As WakeHistoryTurn) As String
		  // The turn's entries as "read" or their change action, in order.
		  Var names() As String
		  For Each entry As WakeHistoryEntry In turn.Entries
		    names.Add(If(entry.IsRead, "read", entry.ToolEvent.ChangeAction))
		  Next
		  Return String.FromArray(names, " ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BlameTest()
		  // format.py as both sessions left it, with a line added by hand: the first line is the
		  // create's, the return line the rewrite's (the create's was replaced), and the rounding
		  // line, removed in session 11, credits nothing.
		  Var history As WakeFileHistory = BothSessions
		  history.UseFileText("def fmt(x):" + &u0A + "    return f""{x:.2f}""" + &u0A + "# mine <b>" + &u0A + "    x = round(x, 2)" + &u0A)
		  Var owners() As WakeHistoryEntry = history.Blame
		  Var count As Integer = owners.Count
		  Assert.AreEqual(4, count)
		  If count <> 4 Then Return
		  
		  Assert.IsNotNil(owners(0))
		  Assert.IsNotNil(owners(1))
		  If owners(0) <> Nil Then Assert.AreEqual("create", owners(0).ToolEvent.ChangeAction)
		  If owners(1) <> Nil Then Assert.AreEqual("write", owners(1).ToolEvent.ChangeAction)
		  Assert.IsNil(owners(2), "typed by hand")
		  Assert.IsNil(owners(3), "removed by a later edit")
		  
		  // Marks jump to the change's anchor in the history, and the file's text is escaped.
		  Var html As String = history.HTML
		  Assert.IsTrue(html.IndexOf("id=""blame-view""") >= 0)
		  Assert.IsTrue(html.IndexOf("wakeJump('" + history.Anchor(owners(1).SessionUID, owners(1).ToolEvent.Sequence) + "')") >= 0)
		  Assert.IsTrue(html.IndexOf("not from an agent edit, or changed since") >= 0)
		  Assert.IsTrue(html.IndexOf("<td class=""src"">    return f&quot;{x:.2f}&quot;</td>") >= 0)
		  Assert.IsTrue(html.IndexOf("# mine &lt;b&gt;") >= 0)
		  Assert.IsTrue(html.IndexOf("2 of 4 lines match an agent change, from 2 of 3 changes") >= 0)
		  Assert.IsTrue(html.IndexOf("It's a guess") >= 0 Or html.IndexOf("It&#39;s a guess") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BlameFileTest()
		  // The file is read from disk, read-only; a missing or binary file gets a note, not a blame.
		  Var scratch As FolderItem = TestSupport.NewScratchFolder
		  Var f As FolderItem = scratch.Child("format.py")
		  Var output As TextOutputStream = TextOutputStream.Create(f)
		  output.Write("def fmt(x):" + &u0A)
		  output.Close
		  
		  Var history As New WakeFileHistory(f.NativePath, "")
		  history.ReadFileOnDisk
		  Var count As Integer = history.Blame.Count
		  Assert.AreEqual(1, count)
		  
		  Var stream As BinaryStream = BinaryStream.Create(f, True)
		  stream.Write("a" + String.ChrByte(0) + "b")
		  stream.Close
		  history.ReadFileOnDisk
		  count = history.Blame.Count
		  Assert.AreEqual(0, count)
		  Assert.IsTrue(history.HTML.IndexOf("isn&#39;t UTF-8 text") >= 0)
		  
		  Var missing As New WakeFileHistory(scratch.NativePath + "/gone.py", "")
		  missing.ReadFileOnDisk
		  Assert.IsTrue(missing.HTML.IndexOf("There is no file at this path now.") >= 0)
		  
		  TestSupport.RemoveScratchFolder(scratch)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BothSessions() As WakeFileHistory
		  // format.py's history from session 11 (2 September) and session 10 (30 August), added in
		  // that order.
		  Var history As New WakeFileHistory(kFormatPath, "src/app/format.py")
		  Var later As WakeSession = TestSupport.ParseClaudeFixture(11, "-Users-dev-shop", "history")
		  Var earlier As WakeSession = TestSupport.ParseClaudeFixture(10, "-Users-dev-shop", "changes")
		  history.AddSession(InfoFor(later), later)
		  history.AddSession(InfoFor(earlier), earlier)
		  Return history
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChangesAndWhyTest()
		  // A file created in one turn and rewritten in the next: each turn has its prompt, its change
		  // and the agent's first answer after it.
		  Var history As WakeFileHistory = SessionTen(kFormatPath)
		  Var turns() As WakeHistoryTurn = history.Turns
		  Var count As Integer = turns.Count
		  Assert.AreEqual(2, count)
		  If count <> 2 Then Return
		  
		  Assert.AreEqual("Add a price formatter.", turns(0).Prompt.Text)
		  Assert.AreEqual("create", Actions(turns(0)))
		  Assert.AreEqual("Prices now go through fmt in src/app/format.py, and the readme says so.", turns(0).Why)
		  
		  Assert.AreEqual("Round prices and update my notes.", turns(1).Prompt.Text)
		  Assert.AreEqual("write", Actions(turns(1)))
		  Assert.AreEqual("Prices are rounded in fmt, and your notes have a line about it.", turns(1).Why)
		  
		  Assert.AreEqual(2, history.ChangeCount)
		  Assert.AreEqual(1, history.SessionCount)
		  Assert.AreEqual(0, history.ReadCount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FailedEditsTest()
		  // The read and the edit count; the failed edit and the sed -i of the next turn don't, so that
		  // turn is left out.
		  Var history As WakeFileHistory = SessionTen("/Users/dev/shop/src/app/price.py")
		  Var turns() As WakeHistoryTurn = history.Turns
		  Var count As Integer = turns.Count
		  Assert.AreEqual(1, count)
		  If count = 1 Then Assert.AreEqual("read edit", Actions(turns(0)))
		  Assert.AreEqual(1, history.ChangeCount)
		  Assert.AreEqual(1, history.ReadCount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InfoFor(session As WakeSession) As WakeSessionInfo
		  // What the index would hold for a parsed fixture session, as far as the history uses it.
		  Var info As New WakeSessionInfo
		  info.UID = session.ID
		  info.Title = session.Title
		  info.StartTime = session.StartTime
		  info.ProjectPath = session.ProjectPath
		  info.AgentID = "claude-code"
		  Return info
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LinksTest()
		  // The session header opens the timeline at the session's first change, the turn header at
		  // the turn's first change, and each change has an anchor for later jumps.
		  Var history As WakeFileHistory = BothSessions
		  Var html As String = history.HTML
		  Assert.IsTrue(html.IndexOf("wakeOpen('g1')") >= 0)
		  
		  Var turns() As WakeHistoryTurn = history.Turns
		  Var first As WakeHistoryEntry = turns(0).FirstChange
		  Var link As WakeFileChangeInfo = history.ChangeFor("g1")
		  Assert.IsNotNil(link)
		  If link <> Nil Then
		    Assert.AreEqual("Add a price formatter", link.Session.Title)
		    Assert.AreEqual(first.ToolEvent.Sequence, link.Sequence)
		    Assert.AreEqual(TestSupport.ClaudeFixtureID(10), link.EventSessionUID)
		  End If
		  Assert.IsNil(history.ChangeFor("g999"))
		  
		  Var anchor As String = history.Anchor(TestSupport.ClaudeFixtureID(10), first.ToolEvent.Sequence)
		  Assert.AreNotEqual("", anchor)
		  Assert.IsTrue(html.IndexOf("id=""" + anchor + """") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadTest()
		  // From the index: only the sessions that changed the file are parsed.
		  Var scratch As FolderItem = TestSupport.NewScratchFolder
		  TestSupport.CopyFolder(TestSupport.FixturesFolder("claude-code").Child("changes"), scratch.Child("changes"))
		  
		  Var writer As New WakeIndex(scratch.Child("index.sqlite"))
		  writer.Open
		  Var indexer As New WakeIndexer(writer)
		  indexer.AddRoot(New WakeIndexRoot("claude-code", scratch.Child("changes")))
		  Call indexer.Run
		  writer.Close
		  
		  Var index As New WakeIndex(scratch.Child("index.sqlite"))
		  index.Open
		  Var catalog As New WakeCatalog(index)
		  Var changes() As WakeFileChangeInfo = catalog.FileChanges(0, kFormatPath)
		  index.Close
		  
		  Var history As WakeFileHistory = WakeFileHistory.Load(kFormatPath, "src/app/format.py", changes)
		  Assert.AreEqual(2, history.ChangeCount)
		  Assert.AreEqual(1, history.SessionCount)
		  Var count As Integer = history.Turns.Count
		  Assert.AreEqual(2, count)
		  
		  TestSupport.RemoveScratchFolder(scratch)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MarkdownTest()
		  // Prompts and diffs only: the reads-only turn and the answers are left out.
		  Var history As WakeFileHistory = BothSessions
		  Var markdown As String = history.Markdown
		  Assert.IsTrue(markdown.BeginsWith("# History of `src/app/format.py`"))
		  Assert.IsTrue(markdown.IndexOf("> Add a price formatter.") >= 0)
		  Assert.IsTrue(markdown.IndexOf("> Show <b>cents</b> & keep fmt tidy.") >= 0)
		  Assert.IsTrue(markdown.IndexOf("```diff") >= 0)
		  Assert.IsTrue(markdown.IndexOf("-    x = round(x, 2)") >= 0)
		  Assert.IsTrue(markdown.IndexOf("your own edits") >= 0)
		  Assert.AreEqual(-1, markdown.IndexOf("What does fmt return?"))
		  Assert.AreEqual(-1, markdown.IndexOf("Line two of the answer."))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub OrderAndReadsTest()
		  // Sessions are oldest first, whatever order they were added in. A shell read by a relative
		  // path counts, and a turn that only read the file is kept as a reads-only turn.
		  Var history As WakeFileHistory = BothSessions
		  Var turns() As WakeHistoryTurn = history.Turns
		  Var count As Integer = turns.Count
		  Assert.AreEqual(4, count)
		  If count <> 4 Then Return
		  
		  Assert.AreEqual("Add a price formatter.", turns(0).Prompt.Text)
		  Assert.AreEqual("Round prices and update my notes.", turns(1).Prompt.Text)
		  Assert.AreEqual("read edit", Actions(turns(2)))
		  Assert.AreEqual("read", Actions(turns(3)))
		  Assert.AreEqual(0, turns(3).ChangeCount)
		  Assert.AreEqual("", turns(3).Why, "no why without a change")
		  
		  Assert.AreEqual(3, history.ChangeCount)
		  Assert.AreEqual(2, history.SessionCount)
		  Assert.AreEqual(2, history.ReadCount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PageTest()
		  // The page follows the timeline's rules: a closed content policy, escaped text, and diffs
		  // drawn as the timeline draws them. Reads start hidden, and the why is cut short.
		  Var history As WakeFileHistory = BothSessions
		  Var html As String = history.HTML
		  Assert.IsTrue(html.IndexOf("default-src 'none'") >= 0)
		  Assert.AreEqual(-1, html.IndexOf("<b>cents"))
		  Assert.IsTrue(html.IndexOf("Show &lt;b&gt;cents&lt;/b&gt; &amp; keep fmt tidy.") >= 0)
		  Assert.IsTrue(html.IndexOf("<div class=""dl del"">-    x = round(x, 2)</div>") >= 0)
		  Assert.IsTrue(html.IndexOf("<body class=""hide-reads"">") >= 0)
		  Assert.IsTrue(html.IndexOf("class=""turn reads-only""") >= 0)
		  Assert.IsTrue(html.IndexOf("class=""ev read""") >= 0)
		  Assert.IsTrue(html.IndexOf("Show all 6 lines") >= 0, "the why shows a few lines")
		  Assert.IsTrue(html.IndexOf("your own edits") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SessionTen(target As String) As WakeFileHistory
		  Var session As WakeSession = TestSupport.ParseClaudeFixture(10, "-Users-dev-shop", "changes")
		  Var history As New WakeFileHistory(target, "")
		  history.AddSession(InfoFor(session), session)
		  Return history
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SubagentTest()
		  // A subagent's edit sits under the prompt that started the subagent, marked as such, with the
		  // main session's answer after the subagent as the why.
		  Var history As WakeFileHistory = SessionTen("/Users/dev/shop/README.md")
		  Var turns() As WakeHistoryTurn = history.Turns
		  Var count As Integer = turns.Count
		  Assert.AreEqual(1, count)
		  If count <> 1 Then Return
		  
		  Assert.AreEqual("Add a price formatter.", turns(0).Prompt.Text)
		  Assert.AreEqual("edit", Actions(turns(0)))
		  Assert.IsTrue(turns(0).Entries(0).InSubagent)
		  Assert.AreEqual("a0fixture000010", turns(0).Entries(0).SessionUID)
		  Assert.AreEqual("Prices now go through fmt in src/app/format.py, and the readme says so.", turns(0).Why)
		  Assert.IsTrue(history.HTML.IndexOf("<span class=""badge"">subagent</span>") >= 0)
		End Sub
	#tag EndMethod


	#tag Constant, Name = kFormatPath, Type = String, Dynamic = False, Default = \"/Users/dev/shop/src/app/format.py", Scope = Private
	#tag EndConstant


End Class
#tag EndClass
