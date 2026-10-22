#tag Class
Protected Class WakeFileChangesTests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  // Index a scratch copy of the file-changes fixture (session 10) and read it through a
		  // separate connection.
		  mScratch = TestSupport.NewScratchFolder
		  TestSupport.CopyFolder(TestSupport.FixturesFolder("claude-code").Child("changes"), mScratch.Child("changes"))

		  Var writer As New WakeIndex(mScratch.Child("index.sqlite"))
		  writer.Open
		  Var indexer As New WakeIndexer(writer)
		  indexer.AddRoot(New WakeIndexRoot("claude-code", mScratch.Child("changes")))
		  Call indexer.Run
		  writer.Close

		  mIndex = New WakeIndex(mScratch.Child("index.sqlite"))
		  mIndex.Open
		  mCatalog = New WakeCatalog(mIndex)
		End Sub
	#tag EndEvent

	#tag Event
		Sub TearDown()
		  mCatalog = Nil
		  If mIndex <> Nil Then mIndex.Close
		  mIndex = Nil
		  TestSupport.RemoveScratchFolder(mScratch)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub ActionsTest()
		  // A Write that created a file, one that replaced it and an edit; a failed edit and a sed -i
		  // are still events, but only the parser's actions on edit and write tools count.
		  Var session As WakeSession = TestSupport.ParseClaudeFixture(10, "-Users-dev-shop", "changes")
		  Assert.IsNotNil(session)
		  If session Is Nil Then Return

		  Var actions() As String
		  Var lines() As String
		  For Each e As WakeEvent In session.Events
		    If e.ChangeAction = "" Then Continue
		    actions.Add(e.ChangeAction)
		    Var counts As Pair = e.ChangedLineCounts
		    lines.Add("+" + counts.Left.StringValue + "-" + counts.Right.StringValue)
		  Next

		  Assert.AreEqual("create edit write edit create", String.FromArray(actions, " "))
		  Assert.AreEqual("+2-0 +2-1 +2-1 +1-1 +1-0", String.FromArray(lines, " "))

		  Var subagentActions() As String
		  For Each e As WakeEvent In session.Subagents(0).Events
		    If e.ChangeAction <> "" Then subagentActions.Add(e.ChangeAction)
		  Next
		  Assert.AreEqual("edit", String.FromArray(subagentActions, " "))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChangedFilesTest()
		  Var files() As WakeChangedFile = mCatalog.ChangedFiles("", 0)
		  Var count As Integer = files.Count
		  Assert.AreEqual(4, count, "the failed edit and the sed -i don't count")

		  Var formatFile As WakeChangedFile = FindFile(files, "src/app/format.py")
		  Assert.IsNotNil(formatFile)
		  If formatFile <> Nil Then
		    Assert.AreEqual("/Users/dev/shop/src/app/format.py", formatFile.TargetPath)
		    Assert.AreEqual("/Users/dev/shop", formatFile.ProjectPath)
		    Assert.IsFalse(formatFile.IsOutside)
		    Assert.AreEqual(2, formatFile.Edits)
		    Assert.AreEqual(4, formatFile.LinesAdded)
		    Assert.AreEqual(1, formatFile.LinesRemoved)
		    Assert.AreEqual(1, formatFile.SessionCount)
		    Assert.AreEqual(0, formatFile.Reads)
		    Assert.IsTrue(formatFile.Tokens > 0, "its two writes")
		    Assert.AreEqual("format.py", formatFile.Name)
		    Assert.IsNotNil(formatFile.LastChanged)
		    Var written As New DateTime(2026, 8, 30, 11, 0, 2, 0, New TimeZone(0))
		    If formatFile.LastChanged <> Nil Then Assert.AreEqual(written.SecondsFrom1970, formatFile.LastChanged.SecondsFrom1970)
		    Assert.IsFalse(formatFile.ExistsOnDisk)
		  End If

		  Var price As WakeChangedFile = FindFile(files, "src/app/price.py")
		  Assert.IsNotNil(price)
		  If price <> Nil Then
		    Assert.AreEqual(1, price.Edits)
		    Assert.AreEqual(2, price.LinesAdded)
		    Assert.AreEqual(1, price.LinesRemoved)
		    Assert.AreEqual(1, price.Reads)
		  End If

		  Var readme As WakeChangedFile = FindFile(files, "README.md")
		  Assert.IsNotNil(readme, "a subagent's edit")
		  If readme <> Nil Then Assert.AreEqual(2, readme.LinesAdded)

		  Var notes As WakeChangedFile = FindFile(files, "/Users/dev/notes/shop.md")
		  Assert.IsNotNil(notes)
		  If notes <> Nil Then
		    Assert.IsTrue(notes.IsOutside)
		    Assert.AreEqual(1, notes.LinesAdded)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ChildNames(node As WakeFileNode) As String
		  Var names() As String
		  For Each child As WakeFileNode In node.Children
		    names.Add(child.Name)
		  Next
		  Return String.FromArray(names, " ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FileChangesTest()
		  Var files() As WakeChangedFile = mCatalog.ChangedFiles("", 0)
		  Var formatFile As WakeChangedFile = FindFile(files, "src/app/format.py")
		  Assert.IsNotNil(formatFile)
		  If formatFile Is Nil Then Return

		  Var changes() As WakeFileChangeInfo = mCatalog.FileChanges(formatFile.ProjectID, formatFile.TargetPath)
		  Var count As Integer = changes.Count
		  Assert.AreEqual(2, count)
		  If count = 2 Then
		    Assert.AreEqual(WakeEvent.kChangeWrite, changes(0).Action, "newest first")
		    Assert.AreEqual("Round prices and update my notes.", changes(0).Prompt)
		    Assert.AreEqual(WakeEvent.kChangeCreate, changes(1).Action)
		    Assert.AreEqual("Add a price formatter.", changes(1).Prompt)
		    Assert.AreEqual("Add a price formatter", changes(1).Session.Title)
		    Assert.IsFalse(changes(1).InSubagent)
		  End If

		  Var readme As WakeChangedFile = FindFile(files, "README.md")
		  If readme Is Nil Then Return
		  changes = mCatalog.FileChanges(readme.ProjectID, readme.TargetPath)
		  count = changes.Count
		  Assert.AreEqual(1, count)
		  If count = 1 Then
		    Assert.IsTrue(changes(0).InSubagent)
		    Assert.AreEqual("a0fixture000010", changes(0).EventSessionUID)
		    Assert.AreEqual("Add a price formatter.", changes(0).Prompt, "the prompt that started the subagent")
		    Assert.AreEqual(0, changes(0).PromptSequence)
		    Assert.AreEqual("00000000-0000-4000-8000-000000000010", changes(0).Session.UID)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FindFile(files() As WakeChangedFile, path As String) As WakeChangedFile
		  For Each f As WakeChangedFile In files
		    If f.Path = path Then Return f
		  Next
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PeriodAndSessionTest()
		  // Changes are filtered by their own time: the second prompt began at 11:00 UTC.
		  Var since As New DateTime(2026, 8, 30, 10, 30, 0, 0, New TimeZone(0))
		  Var files() As WakeChangedFile = mCatalog.ChangedFiles("", 0, since)
		  Var paths() As String
		  For Each f As WakeChangedFile In files
		    paths.Add(f.Path)
		  Next
		  paths.Sort
		  Assert.AreEqual("/Users/dev/notes/shop.md src/app/format.py", String.FromArray(paths, " "))

		  Var formatFile As WakeChangedFile = FindFile(files, "src/app/format.py")
		  If formatFile <> Nil Then Assert.AreEqual(1, formatFile.Edits)

		  Var sessions() As WakeSessionInfo = mCatalog.Sessions("", 0)
		  Var sessionCount As Integer = sessions.Count
		  Assert.AreEqual(1, sessionCount)
		  If sessionCount = 0 Then Return
		  sessions = mCatalog.Sessions("", 0, False, since)
		  sessionCount = sessions.Count
		  Assert.AreEqual(0, sessionCount, "sessions go by their start")

		  sessions = mCatalog.Sessions("", 0)
		  files = mCatalog.ChangedFiles("", 0, Nil, sessions(0).ID)
		  Var count As Integer = files.Count
		  Assert.AreEqual(4, count)

		  files = mCatalog.ChangedFiles("claude-code", sessions(0).ProjectID, Nil, sessions(0).ID + 1000)
		  count = files.Count
		  Assert.AreEqual(0, count)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RelativePathTest()
		  Assert.AreEqual("src/a.c", WakeCore.RelativePath("/work/src/a.c", "/work"))
		  Assert.AreEqual("src/a.c", WakeCore.RelativePath("/work/src/a.c", "/work/"))
		  Assert.AreEqual("/workshop/a.c", WakeCore.RelativePath("/workshop/a.c", "/work"))
		  Assert.AreEqual("/Work/a.c", WakeCore.RelativePath("/Work/a.c", "/work"))
		  Assert.AreEqual("src\a.c", WakeCore.RelativePath("C:\work\src\a.c", "C:\work"))
		  Assert.AreEqual("/work/a.c", WakeCore.RelativePath("/work/a.c", ""))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TreeTest()
		  Var projects() As WakeFileNode = WakeFileNode.Build(mCatalog.ChangedFiles("", 0))
		  Var count As Integer = projects.Count
		  Assert.AreEqual(1, count)
		  If count = 0 Then Return

		  Var project As WakeFileNode = projects(0)
		  Assert.IsTrue(project.Kind = WakeFileNode.Kinds.Project)
		  Assert.AreEqual("/Users/dev/shop", project.Name)
		  Assert.AreEqual(5, project.Edits)
		  Assert.AreEqual(9, project.LinesAdded)
		  Assert.AreEqual(2, project.LinesRemoved)
		  Assert.AreEqual(1, project.Reads)
		  Assert.AreEqual(1, project.SessionCount)
		  Assert.AreEqual("README.md src/app " + WakeFileNode.kOutsideName, ChildNames(project), "src and app collapse; outside comes last")

		  Var appFolder As WakeFileNode = project.Children(1)
		  Assert.IsTrue(appFolder.Kind = WakeFileNode.Kinds.Folder)
		  Assert.AreEqual("src/app", appFolder.Path)
		  Assert.AreEqual("format.py price.py", ChildNames(appFolder))
		  Assert.AreEqual(3, appFolder.Edits)
		  Assert.AreEqual(6, appFolder.LinesAdded)

		  Var outside As WakeFileNode = project.Children(2)
		  Assert.IsTrue(outside.Kind = WakeFileNode.Kinds.Outside)
		  Assert.AreEqual("/Users/dev/notes", ChildNames(outside))
		  Assert.AreEqual("shop.md", ChildNames(outside.Children(0)))
		  Assert.AreEqual("/Users/dev/notes/shop.md", outside.Children(0).Children(0).Path)

		  // By edits, most first: src/app (3) before README.md (1); outside stays last.
		  project.Sort(WakeFileNode.Columns.Edits, False)
		  Assert.AreEqual("src/app README.md " + WakeFileNode.kOutsideName, ChildNames(project))
		  Assert.AreEqual("format.py price.py", ChildNames(project.Children(0)))
		  project.Sort(WakeFileNode.Columns.Name, False)
		  Assert.AreEqual("src/app README.md " + WakeFileNode.kOutsideName, ChildNames(project))
		  Assert.AreEqual("price.py format.py", ChildNames(project.Children(0)))
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mCatalog As WakeCatalog
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIndex As WakeIndex
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScratch As FolderItem
	#tag EndProperty


End Class
#tag EndClass
