#tag Class
Protected Class WakeCatalogTests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  // Index a scratch copy of the fixtures, then browse it through a separate connection,
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


	#tag Method, Flags = &h21
		Private Function FindSession(sessions() As WakeSessionInfo, sessionNumber As Integer) As WakeSessionInfo
		  For Each s As WakeSessionInfo In sessions
		    If s.UID = TestSupport.ClaudeFixtureID(sessionNumber) Then Return s
		  Next
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MissingSessionIsNilTest()
		  Assert.IsNil(mCatalog.Session(999999))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ProjectsTest()
		  Var projects() As WakeProjectInfo = mCatalog.Projects
		  Var count As Integer = projects.Count
		  Assert.AreEqual(2, count)

		  // Most recently active first.
		  Assert.AreEqual("demo.app", projects(0).Name)
		  Assert.AreEqual("/Users/dev/Open Source/demo.app", projects(0).Path)
		  Assert.AreEqual(1, projects(0).SessionCount)
		  Assert.IsNotNil(projects(0).LastActivity)

		  Assert.AreEqual("demo", projects(1).Name)
		  Assert.AreEqual("claude-code", projects(1).AgentID)
		  Assert.AreEqual(4, projects(1).SessionCount, "command-only session hidden")

		  projects = mCatalog.Projects(True)
		  Assert.AreEqual(5, projects(1).SessionCount, "command-only session included")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SessionDetailTest()
		  Var listed As WakeSessionInfo = FindSession(mCatalog.Sessions("", 0), 4)
		  Var s As WakeSessionInfo = mCatalog.Session(listed.ID)

		  Assert.AreEqual(TestSupport.ClaudeFixtureID(4), s.UID)
		  Assert.AreEqual(1, s.SubagentCount)
		  Assert.AreEqual(25, s.OwnUsage.InputTokens)
		  Assert.AreEqual(135, s.TotalUsage.InputTokens, "subagent tokens rolled up")
		  Assert.AreEqual(31.0, s.DurationSeconds, 0.001)
		  Assert.IsTrue(s.FilePath.EndsWith(TestSupport.ClaudeFixtureID(4) + ".jsonl"), s.FilePath)
		  Var modelCount As Integer = s.Models.Count
		  Assert.IsTrue(modelCount > 0, "per-model usage")

		  Var subagents() As WakeSessionInfo = mCatalog.Subagents(s.ID)
		  Var subagentCount As Integer = subagents.Count
		  Assert.AreEqual(1, subagentCount)
		  Assert.AreEqual("a0fixture000001", subagents(0).UID)
		  Assert.AreEqual(s.ID, subagents(0).ParentID)
		  Assert.AreEqual(110, subagents(0).OwnUsage.InputTokens)

		  Var subagent As WakeSessionInfo = mCatalog.Session(subagents(0).ID)
		  Assert.AreEqual("claude-haiku-4-5-20251001", subagent.Models(0).Left.StringValue)
		  Assert.AreEqual(110, WakeTokenUsage(subagent.Models(0).Right.ObjectValue).InputTokens)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SessionFlagsTest()
		  Var all() As WakeSessionInfo = mCatalog.Sessions("", 0, True)

		  Var s2 As WakeSessionInfo = FindSession(all, 2)
		  Assert.AreEqual("Fix failing CSV quoting test", s2.DisplayTitle)
		  Assert.AreEqual("feature/csv", s2.GitBranch)
		  Assert.IsTrue(s2.HasAgentCost, "cost reported by agent")
		  Assert.IsFalse(s2.IsPartial)

		  Assert.IsTrue(FindSession(all, 3).IsPartial, "partially parsed")
		  Assert.AreNotEqual("", FindSession(all, 3).ParseNote)

		  Var s5 As WakeSessionInfo = FindSession(all, 5)
		  Assert.IsTrue(s5.IsCommandOnly)
		  Assert.IsNil(s5.StartTime)
		  Assert.AreEqual(WakeFormat.kUnknown, WakeFormat.Duration(s5.DurationSeconds))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SessionsTest()
		  Var visible() As WakeSessionInfo = mCatalog.Sessions("", 0)
		  Var count As Integer = visible.Count
		  Assert.AreEqual(5, count, "command-only session hidden, subagents not listed")

		  // Newest first.
		  Var order() As String
		  For Each s As WakeSessionInfo In visible
		    order.Add(s.UID.Right(1))
		  Next
		  Assert.AreEqual("6,4,3,2,1", String.FromArray(order, ","))

		  count = mCatalog.Sessions("", 0, True).Count
		  Assert.AreEqual(6, count, "command-only session included")

		  count = mCatalog.Sessions("other-agent", 0, True).Count
		  Assert.AreEqual(0, count, "other agent")

		  Var projects() As WakeProjectInfo = mCatalog.Projects
		  Var demo As WakeProjectInfo = projects(1)
		  Var inProject() As WakeSessionInfo = mCatalog.Sessions("claude-code", demo.ID)
		  count = inProject.Count
		  Assert.AreEqual(4, count)
		  For Each s As WakeSessionInfo In inProject
		    Assert.AreEqual(demo.ID, s.ProjectID)
		    Assert.AreEqual("/Users/dev/demo", s.ProjectPath)
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
