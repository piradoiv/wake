#tag Class
Protected Class WakeNowhereTests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  // Index a scratch copy of the reads-that-led-nowhere fixture (session 9) and read it through
		  // a separate connection.
		  mScratch = TestSupport.NewScratchFolder
		  TestSupport.CopyFolder(TestSupport.FixturesFolder("claude-code").Child("nowhere"), mScratch.Child("nowhere"))

		  Var writer As New WakeIndex(mScratch.Child("index.sqlite"))
		  writer.Open
		  Var indexer As New WakeIndexer(writer)
		  indexer.AddRoot(New WakeIndexRoot("claude-code", mScratch.Child("nowhere")))
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
		Sub CallsTest()
		  Var calls() As WakeToolCallInfo = mCatalog.ToolCalls(WakeCatalog.ToolGroupings.File, "/Users/dev/notes/src/lexer.c")
		  Var count As Integer = calls.Count
		  Assert.AreEqual(2, count)
		  For Each c As WakeToolCallInfo In calls
		    Assert.IsTrue(c.LedNowhere)
		  Next

		  calls = mCatalog.ToolCalls(WakeCatalog.ToolGroupings.File, "/Users/dev/notes/src/parser.c")
		  count = calls.Count
		  Assert.AreEqual(2, count, "the read and the edit")
		  For Each c As WakeToolCallInfo In calls
		    Assert.IsFalse(c.LedNowhere)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FileGroupingTest()
		  Var files() As WakeToolUsageGroup = mCatalog.ToolUsage(WakeCatalog.ToolGroupings.File)

		  Var lexer As WakeToolUsageGroup = FindGroup(files, "/Users/dev/notes/src/lexer.c")
		  Assert.IsNotNil(lexer)
		  If lexer <> Nil Then
		    Assert.AreEqual(2, lexer.Reads)
		    Assert.AreEqual(2, lexer.NowhereReads, "reading it again isn't using it")
		    Assert.IsTrue(lexer.NowhereTokens > 0)
		    Assert.AreEqual(lexer.AddedTokens + lexer.CarriedTokens, lexer.NowhereTokens)
		  End If

		  Var parser As WakeToolUsageGroup = FindGroup(files, "/Users/dev/notes/src/parser.c")
		  Assert.IsNotNil(parser)
		  If parser <> Nil Then
		    Assert.AreEqual(1, parser.Reads)
		    Assert.AreEqual(0, parser.NowhereReads)
		    Assert.AreEqual(0, parser.NowhereTokens)
		  End If

		  Var util As WakeToolUsageGroup = FindGroup(files, "/Users/dev/notes/src/util.h")
		  Assert.IsNotNil(util)
		  If util <> Nil Then Assert.AreEqual(1, util.NowhereReads)

		  Var intents() As WakeToolUsageGroup = mCatalog.ToolUsage(WakeCatalog.ToolGroupings.Pattern)
		  Var reads, nowhere As Integer
		  For Each g As WakeToolUsageGroup In intents
		    reads = reads + g.Reads
		    nowhere = nowhere + g.NowhereReads
		  Next
		  Assert.AreEqual(7, reads, "a re-read is still a read")
		  Assert.AreEqual(4, nowhere)

		  Var reread As WakeToolUsageGroup = FindGroup(intents, WakeCallPattern.kKeyReread)
		  Assert.IsNotNil(reread)
		  If reread <> Nil Then Assert.AreEqual(1, reread.NowhereReads)
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
		Sub FlagsTest()
		  // Used by a later edit, by an answer and by a subagent prompt; never used, read twice and never
		  // used, and mentioned only after a compaction.
		  Var session As WakeSession = TestSupport.ParseClaudeFixture(9, "-Users-dev-notes", "nowhere")
		  Assert.IsNotNil(session)
		  If session Is Nil Then Return

		  Var names() As String
		  Var flags() As String
		  For Each e As WakeEvent In session.Events
		    If Not e.IsToolCall Or Not WakeCallPattern.IsRead(e.Pattern) Then Continue
		    Var path As String = e.TargetPath
		    names.Add(path.NthField("/", path.CountFields("/")))
		    flags.Add(If(e.LedNowhere, "nowhere", "used"))
		  Next

		  Assert.AreEqual("parser.c README.md util.h lexer.c lexer.c notes.md old.c", String.FromArray(names, " "))
		  Assert.AreEqual("used used nowhere nowhere nowhere used nowhere", String.FromArray(flags, " "), _
		  "util.hpp isn't util.h, and old.c is mentioned only in a new context")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReportTest()
		  Var report As New WakeTokenReport(mCatalog, Nil, Nil, "All time")
		  Var text As String = report.Markdown

		  Assert.IsTrue(text.IndexOf("## Reads that led nowhere: ≈") >= 0)
		  Assert.IsTrue(text.IndexOf("4 of 7 reads (57%)") >= 0)
		  Assert.IsTrue(text.IndexOf(WakeCallPattern.LedNowhereAdvice) >= 0)
		  Assert.IsTrue(text.IndexOf("| `/Users/dev/notes/src/lexer.c` | 2 | 2 |") >= 0)
		  Assert.IsTrue(text.IndexOf("`/Users/dev/notes/src/parser.c` | 1 | 0") < 0, "only files with reads that led nowhere")

		  Var later As DateTime = DateTime.Now.AddInterval(0, 0, 1)
		  Var empty As New WakeTokenReport(mCatalog, Nil, later, "Tomorrow")
		  Assert.IsTrue(empty.Markdown.IndexOf("## Reads that led nowhere") < 0)
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
