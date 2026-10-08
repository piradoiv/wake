#tag Class
Protected Class WakeSearchTests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  // Index a scratch copy of the fixtures, then search it through a separate connection,
		  // the way the window does.
		  mScratch = TestSupport.NewScratchFolder
		  TestSupport.CopyFolder(TestSupport.FixturesFolder("claude-code").Child("projects"), mScratch.Child("projects"))

		  Var writer As New WakeIndex(mScratch.Child("index.sqlite"))
		  writer.Open
		  Var indexer As New WakeIndexer(writer)
		  indexer.AddRoot(New WakeIndexRoot("claude-code", mScratch.Child("projects")))
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
		Sub AgentAndProjectFilterTest()
		  Var query As New WakeSearchQuery("TODO")
		  Var count As Integer = mCatalog.Search(query).Count
		  Assert.IsTrue(count > 0, "matches without filters")

		  query.AgentID = "other-agent"
		  count = mCatalog.Search(query).Count
		  Assert.AreEqual(0, count, "other agent")

		  Var projects() As WakeProjectInfo = mCatalog.Projects
		  query.AgentID = "claude-code"
		  query.ProjectID = projects(0).ID
		  count = mCatalog.Search(query).Count
		  Assert.AreEqual(0, count, "demo.app has no TODOs")

		  query.ProjectID = projects(1).ID
		  For Each hit As WakeSearchHit In mCatalog.Search(query)
		    Assert.AreEqual(projects(1).ID, hit.Session.ProjectID)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DateRangeFilterTest()
		  // Session 4, the only one that mentions TODOs, ran on 2026-09-04 (UTC).
		  Var query As New WakeSearchQuery("TODO")
		  query.ToTime = New DateTime(2026, 9, 4, 0, 0, 0, 0, New TimeZone(0))
		  Var count As Integer = mCatalog.Search(query).Count
		  Assert.AreEqual(0, count, "before the session")

		  query.ToTime = Nil
		  query.FromTime = New DateTime(2026, 9, 4, 0, 0, 0, 0, New TimeZone(0))
		  count = mCatalog.Search(query).Count
		  Assert.IsTrue(count > 0, "from the day of the session")

		  query.FromTime = New DateTime(2026, 9, 5, 0, 0, 0, 0, New TimeZone(0))
		  count = mCatalog.Search(query).Count
		  Assert.AreEqual(0, count, "after the session")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EmptyQueryFindsNothingTest()
		  For Each text As String In Array("", "   ", """""", "-", "*")
		    Var count As Integer = mCatalog.Search(New WakeSearchQuery(text)).Count
		    Assert.AreEqual(0, count, "query [" + text + "]")
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub KindFilterTest()
		  Var query As New WakeSearchQuery("TODO")
		  query.Kinds.Add("user")
		  Var hits() As WakeSearchHit = mCatalog.Search(query)

		  // The parent's prompt and the prompt the subagent was given.
		  Var count As Integer = hits.Count
		  Assert.AreEqual(2, count)
		  For Each hit As WakeSearchHit In hits
		    Assert.AreEqual("user", hit.Kind)
		  Next

		  query.Kinds.Add("tool")
		  Var withTools As Integer = mCatalog.Search(query).Count
		  Assert.IsTrue(withTools > count, "tool calls added")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LimitTest()
		  Var query As New WakeSearchQuery("TODO")
		  query.Limit = 1
		  Var count As Integer = mCatalog.Search(query).Count
		  Assert.AreEqual(1, count)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MatchExpressionTest()
		  Assert.AreEqual("", MatchFor(""))
		  Assert.AreEqual("", MatchFor("  " + &u09 + " "))
		  Assert.AreEqual("""parse""* ""main.c""*", MatchFor("parse  main.c"))
		  Assert.AreEqual("""csv test"" ""fix""*", MatchFor("""csv test"" fix"))
		  Assert.AreEqual("""csv test""", MatchFor("""csv test"), "unclosed quote")
		  Assert.AreEqual("""OR""* ""NOT""* ""a*""*", MatchFor("OR NOT a*"), "operators are words")
		  Assert.AreEqual("""say""* ""hi""", MatchFor("say""hi"""), "a quote starts a phrase")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MatchFor(text As String) As String
		  Var query As New WakeSearchQuery(text)
		  Return query.MatchExpression
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PhraseAndPrefixTest()
		  Var count As Integer = mCatalog.Search(New WakeSearchQuery("handl escap")).Count
		  Assert.IsTrue(count > 0, "prefixes")

		  count = mCatalog.Search(New WakeSearchQuery("""handle escapes""")).Count
		  Assert.IsTrue(count > 0, "phrase")

		  count = mCatalog.Search(New WakeSearchQuery("""escapes handle""")).Count
		  Assert.AreEqual(0, count, "phrase order matters")

		  count = mCatalog.Search(New WakeSearchQuery("handle nonexistentword")).Count
		  Assert.AreEqual(0, count, "every term must match")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SubagentHitTest()
		  // "TODO handle escapes" appears only in the output of the subagent's Grep call.
		  Var hits() As WakeSearchHit = mCatalog.Search(New WakeSearchQuery("escapes"))
		  Var count As Integer = hits.Count
		  Assert.IsTrue(count > 0, "found")

		  Var grep As WakeSearchHit
		  For Each hit As WakeSearchHit In hits
		    Assert.IsTrue(hit.InSubagent, "in the subagent")
		    Assert.AreEqual("a0fixture000001", hit.EventSessionUID)
		    Assert.AreEqual(TestSupport.ClaudeFixtureID(4), hit.Session.UID, "top-level session")
		    Assert.AreEqual("Find TODOs", hit.Session.DisplayTitle)
		    If hit.ToolName = "Grep" Then grep = hit
		  Next

		  Assert.IsNotNil(grep, "Grep call")
		  Assert.AreEqual("tool", grep.Kind)
		  Assert.IsNotNil(grep.Timestamp)
		  Assert.IsTrue(grep.Snippet.IndexOf(WakeSearchHit.MatchStart + "escapes" + WakeSearchHit.MatchEnd) >= 0, grep.PlainSnippet)
		  Assert.AreEqual(-1, grep.PlainSnippet.IndexOf(WakeSearchHit.MatchStart))

		  // The hit leads to its event in the timeline.
		  Var timeline As WakeTimeline = WakeTimeline.Load(grep.Session.AgentID, grep.Session.FilePath)
		  Var anchor As String = timeline.Anchor(grep.EventSessionUID, grep.Sequence)
		  Assert.AreNotEqual("", anchor)
		  Assert.IsTrue(timeline.HTML.IndexOf("id=""" + anchor + """") >= 0, "anchor in page")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TopLevelHitTest()
		  Var hits() As WakeSearchHit = mCatalog.Search(New WakeSearchQuery("split_quoted"))
		  Var count As Integer = hits.Count
		  Assert.IsTrue(count > 0, "found")

		  For Each hit As WakeSearchHit In hits
		    Assert.IsFalse(hit.InSubagent)
		    Assert.AreEqual(TestSupport.ClaudeFixtureID(2), hit.Session.UID)
		    Assert.AreEqual(hit.Session.UID, hit.EventSessionUID)
		    Assert.AreEqual("Fix failing CSV quoting test", hit.Session.DisplayTitle)
		  Next
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
