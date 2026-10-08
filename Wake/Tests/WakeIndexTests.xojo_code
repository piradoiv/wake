#tag Class
Protected Class WakeIndexTests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  // Every test works on its own scratch copy of the fixtures, never the originals.
		  mScratch = TestSupport.NewScratchFolder
		  TestSupport.CopyFolder(TestSupport.FixturesFolder("claude-code").Child("projects"), mScratch.Child("projects"))
		End Sub
	#tag EndEvent

	#tag Event
		Sub TearDown()
		  TestSupport.RemoveScratchFolder(mScratch)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub ChangedFileIsReindexedTest()
		  Var first As WakeIndexRunResult = RunIndexer
		  Assert.AreEqual(6, first.FilesIndexed)

		  TestSupport.AppendLine(ScratchSession(1), "{""type"": ""user"", ""message"": {""role"": ""user"", " + _
		  """content"": ""And the tests?""}, ""uuid"": ""00000010-1111-4000-8000-0000000000ff"", " + _
		  """timestamp"": ""2026-09-01T10:05:00.000Z"", ""cwd"": ""/Users/dev/demo"", " + _
		  """sessionId"": """ + TestSupport.ClaudeFixtureID(1) + """}")

		  Var second As WakeIndexRunResult = RunIndexer
		  Assert.AreEqual(1, second.FilesIndexed, second.Summary)
		  Assert.AreEqual(5, second.FilesSkipped, second.Summary)
		  Assert.AreEqual(2, QueryInteger("SELECT prompt_count FROM sessions WHERE uid = '" + TestSupport.ClaudeFixtureID(1) + "'"))
		  Assert.AreEqual(1, QueryInteger("SELECT count(*) FROM sessions WHERE uid = '" + TestSupport.ClaudeFixtureID(1) + "'"), "no duplicate rows")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CustomRootsRoundTripTest()
		  Var roots() As WakeIndexRoot
		  roots.Add(New WakeIndexRoot("claude-code", mScratch.Child("projects"), True))
		  roots.Add(New WakeIndexRoot("claude-code", mScratch, False))

		  Var f As FolderItem = mScratch.Child("folders.json")
		  WakeFolders.SaveCustomRoots(f, roots)

		  Var loaded() As WakeIndexRoot = WakeFolders.LoadCustomRoots(f)
		  Var loadedCount As Integer = loaded.Count
		  Assert.AreEqual(1, loadedCount, "only custom roots are saved")
		  If loadedCount <> 1 Then Return

		  Assert.AreEqual("claude-code", loaded(0).AgentID)
		  Assert.AreEqual(mScratch.Child("projects").NativePath, loaded(0).Folder.NativePath)
		  Assert.IsTrue(loaded(0).IsCustom)

		  Var missingCount As Integer = WakeFolders.LoadCustomRoots(mScratch.Child("missing.json")).Count
		  Assert.AreEqual(0, missingCount, "missing file")

		  Var broken As FolderItem = mScratch.Child("broken.json")
		  TestSupport.AppendLine(broken, "[{""agent"": ")
		  Var brokenCount As Integer = WakeFolders.LoadCustomRoots(broken).Count
		  Assert.AreEqual(0, brokenCount, "malformed JSON")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeletedFileIsRemovedTest()
		  Call RunIndexer
		  Assert.AreEqual(2, QueryInteger("SELECT count(*) FROM projects"))

		  ScratchSession(2).Remove
		  ScratchSession(6, "-Users-dev-Open-Source-demo-app").Remove

		  Var result As WakeIndexRunResult = RunIndexer
		  Assert.AreEqual(4, result.FilesFound, result.Summary)
		  Assert.AreEqual(2, result.FilesRemoved, result.Summary)
		  Assert.AreEqual(4, result.FilesSkipped, result.Summary)

		  Assert.AreEqual(0, QueryInteger("SELECT count(*) FROM sessions WHERE uid = '" + TestSupport.ClaudeFixtureID(2) + "'"))
		  Assert.AreEqual(1, QueryInteger("SELECT count(*) FROM projects"), "project with no sessions left is removed")
		  Assert.AreEqual(0, QueryInteger("SELECT count(*) FROM events WHERE session_id NOT IN (SELECT id FROM sessions)"), "orphan events")
		  Assert.AreEqual(0, QueryInteger("SELECT count(*) FROM events_fts WHERE rowid NOT IN (SELECT id FROM events)"), "orphan search rows")
		  Assert.AreEqual(0, QueryInteger("SELECT count(*) FROM events_fts WHERE events_fts MATCH 'verbose'"), "deleted session no longer found")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FirstRunIndexesEverythingTest()
		  Var result As WakeIndexRunResult = RunIndexer
		  Var errors As String = String.FromArray(result.Errors, "; ")

		  Assert.AreEqual(6, result.FilesFound, "memory/ and subagent files are not sessions")
		  Assert.AreEqual(6, result.FilesIndexed, errors)
		  Assert.AreEqual(0, result.FilesFailed, errors)
		  Assert.AreEqual(0, result.FilesRemoved)

		  Assert.AreEqual(6, QueryInteger("SELECT count(*) FROM files"))
		  Assert.AreEqual(6, QueryInteger("SELECT count(*) FROM sessions WHERE parent_id IS NULL"))
		  Assert.AreEqual(1, QueryInteger("SELECT count(*) FROM sessions WHERE parent_id IS NOT NULL"), "one subagent")
		  Assert.AreEqual(2, QueryInteger("SELECT count(*) FROM projects"))
		  Assert.AreEqual(QueryInteger("SELECT sum(event_count) FROM sessions"), QueryInteger("SELECT count(*) FROM events"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SearchFindsEventsTest()
		  Call RunIndexer

		  Var sql As String = "SELECT sessions.uid AS v FROM events_fts JOIN events ON events.id = events_fts.rowid " + _
		  "JOIN sessions ON sessions.id = events.session_id WHERE events_fts MATCH "

		  Assert.AreEqual(TestSupport.ClaudeFixtureID(2), QueryString(sql + "'verbose'"), "shell command")
		  // The parent's Agent tool result repeats the subagent's answer, so both match.
		  Var subagentMatches As Integer = QueryInteger("SELECT count(*) FROM events_fts JOIN events ON events.id = events_fts.rowid " + _
		  "JOIN sessions ON sessions.id = events.session_id WHERE events_fts MATCH 'todos' AND sessions.uid = 'a0fixture000001'")
		  Assert.IsTrue(subagentMatches > 0, "subagent text")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SessionRowsTest()
		  Call RunIndexer

		  Var where2 As String = " FROM sessions WHERE uid = '" + TestSupport.ClaudeFixtureID(2) + "'"
		  Assert.AreEqual("Fix failing CSV quoting test", QueryString("SELECT title AS v" + where2))
		  Assert.AreEqual("feature/csv", QueryString("SELECT git_branch AS v" + where2))
		  Assert.AreEqual(22, QueryInteger("SELECT total_input_tokens" + where2))
		  Assert.AreEqual(1, QueryInteger("SELECT agent_cost_usd IS NOT NULL" + where2), "cost reported by agent")

		  // Subagent tokens are kept on the subagent and rolled up into the parent's totals.
		  Var where4 As String = " FROM sessions WHERE uid = '" + TestSupport.ClaudeFixtureID(4) + "'"
		  Assert.AreEqual(25, QueryInteger("SELECT input_tokens" + where4))
		  Assert.AreEqual(135, QueryInteger("SELECT total_input_tokens" + where4))
		  Assert.AreEqual(75, QueryInteger("SELECT total_output_tokens" + where4))
		  Assert.AreEqual(100, QueryInteger("SELECT total_cache_write_tokens" + where4))
		  Assert.AreEqual(400, QueryInteger("SELECT total_cache_read_tokens" + where4))
		  Assert.AreEqual(110, QueryInteger("SELECT s.input_tokens FROM sessions s JOIN sessions p ON s.parent_id = p.id " + _
		  "WHERE p.uid = '" + TestSupport.ClaudeFixtureID(4) + "'"))
		  Assert.AreEqual("claude-haiku-4-5-20251001", QueryString("SELECT m.model AS v FROM session_models m " + _
		  "JOIN sessions s ON s.id = m.session_id WHERE s.uid = 'a0fixture000001'"))

		  Assert.AreEqual(1, QueryInteger("SELECT partial FROM sessions WHERE uid = '" + TestSupport.ClaudeFixtureID(3) + "'"))
		  Assert.AreEqual(1, QueryInteger("SELECT command_only FROM sessions WHERE uid = '" + TestSupport.ClaudeFixtureID(5) + "'"), "empty session")
		  Assert.AreEqual("/Users/dev/demo", QueryString("SELECT p.path AS v FROM projects p JOIN sessions s ON s.project_id = p.id " + _
		  "WHERE s.uid = '" + TestSupport.ClaudeFixtureID(5) + "'"), "a session with no cwd joins its folder's project")
		  Assert.AreEqual(0, QueryInteger("SELECT command_only FROM sessions WHERE uid = '" + TestSupport.ClaudeFixtureID(1) + "'"))

		  Assert.AreEqual("/Users/dev/Open Source/demo.app", QueryString("SELECT p.path AS v FROM projects p " + _
		  "JOIN sessions s ON s.project_id = p.id WHERE s.uid = '" + TestSupport.ClaudeFixtureID(6) + "'"))

		  Var start As DateTime = WakeCore.ParseISO8601("2026-09-01T10:00:00.000Z")
		  Assert.AreEqual(start.SecondsFrom1970, QueryDouble("SELECT start_time" + " FROM sessions WHERE uid = '" + TestSupport.ClaudeFixtureID(1) + "'"), 0.001)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SubagentChangeReindexesParentTest()
		  Call RunIndexer

		  Var subagent As FolderItem = mScratch.Child("projects").Child("-Users-dev-demo").Child(TestSupport.ClaudeFixtureID(4)) _
		  .Child("subagents").Child("agent-a0fixture000001.jsonl")
		  TestSupport.AppendLine(subagent, "{""type"": ""future-record-kind""}")

		  Var result As WakeIndexRunResult = RunIndexer
		  Assert.AreEqual(1, result.FilesIndexed, result.Summary)
		  Assert.AreEqual(1, QueryInteger("SELECT count(*) FROM sessions WHERE parent_id IS NOT NULL"), "still one subagent")
		  Assert.AreEqual(1, QueryInteger("SELECT partial FROM sessions WHERE uid = 'a0fixture000001'"), "unknown record counted")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ThreadIndexesInBackgroundTest()
		  Var roots() As WakeIndexRoot
		  roots.Add(New WakeIndexRoot("claude-code", mScratch.Child("projects")))

		  mThread = New WakeIndexThread(mScratch.Child("index.sqlite"), roots)
		  AddHandler mThread.Progress, AddressOf Thread_Progress
		  AddHandler mThread.Finished, AddressOf Thread_Finished
		  AddHandler mThread.Failed, AddressOf Thread_Failed

		  AsyncAwait(30)
		  mThread.Start
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UnchangedFilesAreSkippedTest()
		  Call RunIndexer
		  Var eventCount As Integer = QueryInteger("SELECT count(*) FROM events")

		  Var result As WakeIndexRunResult = RunIndexer
		  Assert.AreEqual(0, result.FilesIndexed, result.Summary)
		  Assert.AreEqual(6, result.FilesSkipped, result.Summary)
		  Assert.AreEqual(0, result.FilesRemoved, result.Summary)
		  Assert.AreEqual(eventCount, QueryInteger("SELECT count(*) FROM events"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function OpenIndex() As WakeIndex
		  Var index As New WakeIndex(mScratch.Child("index.sqlite"))
		  index.Open
		  Return index
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function QueryDouble(sql As String) As Double
		  Var index As WakeIndex = OpenIndex
		  Var rs As RowSet = index.Database.SelectSQL(sql)
		  Var value As Double = If(rs.AfterLastRow, -1.0, rs.ColumnAt(0).DoubleValue)
		  index.Close
		  Return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function QueryInteger(sql As String) As Integer
		  Var index As WakeIndex = OpenIndex
		  Var rs As RowSet = index.Database.SelectSQL(sql)
		  Var value As Integer = If(rs.AfterLastRow, -1, rs.ColumnAt(0).IntegerValue)
		  index.Close
		  Return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function QueryString(sql As String) As String
		  Var index As WakeIndex = OpenIndex
		  Var rs As RowSet = index.Database.SelectSQL(sql)
		  Var value As String = If(rs.AfterLastRow, "(no row)", rs.ColumnAt(0).StringValue)
		  index.Close
		  Return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ReleaseThread()
		  // The handlers point back at this test, so the test would never be released (and its
		  // scratch folder never removed) while they are attached.
		  If mThread Is Nil Then Return
		  RemoveHandler mThread.Progress, AddressOf Thread_Progress
		  RemoveHandler mThread.Finished, AddressOf Thread_Finished
		  RemoveHandler mThread.Failed, AddressOf Thread_Failed
		  mThread = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunIndexer() As WakeIndexRunResult
		  Var index As WakeIndex = OpenIndex
		  Var indexer As New WakeIndexer(index)
		  indexer.AddRoot(New WakeIndexRoot("claude-code", mScratch.Child("projects")))

		  Var result As WakeIndexRunResult = indexer.Run
		  index.Close
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ScratchSession(sessionNumber As Integer, projectFolder As String = "-Users-dev-demo") As FolderItem
		  Return mScratch.Child("projects").Child(projectFolder).Child(TestSupport.ClaudeFixtureID(sessionNumber) + ".jsonl")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Thread_Failed(sender As WakeIndexThread, message As String)
		  #Pragma Unused sender
		  Assert.Fail(message)
		  ReleaseThread
		  AsyncComplete
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Thread_Finished(sender As WakeIndexThread, result As WakeIndexRunResult)
		  #Pragma Unused sender
		  Assert.AreEqual(6, result.FilesIndexed, result.Summary)
		  Assert.IsTrue(mProgressUpdates > 0, "progress was reported")
		  Assert.AreEqual(6, QueryInteger("SELECT count(*) FROM sessions WHERE parent_id IS NULL"))
		  ReleaseThread
		  AsyncComplete
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Thread_Progress(sender As WakeIndexThread, done As Integer, total As Integer, currentPath As String)
		  #Pragma Unused sender
		  #Pragma Unused done
		  #Pragma Unused total
		  #Pragma Unused currentPath
		  mProgressUpdates = mProgressUpdates + 1
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mProgressUpdates As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScratch As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mThread As WakeIndexThread
	#tag EndProperty


End Class
#tag EndClass
