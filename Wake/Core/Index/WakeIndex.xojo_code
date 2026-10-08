#tag Class
Protected Class WakeIndex
	#tag Method, Flags = &h0
		Sub Close()
		  If mDB <> Nil Then mDB.Close
		  mDB = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(databaseFile As FolderItem)
		  // databaseFile Nil keeps the index in memory.
		  mFile = databaseFile
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CreateSchema()
		  // The index is a cache of the transcripts, so an index from another schema version is
		  // dropped and rebuilt instead of migrated.
		  Var version As Integer = 0
		  Var rs As RowSet = mDB.SelectSQL("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'meta'")
		  If Not rs.AfterLastRow Then
		    rs = mDB.SelectSQL("SELECT value FROM meta WHERE key = 'schema_version'")
		    If Not rs.AfterLastRow Then version = rs.Column("value").StringValue.ToInteger
		  End If

		  If version = kSchemaVersion Then Return

		  mDB.BeginTransaction
		  Try
		    For Each name As String In Array("events_fts", "events", "session_models", "sessions", "projects", "files", "meta")
		      mDB.ExecuteSQL("DROP TABLE IF EXISTS " + name)
		    Next

		    For Each statement As String In SchemaStatements
		      mDB.ExecuteSQL(statement)
		    Next

		    mDB.ExecuteSQL("INSERT INTO meta (key, value) VALUES ('schema_version', ?)", kSchemaVersion.ToString)
		    mDB.CommitTransaction
		  Catch err As DatabaseException
		    mDB.RollbackTransaction
		    Raise err
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Database() As SQLiteDatabase
		  // The open connection, for queries. Nil until Open succeeds.
		  Return mDB
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DatabaseFile() As FolderItem
		  Return mFile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IndexedFiles() As Dictionary
		  // Every indexed transcript, keyed by native path (case-sensitive) to a WakeIndexedFile.
		  Var result As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  Var rs As RowSet = mDB.SelectSQL("SELECT id, path, size, mtime_ms, related FROM files")

		  For Each row As DatabaseRow In rs
		    Var f As New WakeIndexedFile
		    f.ID = row.Column("id").IntegerValue
		    f.Path = row.Column("path").StringValue
		    f.Size = row.Column("size").Int64Value
		    f.ModifiedMs = row.Column("mtime_ms").Int64Value
		    f.RelatedSignature = row.Column("related").StringValue
		    result.Value(f.Path) = f
		  Next

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InsertEvents(sessionID As Integer, session As WakeSession)
		  For Each e As WakeEvent In session.Events
		    Var isError As Integer = If(e.ResultIsError Or e.Kind = WakeEvent.Kinds.Error, 1, 0)

		    mDB.ExecuteSQL("INSERT INTO events (session_id, seq, kind, timestamp, model, tool_name, " + _
		    "tool_use_id, file_path, summary, is_error, subagent_uid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
		    sessionID, e.Sequence, WakeEvent.KindName(e.Kind), TimeValue(e.Timestamp), e.Model, e.ToolName, _
		    e.ToolUseID, e.FilePath, e.Summary, isError, e.SubagentID)

		    Var body As String = SearchText(e)
		    If body <> "" Then
		      mDB.ExecuteSQL("INSERT INTO events_fts (rowid, body) VALUES (?, ?)", mDB.LastRowID, body)
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InsertSession(fileID As Integer, parentID As Variant, projectID As Integer, session As WakeSession)
		  Var total As WakeTokenUsage = session.TotalUsage
		  Var own As WakeTokenUsage = session.Usage

		  Var reportedCost As Variant
		  If session.HasAgentReportedCost Then reportedCost = session.AgentReportedCostUSD

		  Var uid As String = If(session.IsSubagent And session.SubagentID <> "", session.SubagentID, session.ID)

		  mDB.ExecuteSQL("INSERT INTO sessions (file_id, parent_id, project_id, agent, uid, title, first_prompt, " + _
		  "start_time, end_time, active_ms, prompt_count, event_count, command_only, git_branch, agent_version, " + _
		  "input_tokens, output_tokens, cache_write_tokens, cache_read_tokens, " + _
		  "total_input_tokens, total_output_tokens, total_cache_write_tokens, total_cache_read_tokens, " + _
		  "agent_cost_usd, partial, parse_note, subagent_type, subagent_description, parent_tool_use_id) " + _
		  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
		  fileID, parentID, projectID, session.AgentID, uid, session.Title, session.FirstPrompt, _
		  TimeValue(session.StartTime), TimeValue(session.EndTime), session.ActiveDurationMs, session.PromptCount, _
		  session.Events.Count, If(session.IsCommandOnly, 1, 0), session.GitBranch, session.AgentVersion, _
		  own.InputTokens, own.OutputTokens, own.CacheWriteTokens, own.CacheReadTokens, _
		  total.InputTokens, total.OutputTokens, total.CacheWriteTokens, total.CacheReadTokens, _
		  reportedCost, If(session.Report.IsPartial, 1, 0), session.Report.Summary, _
		  session.SubagentType, session.SubagentDescription, session.ParentToolUseID)

		  Var sessionID As Integer = mDB.LastRowID

		  For Each model As Variant In session.UsageByModel.Keys
		    Var usage As WakeTokenUsage = WakeTokenUsage(session.UsageByModel.Value(model).ObjectValue)
		    mDB.ExecuteSQL("INSERT INTO session_models (session_id, model, input_tokens, output_tokens, " + _
		    "cache_write_tokens, cache_read_tokens) VALUES (?, ?, ?, ?, ?, ?)", sessionID, model.StringValue, _
		    usage.InputTokens, usage.OutputTokens, usage.CacheWriteTokens, usage.CacheReadTokens)
		  Next

		  InsertEvents(sessionID, session)

		  For Each child As WakeSession In session.Subagents
		    InsertSession(fileID, sessionID, projectID, child)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Open()
		  // Opens the index, creating the file and schema when needed.
		  // Raises DatabaseException or IOException when that fails.
		  Close

		  Var db As New SQLiteDatabase

		  If mFile Is Nil Then
		    db.Connect
		  Else
		    Var folder As FolderItem = mFile.Parent
		    If folder <> Nil And Not folder.Exists Then folder.CreateFolder

		    db.DatabaseFile = mFile
		    If mFile.Exists Then
		      db.Connect
		    Else
		      db.CreateDatabase
		    End If

		    // WAL lets the browse UI read while the indexer thread writes on its own connection.
		    db.WriteAheadLogging = True
		  End If

		  db.Timeout = 10
		  db.ExecuteSQL("PRAGMA foreign_keys = ON")

		  mDB = db
		  CreateSchema
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ProjectID(agentID As String, path As String, isFallback As Boolean) As Integer
		  Var rs As RowSet = mDB.SelectSQL("SELECT id FROM projects WHERE agent = ? AND path = ?", agentID, path)
		  If Not rs.AfterLastRow Then Return rs.Column("id").IntegerValue

		  mDB.ExecuteSQL("INSERT INTO projects (agent, path, is_fallback) VALUES (?, ?, ?)", agentID, path, If(isFallback, 1, 0))
		  Return mDB.LastRowID
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveFile(fileID As Integer)
		  // Foreign keys cascade to the file's sessions and events, and a trigger clears the
		  // search rows of each deleted event.
		  mDB.BeginTransaction
		  Try
		    mDB.ExecuteSQL("DELETE FROM files WHERE id = ?", fileID)
		    mDB.CommitTransaction
		  Catch err As DatabaseException
		    mDB.RollbackTransaction
		    Raise err
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TidyProjects()
		  // A session with no working directory (an empty file, or only a slash command) gets
		  // a project named after its folder. Move it to the real project of the other sessions
		  // in the same folder, then drop projects left with no sessions.
		  Var sibling As String = "SELECT s2.project_id FROM sessions s2 JOIN files f2 ON f2.id = s2.file_id " + _
		  "JOIN projects p2 ON p2.id = s2.project_id WHERE p2.is_fallback = 0 AND p2.agent = sessions.agent " + _
		  "AND f2.folder = (SELECT folder FROM files WHERE id = sessions.file_id) LIMIT 1"

		  mDB.BeginTransaction
		  Try
		    mDB.ExecuteSQL("UPDATE sessions SET project_id = (" + sibling + ") " + _
		    "WHERE project_id IN (SELECT id FROM projects WHERE is_fallback = 1) AND EXISTS (" + sibling + ")")
		    mDB.ExecuteSQL("DELETE FROM projects WHERE id NOT IN (SELECT DISTINCT project_id FROM sessions)")
		    mDB.CommitTransaction
		  Catch err As DatabaseException
		    mDB.RollbackTransaction
		    Raise err
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SchemaStatements() As String()
		  // Times are seconds since 1970 (UTC) as REAL, or NULL when unknown. File modification
		  // times are whole milliseconds so they compare exactly.
		  Var s() As String

		  s.Add("CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT)")

		  s.Add("CREATE TABLE files (id INTEGER PRIMARY KEY, path TEXT NOT NULL UNIQUE, agent TEXT NOT NULL, " + _
		  "folder TEXT NOT NULL, size INTEGER NOT NULL, mtime_ms INTEGER NOT NULL, related TEXT NOT NULL DEFAULT '', " + _
		  "indexed_at REAL NOT NULL, file_error TEXT NOT NULL DEFAULT '', malformed_lines INTEGER NOT NULL DEFAULT 0, " + _
		  "unknown_records INTEGER NOT NULL DEFAULT 0, unknown_blocks INTEGER NOT NULL DEFAULT 0, " + _
		  "parse_note TEXT NOT NULL DEFAULT '')")

		  // is_fallback marks a project named after its folder because no session gave a path.
		  s.Add("CREATE TABLE projects (id INTEGER PRIMARY KEY, agent TEXT NOT NULL, path TEXT NOT NULL, " + _
		  "is_fallback INTEGER NOT NULL DEFAULT 0, UNIQUE (agent, path))")

		  s.Add("CREATE TABLE sessions (id INTEGER PRIMARY KEY, " + _
		  "file_id INTEGER NOT NULL REFERENCES files(id) ON DELETE CASCADE, " + _
		  "parent_id INTEGER REFERENCES sessions(id) ON DELETE CASCADE, " + _
		  "project_id INTEGER NOT NULL REFERENCES projects(id), " + _
		  "agent TEXT NOT NULL, uid TEXT NOT NULL, title TEXT NOT NULL DEFAULT '', first_prompt TEXT NOT NULL DEFAULT '', " + _
		  "start_time REAL, end_time REAL, active_ms INTEGER NOT NULL DEFAULT 0, " + _
		  "prompt_count INTEGER NOT NULL DEFAULT 0, event_count INTEGER NOT NULL DEFAULT 0, " + _
		  "command_only INTEGER NOT NULL DEFAULT 0, git_branch TEXT NOT NULL DEFAULT '', agent_version TEXT NOT NULL DEFAULT '', " + _
		  "input_tokens INTEGER NOT NULL DEFAULT 0, output_tokens INTEGER NOT NULL DEFAULT 0, " + _
		  "cache_write_tokens INTEGER NOT NULL DEFAULT 0, cache_read_tokens INTEGER NOT NULL DEFAULT 0, " + _
		  "total_input_tokens INTEGER NOT NULL DEFAULT 0, total_output_tokens INTEGER NOT NULL DEFAULT 0, " + _
		  "total_cache_write_tokens INTEGER NOT NULL DEFAULT 0, total_cache_read_tokens INTEGER NOT NULL DEFAULT 0, " + _
		  "agent_cost_usd REAL, partial INTEGER NOT NULL DEFAULT 0, parse_note TEXT NOT NULL DEFAULT '', " + _
		  "subagent_type TEXT NOT NULL DEFAULT '', subagent_description TEXT NOT NULL DEFAULT '', " + _
		  "parent_tool_use_id TEXT NOT NULL DEFAULT '')")
		  s.Add("CREATE INDEX sessions_file ON sessions (file_id)")
		  s.Add("CREATE INDEX sessions_parent ON sessions (parent_id)")
		  s.Add("CREATE INDEX sessions_project ON sessions (project_id, start_time)")

		  s.Add("CREATE TABLE session_models (session_id INTEGER NOT NULL REFERENCES sessions(id) ON DELETE CASCADE, " + _
		  "model TEXT NOT NULL, input_tokens INTEGER NOT NULL, output_tokens INTEGER NOT NULL, " + _
		  "cache_write_tokens INTEGER NOT NULL, cache_read_tokens INTEGER NOT NULL, PRIMARY KEY (session_id, model))")

		  s.Add("CREATE TABLE events (id INTEGER PRIMARY KEY, " + _
		  "session_id INTEGER NOT NULL REFERENCES sessions(id) ON DELETE CASCADE, seq INTEGER NOT NULL, " + _
		  "kind TEXT NOT NULL, timestamp REAL, model TEXT NOT NULL DEFAULT '', tool_name TEXT NOT NULL DEFAULT '', " + _
		  "tool_use_id TEXT NOT NULL DEFAULT '', file_path TEXT NOT NULL DEFAULT '', summary TEXT NOT NULL DEFAULT '', " + _
		  "is_error INTEGER NOT NULL DEFAULT 0, subagent_uid TEXT NOT NULL DEFAULT '')")
		  s.Add("CREATE INDEX events_session ON events (session_id, seq)")

		  // The rowid of each search row is the id of its event.
		  s.Add("CREATE VIRTUAL TABLE events_fts USING fts5(body, tokenize = 'unicode61 remove_diacritics 2')")
		  s.Add("CREATE TRIGGER events_fts_delete AFTER DELETE ON events BEGIN " + _
		  "DELETE FROM events_fts WHERE rowid = old.id; END")

		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SearchText(e As WakeEvent) As String
		  // What full-text search sees for an event. Persisted tool output is not read: it is
		  // loaded only on demand. Very long text is cut to keep the index small.
		  Var parts() As String

		  For Each piece As String In Array(e.Text, e.Command, e.FilePath, e.Patch, e.Stdout, e.Stderr)
		    If piece <> "" Then parts.Add(piece)
		  Next

		  // Shell commands and edits are already covered by Command and Patch.
		  If e.ToolInputJSON <> "" And e.Kind = WakeEvent.Kinds.ToolCall Then parts.Add(e.ToolInputJSON)

		  // For shell commands the result text repeats stdout.
		  If e.ResultText <> "" And e.Stdout = "" Then parts.Add(e.ResultText)

		  Var body As String = String.FromArray(parts, &u0A)
		  If body.Length > kMaxSearchTextLength Then body = body.Left(kMaxSearchTextLength)
		  Return body
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StoreSession(f As FolderItem, sizeBytes As Int64, modifiedMs As Int64, relatedSignature As String, session As WakeSession)
		  // Replaces everything indexed for f with session, in one transaction.
		  Var path As String = f.NativePath

		  Var folder As String = If(f.Parent Is Nil, "", f.Parent.NativePath)
		  Var projectPath As String = session.ProjectPath
		  Var isFallback As Boolean = projectPath = ""
		  If isFallback And f.Parent <> Nil Then projectPath = f.Parent.Name

		  Var report As WakeParseReport = session.Report

		  mDB.BeginTransaction
		  Try
		    mDB.ExecuteSQL("DELETE FROM files WHERE path = ?", path)

		    mDB.ExecuteSQL("INSERT INTO files (path, agent, folder, size, mtime_ms, related, indexed_at, file_error, " + _
		    "malformed_lines, unknown_records, unknown_blocks, parse_note) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
		    path, session.AgentID, folder, sizeBytes, modifiedMs, relatedSignature, DateTime.Now.SecondsFrom1970, _
		    report.FileError, report.MalformedLines, report.UnknownRecordCount, report.UnknownBlockCount, report.Summary)
		    Var fileID As Integer = mDB.LastRowID

		    InsertSession(fileID, Nil, ProjectID(session.AgentID, projectPath, isFallback), session)

		    mDB.CommitTransaction
		  Catch err As DatabaseException
		    mDB.RollbackTransaction
		    Raise err
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TimeValue(d As DateTime) As Variant
		  If d Is Nil Then Return Nil
		  Return d.SecondsFrom1970
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mDB As SQLiteDatabase
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFile As FolderItem
	#tag EndProperty


	#tag Constant, Name = kMaxSearchTextLength, Type = Double, Dynamic = False, Default = \"65536", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSchemaVersion, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant


End Class
#tag EndClass
