#tag Class
Protected Class WakeTokenReportTests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  // Index a scratch copy of the call-pattern fixture (session 7) and read it through a
		  // separate connection.
		  mScratch = TestSupport.NewScratchFolder
		  TestSupport.CopyFolder(TestSupport.FixturesFolder("claude-code").Child("patterns"), mScratch.Child("patterns"))
		  
		  Var writer As New WakeIndex(mScratch.Child("index.sqlite"))
		  writer.Open
		  Var indexer As New WakeIndexer(writer)
		  indexer.AddRoot(New WakeIndexRoot("claude-code", mScratch.Child("patterns")))
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
		Sub FileWasteTest()
		  // config.py is read with sed, read again with Read, edited, and read whole after the edit.
		  Var files() As WakeToolUsageGroup = mCatalog.ToolUsage(WakeCatalog.ToolGroupings.File)
		  Var config As WakeToolUsageGroup = FindGroup(files, "/Users/dev/lab/src/config.py")
		  Assert.IsNotNil(config, "relative and absolute paths are one file")
		  If config Is Nil Then Return
		  Assert.AreEqual(4, config.Calls)
		  Assert.AreEqual(3, config.Reads)
		  Assert.AreEqual(1, config.Rereads)
		  Assert.AreEqual(2, config.LineRangeReads)
		  Assert.AreEqual(1, config.ReadSessionCount)
		  
		  Var guide As WakeToolUsageGroup = FindGroup(files, "/Users/dev/lab/docs/user guide.md")
		  Assert.IsNotNil(guide)
		  If guide <> Nil Then Assert.AreEqual(0, guide.Rereads)
		  
		  // The files of one pattern.
		  Var wholeFiles() As WakeToolUsageGroup = mCatalog.ToolUsage(WakeCatalog.ToolGroupings.File, Nil, _
		  WakeCatalog.ToolGroupings.Pattern, WakeCallPattern.kKeyWholeFile)
		  Var count As Integer = wholeFiles.Count
		  Assert.AreEqual(2, count)
		  Assert.IsNotNil(FindGroup(wholeFiles, "/Users/dev/lab/docs/user guide.md"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FindGroup(groups() As WakeToolUsageGroup, key As String) As WakeToolUsageGroup
		  For Each g As WakeToolUsageGroup In groups
		    If g.Key = key Then Return g
		  Next
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PatternGroupingTest()
		  Var groups() As WakeToolUsageGroup = mCatalog.ToolUsage(WakeCatalog.ToolGroupings.Pattern)
		  Var count As Integer = groups.Count
		  Assert.AreEqual(6, count, "line range, whole file, section, search, edit and re-read")
		  
		  Var lineRange As WakeToolUsageGroup = FindGroup(groups, WakeCallPattern.kKeyLineRange)
		  Assert.IsNotNil(lineRange)
		  If lineRange <> Nil Then
		    Assert.AreEqual(2, lineRange.Calls, "sed and head; the Read is a re-read")
		    Assert.AreEqual("Line range", lineRange.Label)
		  End If
		  
		  Var reread As WakeToolUsageGroup = FindGroup(groups, WakeCallPattern.kKeyReread)
		  Assert.IsNotNil(reread)
		  If reread <> Nil Then
		    Assert.AreEqual(1, reread.Calls)
		    Assert.AreEqual(1, reread.Rereads)
		    Assert.AreEqual("Re-read", reread.Label)
		  End If
		  
		  Var wholeFile As WakeToolUsageGroup = FindGroup(groups, WakeCallPattern.kKeyWholeFile)
		  If wholeFile <> Nil Then Assert.AreEqual(2, wholeFile.Calls, "cat, and the Read after the edit")
		  Assert.IsNil(FindGroup(groups, WakeCallPattern.kKeyRun))
		  
		  Var calls() As WakeToolCallInfo = mCatalog.ToolCalls(WakeCatalog.ToolGroupings.Pattern, WakeCallPattern.kKeyReread)
		  count = calls.Count
		  Assert.AreEqual(1, count)
		  If count = 1 Then Assert.AreEqual("/Users/dev/lab/src/config.py", calls(0).TargetPath)
		  If count = 1 Then Assert.AreEqual(WakeCallPattern.kKeyReread, calls(0).PatternKey)
		  
		  // A file's calls carry their intents.
		  calls = mCatalog.ToolCalls(WakeCatalog.ToolGroupings.File, "/Users/dev/lab/src/config.py")
		  Var keys() As String
		  For Each c As WakeToolCallInfo In calls
		    keys.Add(c.PatternKey)
		  Next
		  count = keys.Count
		  Assert.AreEqual(4, count)
		  Assert.IsTrue(keys.IndexOf(WakeCallPattern.kKeyEdit) >= 0)
		  Assert.IsTrue(keys.IndexOf(WakeCallPattern.kKeyLineRange) >= 0)
		  Assert.IsTrue(keys.IndexOf(WakeCallPattern.kKeyWholeFile) >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReportTest()
		  Var report As New WakeTokenReport(mCatalog, Nil, Nil, "All time")
		  Var text As String = report.Markdown
		  
		  Assert.IsTrue(text.BeginsWith("# Where the tokens went: All time"))
		  For Each key As String In Array(WakeCallPattern.kKeyLineRange, WakeCallPattern.kKeyWholeFile, WakeCallPattern.kKeySection, _
		    WakeCallPattern.kKeySearch, WakeCallPattern.kKeyEdit, WakeCallPattern.kKeyReread)
		    Assert.IsTrue(text.IndexOf(". " + WakeCallPattern.Label(key) + ": ≈") >= 0, "section for " + key)
		    Assert.IsTrue(text.IndexOf(WakeCallPattern.Advice(key)) >= 0, "advice for " + key)
		  Next
		  For Each key As String In Array(WakeCallPattern.kKeyRun, WakeCallPattern.kKeyListing, WakeCallPattern.kKeyWeb, WakeCallPattern.kKeyOther)
		    Assert.IsTrue(text.IndexOf(". " + WakeCallPattern.Label(key) + ": ≈") < 0, "no section for " + key)
		  Next
		  
		  // The search's example holds three backticks, so its fence has four.
		  Assert.IsTrue(text.IndexOf("````" + &u0A + "   $ grep -rn ""```"" docs" + &u0A + "   ````") >= 0, "fence longer than any backtick run")
		  Assert.IsTrue(text.IndexOf("`/Users/dev/lab/src/config.py`") >= 0, "top files")
		  Assert.IsTrue(text.IndexOf("estimated cost") < 0, "no prices, no cost")
		  
		  Var later As DateTime = DateTime.Now.AddInterval(0, 0, 1)
		  Var empty As New WakeTokenReport(mCatalog, Nil, later, "Tomorrow")
		  Assert.IsTrue(empty.Markdown.IndexOf("No tool calls in this period") >= 0)
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
