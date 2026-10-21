#tag Class
Protected Class WakeContextTests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  // Index a scratch copy of the context growth fixture (session 8) and read it through a
		  // separate connection.
		  mScratch = TestSupport.NewScratchFolder
		  TestSupport.CopyFolder(TestSupport.FixturesFolder("claude-code").Child("context"), mScratch.Child("context"))
		  
		  Var writer As New WakeIndex(mScratch.Child("index.sqlite"))
		  writer.Open
		  Var indexer As New WakeIndexer(writer)
		  indexer.AddRoot(New WakeIndexRoot("claude-code", mScratch.Child("context")))
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
		Sub CatalogTest()
		  Var sessions() As WakeSessionInfo = mCatalog.Sessions("", 0)
		  Var count As Integer = sessions.Count
		  Assert.AreEqual(1, count)
		  If count <> 1 Then Return
		  Assert.AreEqual(105, sessions(0).StartingContextTokens)
		  Assert.AreEqual(7605, sessions(0).CarriedTokens)
		  
		  Var groups() As WakeUsageGroup = mCatalog.Usage(WakeCatalog.UsageGroupings.Session)
		  count = groups.Count
		  Assert.AreEqual(1, count)
		  If count = 1 Then Assert.AreEqual(7605, groups(0).CarriedTokens)
		  
		  groups = mCatalog.Usage(WakeCatalog.UsageGroupings.Model)
		  count = groups.Count
		  Assert.AreEqual(1, count)
		  If count = 1 Then Assert.AreEqual(7605, groups(0).CarriedTokens)
		  
		  Var later As DateTime = DateTime.Now.AddInterval(0, 0, 1)
		  groups = mCatalog.Usage(WakeCatalog.UsageGroupings.Day, later)
		  count = groups.Count
		  Assert.AreEqual(0, count)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LongSessionsTest()
		  Var found() As WakeLongSession = mCatalog.LongSessions
		  Var count As Integer = found.Count
		  Assert.AreEqual(1, count)
		  If count <> 1 Then Return
		  
		  Var g As WakeLongSession = found(0)
		  Assert.AreEqual(7605, g.CarriedTokens)
		  Assert.AreEqual(4, g.TurnCount)
		  Assert.AreEqual(2625, g.PeakContextTokens)
		  Assert.AreEqual(7605, g.Total.CacheReadTokens, "carried tokens are priced as cache reads")
		  Assert.IsNotNil(g.Session)
		  Assert.AreEqual(2, g.TippingTurn, "turn 2 carried 4,310 tokens and did 625 of its own")
		  Assert.AreEqual("Now add tests for the loader.", g.TippingPrompt)
		  Assert.IsNotNil(g.TippingTime)
		  
		  Var later As DateTime = DateTime.Now.AddInterval(0, 0, 1)
		  found = mCatalog.LongSessions(later)
		  count = found.Count
		  Assert.AreEqual(0, count)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReportTest()
		  Var report As New WakeTokenReport(mCatalog, Nil, Nil, "All time")
		  Var text As String = report.Markdown
		  
		  Assert.IsTrue(text.IndexOf("## Long sessions") >= 0)
		  Assert.IsTrue(text.IndexOf(WakeTokenReport.LongSessionAdvice) >= 0)
		  Assert.IsTrue(text.IndexOf("Add a loader for the settings file.: ≈7.6K carried") >= 0, "the session and what it carried")
		  Assert.IsTrue(text.IndexOf("From turn 2 on") >= 0)
		  Assert.IsTrue(text.IndexOf("Now add tests for the loader.") >= 0, "the prompt of that turn")
		  
		  Var later As DateTime = DateTime.Now.AddInterval(0, 0, 1)
		  Var empty As New WakeTokenReport(mCatalog, Nil, later, "Tomorrow")
		  Assert.IsTrue(empty.Markdown.IndexOf("## Long sessions") < 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TurnsTest()
		  // Starting context 105. Each turn carries what the context held before it, beyond 105, once
		  // per response until a compaction. The third turn is compacted at its second response.
		  Var file As FolderItem = mScratch.Child("context").Child("-Users-dev-long").Child("00000000-0000-4000-8000-000000000008.jsonl")
		  Var session As WakeSession = WakeCore.LoadSession("claude-code", file.NativePath)
		  Assert.AreEqual(105, session.StartingContextTokens)
		  Assert.AreEqual(7605, session.CarriedTokens)
		  
		  Var prompts() As WakeEvent
		  For Each e As WakeEvent In session.Events
		    If e.Kind = WakeEvent.Kinds.UserPrompt Then prompts.Add(e)
		  Next
		  Var count As Integer = prompts.Count
		  Assert.AreEqual(4, count)
		  If count <> 4 Then Return
		  
		  Assert.AreEqual(0, prompts(0).TurnCarriedTokens, "the first turn has nothing older to carry")
		  Assert.AreEqual(4310, prompts(1).TurnCarriedTokens, "2 × (2,260 − 105)")
		  Assert.AreEqual(2415, prompts(2).TurnCarriedTokens, "carried by the response before the compaction only")
		  Assert.AreEqual(880, prompts(3).TurnCarriedTokens, "less after the compaction")
		  
		  Assert.AreEqual(105, prompts(0).TurnContextTokens)
		  Assert.AreEqual(2315, prompts(1).TurnContextTokens)
		  Assert.AreEqual(2625, prompts(2).TurnContextTokens)
		  Assert.AreEqual(1040, prompts(3).TurnContextTokens)
		  
		  Assert.IsFalse(prompts(1).TurnStartsNewContext)
		  Assert.IsTrue(prompts(2).TurnStartsNewContext)
		  
		  Assert.AreEqual(prompts(0).Sequence, session.Responses(0).TurnSequence)
		  Assert.AreEqual(prompts(2).Sequence, session.Responses(5).TurnSequence)
		  Assert.IsTrue(session.Responses(5).StartsNewContext)
		  
		  Var carried As WakeTokenUsage = session.CarriedUsage.Total
		  Assert.AreEqual(7605, carried.CacheReadTokens)
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
