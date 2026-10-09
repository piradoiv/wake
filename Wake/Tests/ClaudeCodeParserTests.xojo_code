#tag Class
Protected Class ClaudeCodeParserTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub BasicSessionTest()
		  // Fixture 1: one prompt, one answer split across two records.
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(1)

		  Assert.AreEqual(TestSupport.ClaudeFixtureID(1), s.ID)
		  Assert.AreEqual("claude-code", s.AgentID)
		  Assert.AreEqual("/Users/dev/demo", s.ProjectPath)
		  Assert.AreEqual("Explain parse function", s.Title)
		  Assert.AreEqual("main", s.GitBranch)
		  Assert.AreEqual("2.1.292", s.AgentVersion)
		  Assert.AreEqual(1, s.PromptCount)
		  Assert.AreEqual("Explain what the parse function in main.c does.", s.FirstPrompt)
		  Assert.AreEqual(3500, s.ActiveDurationMs)
		  Assert.AreEqual(3.5, s.DurationSeconds, 0.001)
		  Assert.IsFalse(s.Report.IsPartial, s.Report.Summary)

		  Var actualCount As Integer = s.Events.Count
		  Assert.AreEqual(3, actualCount, "prompt, thinking, text")
		  If s.Events.Count <> 3 Then Return
		  Assert.IsTrue(s.Events(0).Kind = WakeEvent.Kinds.UserPrompt)
		  Assert.IsTrue(s.Events(1).Kind = WakeEvent.Kinds.Thinking)
		  Assert.IsTrue(s.Events(2).Kind = WakeEvent.Kinds.AssistantText)
		  Assert.AreEqual("claude-opus-5-5", s.Events(2).Model)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EditPatchTest()
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(2)
		  Var e As WakeEvent = TestSupport.FindTool(s, "toolu_edit_01")
		  Assert.IsNotNil(e)
		  If e Is Nil Then Return

		  Assert.IsTrue(e.Kind = WakeEvent.Kinds.FileEdit)
		  Assert.AreEqual("/Users/dev/demo/main.c", e.FilePath)
		  Assert.IsTrue(e.Patch.BeginsWith("@@ -1,3 +1,3 @@"), "structured patch replaces the input diff: " + e.Patch)
		  Assert.IsTrue(e.Patch.IndexOf("-  return split(s, ',');") >= 0)
		  Assert.IsTrue(e.Patch.IndexOf("+  return split_quoted(s, ',');") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EmptyFileTest()
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(5)

		  Var actualCount As Integer = s.Events.Count
		  Assert.AreEqual(0, actualCount)
		  Assert.AreEqual("", s.Report.FileError)
		  Assert.IsFalse(s.Report.IsPartial)
		  Assert.AreEqual(0, s.Usage.Total)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IsSessionFileTest()
		  Var parser As New ClaudeCodeParser
		  Var project As FolderItem = TestSupport.FixturesFolder("claude-code").Child("projects").Child("-Users-dev-demo")

		  Assert.IsTrue(parser.IsSessionFile(TestSupport.ClaudeFixture(1)))
		  Assert.IsFalse(parser.IsSessionFile(project.Child("memory").Child("MEMORY.md")), "memory notes")
		  Assert.IsFalse(parser.IsSessionFile(project.Child(TestSupport.ClaudeFixtureID(2))), "session side folder")
		  Assert.IsFalse(parser.IsSessionFile(project.Child(TestSupport.ClaudeFixtureID(4)).Child("subagents").Child("agent-a0fixture000001.jsonl")), "subagent transcript")
		  Assert.IsFalse(parser.IsSessionFile(project.Child("does-not-exist.jsonl")), "missing file")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MissingFileTest()
		  Var parser As New ClaudeCodeParser
		  Var s As WakeSession = parser.ParseSession(Nil)

		  Assert.IsTrue(s.Report.IsPartial)
		  Assert.AreNotEqual("", s.Report.FileError)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PersistedOutputResolvedTest()
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(2)
		  Var e As WakeEvent = TestSupport.FindTool(s, "toolu_bash_02")
		  Assert.IsNotNil(e)
		  If e Is Nil Then Return

		  Assert.AreEqual(2048, e.PersistedOutputSize)
		  Assert.IsTrue(e.PersistedOutputPath.EndsWith("bfixture01.txt"), e.PersistedOutputPath)

		  // The recorded path points at /Users/dev/...; the parser must find the local copy instead.
		  Var f As New FolderItem(e.PersistedOutputPath, FolderItem.PathModes.Native)
		  Assert.IsTrue(f.Exists, "resolved to the session's tool-results folder: " + e.PersistedOutputPath)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ProjectPathFromCwdTest()
		  // The folder name "-Users-dev-Open-Source-demo-app" cannot be decoded; cwd is authoritative.
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(6, "-Users-dev-Open-Source-demo-app")

		  Assert.AreEqual("/Users/dev/Open Source/demo.app", s.ProjectPath)
		  Assert.AreEqual("", s.GitBranch)
		  Assert.AreEqual(16, s.Usage.Total)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RobustnessTest()
		  // Fixture 3: malformed lines, unknown record and block types, meta and command records.
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(3)
		  Var r As WakeParseReport = s.Report

		  Assert.IsTrue(r.IsPartial, "partially parsed")
		  Assert.AreEqual("", r.FileError)
		  Assert.AreEqual(3, r.MalformedLines, "cut line, 'not json', truncated tail")
		  Assert.AreEqual(1, r.BlankLines)
		  Assert.AreEqual(0, r.RecordErrors)
		  Assert.AreEqual(1, r.UnknownRecordTypes.Lookup("future-record-kind", 0).IntegerValue)
		  Assert.AreEqual(1, r.UnknownBlockTypes.Lookup("hologram", 0).IntegerValue)
		  Assert.AreNotEqual("", r.Summary)

		  Assert.AreEqual(1, s.PromptCount, "only the text+image prompt is a real prompt")
		  Assert.AreEqual("What does this screenshot show?" + &u0A + "[image]", s.FirstPrompt)
		  Assert.AreEqual(4, TestSupport.CountEvents(s, WakeEvent.Kinds.System), "command, meta, informational, task notification")
		  Assert.AreEqual(1, TestSupport.CountEvents(s, WakeEvent.Kinds.Error), "synthetic API error")

		  // The synthetic error message's usage is not counted.
		  Assert.AreEqual(10, s.Usage.InputTokens)
		  Assert.AreEqual(10, s.Usage.OutputTokens)
		  Assert.IsFalse(s.UsageByModel.HasKey("<synthetic>"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SessionMetadataTest()
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(2)

		  Assert.AreEqual("Fix failing CSV quoting test", s.Title, "the last ai-title wins")
		  Assert.AreEqual("feature/csv", s.GitBranch)
		  Assert.IsTrue(s.HasAgentReportedCost)
		  Assert.AreEqual(0.1234, s.AgentReportedCostUSD, 0.00001)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ShellCommandTest()
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(2)
		  Var e As WakeEvent = TestSupport.FindTool(s, "toolu_bash_01")
		  Assert.IsNotNil(e)
		  If e Is Nil Then Return

		  Assert.IsTrue(e.Kind = WakeEvent.Kinds.ShellCommand)
		  Assert.AreEqual("make test", e.Command)
		  Assert.IsTrue(e.ResultIsError, "is_error: true")
		  Assert.AreEqual("FAIL test_csv: expected 3 fields, got 2", e.Stdout)
		  Assert.AreEqual("$ make test", e.Summary)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SubagentTest()
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(4)

		  Var actualCount As Integer = s.Subagents.Count
		  Assert.AreEqual(1, actualCount)
		  If s.Subagents.Count <> 1 Then Return

		  Var subagent As WakeSession = s.Subagents(0)
		  Assert.IsTrue(subagent.IsSubagent)
		  Assert.AreEqual("a0fixture000001", subagent.SubagentID)
		  Assert.AreEqual("Explore", subagent.SubagentType)
		  Assert.AreEqual("toolu_agent_01", subagent.ParentToolUseID)
		  Assert.AreEqual(1, subagent.PromptCount)

		  Var agentCall As WakeEvent = TestSupport.FindTool(s, "toolu_agent_01")
		  Assert.IsNotNil(agentCall)
		  If agentCall <> Nil Then Assert.AreSame(subagent, agentCall.Subagent, "linked to the Agent tool call")

		  // Own usage is kept separate; the total rolls subagents up.
		  Assert.AreEqual(25, s.Usage.InputTokens)
		  Assert.AreEqual(50, s.Usage.OutputTokens)
		  Assert.AreEqual(100, s.Usage.CacheWriteTokens)
		  Assert.AreEqual(400, s.Usage.CacheReadTokens)
		  Assert.AreEqual(110, subagent.Usage.InputTokens)
		  Assert.AreEqual(25, subagent.Usage.OutputTokens)
		  Assert.IsTrue(subagent.UsageByModel.HasKey("claude-haiku-4-5-20251001"))

		  Var total As WakeTokenUsage = s.TotalUsage
		  Assert.AreEqual(135, total.InputTokens)
		  Assert.AreEqual(75, total.OutputTokens)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToolCallsPairedByIDTest()
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(2)

		  Var calls As Integer
		  For Each e As WakeEvent In s.Events
		    If e.IsToolCall Then
		      calls = calls + 1
		      Assert.IsTrue(e.HasResult, e.ToolUseID + " has a result")
		    End If
		  Next
		  Assert.AreEqual(6, calls)
		  Assert.AreEqual(0, TestSupport.CountEvents(s, WakeEvent.Kinds.ToolResult), "no orphan results")

		  // The two parallel Reads get their results in reverse order.
		  Var mainRead As WakeEvent = TestSupport.FindTool(s, "toolu_read_01")
		  Var testRead As WakeEvent = TestSupport.FindTool(s, "toolu_read_02")
		  Assert.IsTrue(mainRead.ResultText.IndexOf("split(s, ',')") >= 0, mainRead.ResultText)
		  Assert.IsTrue(testRead.ResultText.IndexOf("csv.h") >= 0, testRead.ResultText)
		  Assert.AreEqual("Read", mainRead.ToolName)
		  Assert.IsTrue(mainRead.ToolInputJSON.IndexOf("main.c") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SessionFilesTest()
		  Var parser As New ClaudeCodeParser
		  Var projects As FolderItem = TestSupport.FixturesFolder("claude-code").Child("projects")

		  Var allCount As Integer = parser.SessionFiles(projects).Count
		  Assert.AreEqual(6, allCount, "projects root")

		  Var oneProjectCount As Integer = parser.SessionFiles(projects.Child("-Users-dev-demo")).Count
		  Assert.AreEqual(5, oneProjectCount, "a single project folder added as a custom root")

		  Var related() As FolderItem = parser.RelatedFiles(TestSupport.ClaudeFixture(4))
		  Var relatedCount As Integer = related.Count
		  Assert.AreEqual(2, relatedCount, "subagent transcript and metadata")

		  Var noneCount As Integer = parser.RelatedFiles(TestSupport.ClaudeFixture(1)).Count
		  Assert.AreEqual(0, noneCount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TokenAttributionTest()
		  // Session 2's contexts grow by 175, 1268, 459, 439 and 485 tokens after its tool results.
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(2)
		  Var responses As Integer = s.Responses.Count
		  Assert.AreEqual(6, responses)

		  Var bash As WakeEvent = TestSupport.FindTool(s, "toolu_bash_01")
		  Assert.AreEqual(175, bash.AddedTokens, "growth before the second response")
		  Assert.AreEqual(700, bash.CarriedTokens, "read again by the four responses after it")

		  // The second response read 5 input and 200 one-hour cache-write tokens, so the share is split alike.
		  Var added As WakeTokenUsage = bash.AddedUsage.Total
		  Assert.AreEqual(4, added.InputTokens)
		  Assert.AreEqual(171, added.CacheWriteTokens)
		  Assert.AreEqual(171, added.CacheWrite1hTokens)
		  Assert.AreEqual(700, bash.CarriedUsage.Total.CacheReadTokens)

		  // Parallel results share the growth by the length of their text: 53 and 52 characters.
		  Var read2 As WakeEvent = TestSupport.FindTool(s, "toolu_read_02")
		  Var read1 As WakeEvent = TestSupport.FindTool(s, "toolu_read_01")
		  Assert.AreEqual(640, read2.AddedTokens)
		  Assert.AreEqual(628, read1.AddedTokens)
		  Assert.AreEqual(1920, read2.CarriedTokens)

		  Assert.AreEqual(459, TestSupport.FindTool(s, "toolu_edit_01").AddedTokens)
		  Assert.AreEqual(439, TestSupport.FindTool(s, "toolu_write_01").CarriedTokens, "one response after it")
		  Var last As WakeEvent = TestSupport.FindTool(s, "toolu_bash_02")
		  Assert.AreEqual(485, last.AddedTokens)
		  Assert.AreEqual(0, last.CarriedTokens, "no response after the last one re-reads it")
		  Assert.IsNil(last.CarriedUsage)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ResponseAndToolTimingTest()
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(2)

		  // The first response answers the prompt at 09:00:00 and its last record is at 09:00:01.5.
		  Assert.AreEqual(1.5, s.Responses(0).Seconds, 0.001)
		  // The second answers the Bash result at 09:00:04 and ends at 09:00:05.1.
		  Assert.AreEqual(1.1, s.Responses(1).Seconds, 0.001)

		  Var bash As WakeEvent = TestSupport.FindTool(s, "toolu_bash_01")
		  Assert.AreEqual(2.5, bash.ResultSeconds, 0.001)
		  Assert.IsTrue(bash.Response Is s.Responses(0), "the call belongs to the first response")
		  Var first As Integer = s.Responses(0).FirstSequence
		  Assert.AreEqual(1, first, "the text block after the prompt")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TurnStatsTest()
		  Var basic As WakeSession = TestSupport.ParseClaudeFixture(1)
		  Var prompt As WakeEvent = basic.Events(0)
		  Assert.AreEqual(3500, prompt.TurnActiveMs, "turn_duration goes to the prompt")
		  Assert.AreEqual(1, prompt.TurnResponses)

		  Var tools As WakeSession = TestSupport.ParseClaudeFixture(2)
		  prompt = tools.Events(0)
		  Assert.AreEqual(6, prompt.TurnResponses)
		  Assert.AreEqual(17500, prompt.TurnUsage.Total.CacheReadTokens)

		  // A turn includes the subagents it started.
		  Var parent As WakeSession = TestSupport.ParseClaudeFixture(4)
		  Var total As WakeTokenUsage = parent.Events(0).TurnUsage.Total
		  Assert.AreEqual(135, total.InputTokens, "25 for the parent and 110 for the subagent")
		  Assert.AreEqual(2, parent.Events(0).TurnUsage.ByModel.KeyCount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UsageCountedOncePerMessageTest()
		  // Every record of a split response repeats the same usage; it must count once.
		  Var basic As WakeSession = TestSupport.ParseClaudeFixture(1)
		  Assert.AreEqual(100, basic.Usage.InputTokens)
		  Assert.AreEqual(50, basic.Usage.OutputTokens)
		  Assert.AreEqual(1000, basic.Usage.CacheWriteTokens)
		  Assert.AreEqual(2000, basic.Usage.CacheReadTokens)

		  Var tools As WakeSession = TestSupport.ParseClaudeFixture(2)
		  Assert.AreEqual(22, tools.Usage.InputTokens)
		  Assert.AreEqual(190, tools.Usage.OutputTokens)
		  Assert.AreEqual(700, tools.Usage.CacheWriteTokens)
		  Assert.AreEqual(17500, tools.Usage.CacheReadTokens)
		  Assert.AreEqual(1, tools.UsageByModel.KeyCount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteCreateTest()
		  Var s As WakeSession = TestSupport.ParseClaudeFixture(2)
		  Var e As WakeEvent = TestSupport.FindTool(s, "toolu_write_01")
		  Assert.IsNotNil(e)
		  If e Is Nil Then Return

		  Assert.IsTrue(e.Kind = WakeEvent.Kinds.FileEdit)
		  Assert.AreEqual("/Users/dev/demo/NOTES.md", e.FilePath)
		  Assert.AreEqual("+# Notes" + &u0A + "+" + &u0A + "+Quoted fields are now supported.", e.Patch)
		End Sub
	#tag EndMethod


End Class
#tag EndClass
