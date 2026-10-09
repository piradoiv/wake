#tag Class
Protected Class WakeCatalog
	#tag Method, Flags = &h0
		Sub Constructor(index As WakeIndex)
		  // Read-only queries for browsing. index must be open, on the caller's own connection.
		  mIndex = index
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Models() As String()
		  // Every model that has used tokens in any session, by name. Raises DatabaseException.
		  Var result() As String
		  Var rs As RowSet = mIndex.Database.SelectSQL("SELECT DISTINCT model FROM session_models " + _
		  "WHERE model <> '' ORDER BY model")
		  For Each row As DatabaseRow In rs
		    result.Add(row.Column("model").StringValue)
		  Next
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Projects(includeCommandOnly As Boolean = False) As WakeProjectInfo()
		  // Every project with at least one session to show, most recently active first.
		  // Raises DatabaseException.
		  Var result() As WakeProjectInfo
		  
		  Var sql As String = "SELECT p.id, p.agent, p.path, count(s.id) AS session_count, " + _
		  "max(coalesce(s.end_time, s.start_time)) AS last_time FROM projects p " + _
		  "JOIN sessions s ON s.project_id = p.id AND s.parent_id IS NULL"
		  If Not includeCommandOnly Then sql = sql + " AND s.command_only = 0"
		  sql = sql + " GROUP BY p.id ORDER BY last_time IS NULL, last_time DESC, p.path"
		  
		  Var rs As RowSet = mIndex.Database.SelectSQL(sql)
		  For Each row As DatabaseRow In rs
		    Var p As New WakeProjectInfo
		    p.ID = row.Column("id").IntegerValue
		    p.AgentID = row.Column("agent").StringValue
		    p.Path = row.Column("path").StringValue
		    p.SessionCount = row.Column("session_count").IntegerValue
		    p.LastActivity = TimeFrom(row.Column("last_time"))
		    result.Add(p)
		  Next
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReadSessions(where As String, values() As Variant, order As String) As WakeSessionInfo()
		  Var sql As String = "SELECT s.*, p.path AS project_path, f.path AS file_path, " + _
		  "(SELECT count(*) FROM sessions c WHERE c.parent_id = s.id) AS subagent_count " + _
		  "FROM sessions s JOIN projects p ON p.id = s.project_id JOIN files f ON f.id = s.file_id " + _
		  "WHERE " + where + " ORDER BY " + order
		  
		  Var rs As RowSet = mIndex.Database.SelectSQL(sql, values)
		  Var result() As WakeSessionInfo
		  
		  For Each row As DatabaseRow In rs
		    Var s As New WakeSessionInfo
		    s.ID = row.Column("id").IntegerValue
		    s.ParentID = If(row.Column("parent_id").Value.IsNull, 0, row.Column("parent_id").IntegerValue)
		    s.ProjectID = row.Column("project_id").IntegerValue
		    s.ProjectPath = row.Column("project_path").StringValue
		    s.FilePath = row.Column("file_path").StringValue
		    s.AgentID = row.Column("agent").StringValue
		    s.UID = row.Column("uid").StringValue
		    s.Title = row.Column("title").StringValue
		    s.FirstPrompt = row.Column("first_prompt").StringValue
		    s.StartTime = TimeFrom(row.Column("start_time"))
		    s.EndTime = TimeFrom(row.Column("end_time"))
		    s.ActiveMs = row.Column("active_ms").Int64Value
		    s.PromptCount = row.Column("prompt_count").IntegerValue
		    s.EventCount = row.Column("event_count").IntegerValue
		    s.IsCommandOnly = row.Column("command_only").BooleanValue
		    s.GitBranch = row.Column("git_branch").StringValue
		    s.AgentVersion = row.Column("agent_version").StringValue
		    s.IsPartial = row.Column("partial").BooleanValue
		    s.ParseNote = row.Column("parse_note").StringValue
		    s.SubagentType = row.Column("subagent_type").StringValue
		    s.SubagentDescription = row.Column("subagent_description").StringValue
		    s.SubagentCount = row.Column("subagent_count").IntegerValue
		    
		    s.HasAgentCost = Not row.Column("agent_cost_usd").Value.IsNull
		    If s.HasAgentCost Then s.AgentCostUSD = row.Column("agent_cost_usd").DoubleValue
		    
		    s.OwnUsage = UsageFrom(row)
		    s.TotalUsage = UsageFrom(row, "total_")
		    
		    result.Add(s)
		  Next
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Search(query As WakeSearchQuery) As WakeSearchHit()
		  // Events that match query.Text, best matches first, at most query.Limit of them. Each hit
		  // carries its top-level session, also when the event belongs to a subagent.
		  // Raises DatabaseException.
		  Var result() As WakeSearchHit
		  Var match As String = query.MatchExpression
		  If match = "" Then Return result
		  
		  Var clauses() As String
		  Var values() As Variant
		  values.Add(WakeSearchHit.MatchStart)
		  values.Add(WakeSearchHit.MatchEnd)
		  values.Add(WakeFormat.kEllipsis)
		  clauses.Add("events_fts MATCH ?")
		  values.Add(match)
		  
		  If query.AgentID <> "" Then
		    clauses.Add("ts.agent = ?")
		    values.Add(query.AgentID)
		  End If
		  
		  If query.ProjectID <> 0 Then
		    clauses.Add("ts.project_id = ?")
		    values.Add(query.ProjectID)
		  End If
		  
		  If Not query.IncludeCommandOnly Then clauses.Add("ts.command_only = 0")
		  
		  If query.FromTime <> Nil Then
		    clauses.Add("coalesce(e.timestamp, es.start_time) >= ?")
		    values.Add(query.FromTime.SecondsFrom1970)
		  End If
		  
		  If query.ToTime <> Nil Then
		    clauses.Add("coalesce(e.timestamp, es.start_time) < ?")
		    values.Add(query.ToTime.SecondsFrom1970)
		  End If
		  
		  If query.Kinds.Count > 0 Then
		    Var marks() As String
		    For Each kind As String In query.Kinds
		      marks.Add("?")
		      values.Add(kind)
		    Next
		    clauses.Add("e.kind IN (" + String.FromArray(marks, ", ") + ")")
		  End If
		  
		  Var limit As Integer = If(query.Limit > 0, query.Limit, 1)
		  values.Add(limit)
		  
		  // Subagents are one level deep, so an event's top-level session is its session's parent,
		  // or that session itself.
		  Var sql As String = "SELECT e.id, e.seq, e.kind, e.timestamp, e.tool_name, e.file_path, " + _
		  "es.uid AS event_uid, es.parent_id IS NOT NULL AS in_subagent, ts.id AS top_id, " + _
		  "snippet(events_fts, 0, ?, ?, ?, 16) AS snippet " + _
		  "FROM events_fts JOIN events e ON e.id = events_fts.rowid " + _
		  "JOIN sessions es ON es.id = e.session_id " + _
		  "JOIN sessions ts ON ts.id = coalesce(es.parent_id, es.id) " + _
		  "WHERE " + String.FromArray(clauses, " AND ") + " ORDER BY rank, e.id LIMIT ?"
		  
		  Var rs As RowSet = mIndex.Database.SelectSQL(sql, values)
		  Var topIDs() As Integer
		  Var topIDMarks() As String
		  Var sessionValues() As Variant
		  
		  For Each row As DatabaseRow In rs
		    Var hit As New WakeSearchHit
		    hit.EventID = row.Column("id").IntegerValue
		    hit.Sequence = row.Column("seq").IntegerValue
		    hit.Kind = row.Column("kind").StringValue
		    hit.Timestamp = TimeFrom(row.Column("timestamp"))
		    hit.ToolName = row.Column("tool_name").StringValue
		    hit.FilePath = row.Column("file_path").StringValue
		    hit.EventSessionUID = row.Column("event_uid").StringValue
		    hit.InSubagent = row.Column("in_subagent").BooleanValue
		    hit.Snippet = row.Column("snippet").StringValue
		    
		    // Session is filled in below, once per session. Until then it holds only the id.
		    Var topID As Integer = row.Column("top_id").IntegerValue
		    hit.Session = New WakeSessionInfo
		    hit.Session.ID = topID
		    If topIDs.IndexOf(topID) < 0 Then
		      topIDs.Add(topID)
		      topIDMarks.Add("?")
		      sessionValues.Add(topID)
		    End If
		    
		    result.Add(hit)
		  Next
		  
		  If topIDs.Count = 0 Then Return result
		  
		  Var sessions As New Dictionary
		  For Each s As WakeSessionInfo In ReadSessions("s.id IN (" + String.FromArray(topIDMarks, ", ") + ")", sessionValues, "s.id")
		    sessions.Value(s.ID) = s
		  Next
		  
		  For Each hit As WakeSearchHit In result
		    hit.Session = WakeSessionInfo(sessions.Lookup(hit.Session.ID, hit.Session).ObjectValue)
		  Next
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Session(sessionID As Integer) As WakeSessionInfo
		  // One session or subagent with its per-model usage, or Nil if it is no longer indexed.
		  // Raises DatabaseException.
		  Var values() As Variant
		  values.Add(sessionID)
		  
		  Var found() As WakeSessionInfo = ReadSessions("s.id = ?", values, "s.id")
		  If found.Count = 0 Then Return Nil
		  
		  Var s As WakeSessionInfo = found(0)
		  Var rs As RowSet = mIndex.Database.SelectSQL("SELECT * FROM session_models WHERE session_id = ? " + _
		  "ORDER BY input_tokens + output_tokens + cache_write_tokens + cache_read_tokens DESC, model", sessionID)
		  
		  For Each row As DatabaseRow In rs
		    s.Models.Add(row.Column("model").StringValue : UsageFrom(row))
		  Next
		  
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Sessions(agentID As String, projectID As Integer, includeCommandOnly As Boolean = False) As WakeSessionInfo()
		  // Top-level sessions, newest first. An empty agentID means every agent, and projectID 0
		  // means every project. Raises DatabaseException.
		  Var clauses() As String
		  Var values() As Variant
		  clauses.Add("s.parent_id IS NULL")
		  
		  If agentID <> "" Then
		    clauses.Add("s.agent = ?")
		    values.Add(agentID)
		  End If
		  
		  If projectID <> 0 Then
		    clauses.Add("s.project_id = ?")
		    values.Add(projectID)
		  End If
		  
		  If Not includeCommandOnly Then clauses.Add("s.command_only = 0")
		  
		  Return ReadSessions(String.FromArray(clauses, " AND "), values, "s.start_time IS NULL, s.start_time DESC, s.id DESC")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SessionUsage(sessionID As Integer) As WakeUsageGroup
		  // A session's usage per model, its subagents included. Raises DatabaseException.
		  Var result As New WakeUsageGroup
		  result.Key = sessionID.ToString
		  
		  Var rs As RowSet = mIndex.Database.SelectSQL("SELECT m.model, sum(m.input_tokens) AS input_tokens, " + _
		  "sum(m.output_tokens) AS output_tokens, sum(m.cache_write_tokens) AS cache_write_tokens, " + _
		  "sum(m.cache_write_1h_tokens) AS cache_write_1h_tokens, sum(m.cache_read_tokens) AS cache_read_tokens " + _
		  "FROM session_models m JOIN sessions s ON s.id = m.session_id " + _
		  "WHERE s.id = ? OR s.parent_id = ? GROUP BY m.model", sessionID, sessionID)
		  
		  For Each row As DatabaseRow In rs
		    result.Add(row.Column("model").StringValue, UsageFrom(row))
		  Next
		  
		  result.SessionCount = 1
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Subagents(sessionID As Integer) As WakeSessionInfo()
		  // The subagents a session started, in the order they began. Raises DatabaseException.
		  Var values() As Variant
		  values.Add(sessionID)
		  Return ReadSessions("s.parent_id = ?", values, "s.start_time IS NULL, s.start_time, s.id")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TimeFrom(column As DatabaseColumn) As DateTime
		  // Index times are seconds since 1970 (UTC), or NULL when unknown.
		  If column Is Nil Or column.Value.IsNull Then Return Nil
		  Return New DateTime(column.DoubleValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToolUsage(grouping As ToolGroupings, fromTime As DateTime = Nil) As WakeToolUsageGroup()
		  // Estimated tokens per tool, tool and file type, shell command or file, from tool calls
		  // made from fromTime on, with the most tokens (added plus re-read) first. Each group is
		  // split by model so it can be priced. Raises DatabaseException.
		  Var keyExpression As String
		  Var clauses() As String
		  Var values() As Variant
		  
		  Select Case grouping
		  Case ToolGroupings.Tool
		    keyExpression = "t.tool"
		  Case ToolGroupings.ToolAndFileType
		    keyExpression = "CASE WHEN t.file_type = '' THEN t.tool ELSE t.tool || ' ' || t.file_type END"
		  Case ToolGroupings.Command
		    keyExpression = "t.command"
		    clauses.Add("t.command <> ''")
		  Case ToolGroupings.File
		    keyExpression = "t.target"
		    clauses.Add("t.target <> ''")
		  End Select
		  clauses.Add("1 = 1")
		  
		  If fromTime <> Nil Then
		    clauses.Add("coalesce(t.timestamp, us.start_time) >= ?")
		    values.Add(fromTime.SecondsFrom1970)
		  End If
		  
		  // Subagent calls count toward the session that started the subagent.
		  Var source As String = " FROM tool_usage t JOIN sessions us ON us.id = t.session_id " + _
		  "JOIN sessions ts ON ts.id = coalesce(us.parent_id, us.id) WHERE " + String.FromArray(clauses, " AND ")
		  
		  Var groups() As WakeToolUsageGroup
		  Var byKey As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  
		  Var rs As RowSet = mIndex.Database.SelectSQL("SELECT " + keyExpression + " AS group_key, " + _
		  "sum(t.is_first) AS calls, sum(t.added_tokens) AS added, sum(t.carried_tokens) AS carried, " + _
		  "count(DISTINCT ts.id) AS session_count" + source + _
		  " GROUP BY group_key ORDER BY sum(t.added_tokens + t.carried_tokens) DESC, calls DESC, group_key", values)
		  
		  For Each row As DatabaseRow In rs
		    Var g As New WakeToolUsageGroup
		    g.Key = row.Column("group_key").StringValue
		    g.Label = g.Key
		    g.Calls = row.Column("calls").IntegerValue
		    g.AddedTokens = row.Column("added").Int64Value
		    g.CarriedTokens = row.Column("carried").Int64Value
		    g.SessionCount = row.Column("session_count").IntegerValue
		    groups.Add(g)
		    byKey.Value(g.Key) = g
		  Next
		  
		  rs = mIndex.Database.SelectSQL("SELECT " + keyExpression + " AS group_key, t.model AS model, " + _
		  "sum(t.input_tokens) AS input_tokens, 0 AS output_tokens, sum(t.cache_write_tokens) AS cache_write_tokens, " + _
		  "sum(t.cache_write_1h_tokens) AS cache_write_1h_tokens, sum(t.cache_read_tokens) AS cache_read_tokens" + _
		  source + " AND t.model <> '' GROUP BY group_key, t.model", values)
		  
		  For Each row As DatabaseRow In rs
		    Var g As WakeToolUsageGroup = WakeToolUsageGroup(byKey.Lookup(row.Column("group_key").StringValue, Nil).ObjectValue)
		    If g <> Nil Then g.Add(row.Column("model").StringValue, UsageFrom(row))
		  Next
		  
		  Return groups
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Usage(grouping As UsageGroupings, fromTime As DateTime = Nil, agentID As String = "", projectID As Integer = 0) As WakeUsageGroup()
		  // Token usage per day, project, model or top-level session, split by model so it can be
		  // priced. Subagent usage counts toward the session that started it. fromTime limits it to
		  // responses from then on. An empty agentID means every agent, and projectID 0 every
		  // project. Days are calendar days in the local time zone, newest first; other groups come
		  // with the most tokens first. Raises DatabaseException.
		  Var keyExpression, labelExpression, order As String
		  Select Case grouping
		  Case UsageGroupings.Day
		    keyExpression = "date(coalesce(u.timestamp, us.start_time, ts.start_time), 'unixepoch', 'localtime')"
		    labelExpression = keyExpression
		    order = "group_key IS NULL, group_key DESC"
		  Case UsageGroupings.Project
		    keyExpression = "ts.project_id"
		    labelExpression = "p.path"
		  Case UsageGroupings.Model
		    keyExpression = "u.model"
		    labelExpression = "u.model"
		  Case UsageGroupings.Session
		    keyExpression = "ts.id"
		    labelExpression = "ts.uid"
		  End Select
		  If order = "" Then order = "tokens DESC, group_label"
		  
		  Var clauses() As String
		  Var values() As Variant
		  clauses.Add("1 = 1")
		  
		  If agentID <> "" Then
		    clauses.Add("ts.agent = ?")
		    values.Add(agentID)
		  End If
		  
		  If projectID <> 0 Then
		    clauses.Add("ts.project_id = ?")
		    values.Add(projectID)
		  End If
		  
		  If fromTime <> Nil Then
		    clauses.Add("coalesce(u.timestamp, us.start_time, ts.start_time) >= ?")
		    values.Add(fromTime.SecondsFrom1970)
		  End If
		  
		  // Subagents are one level deep, so a response's top-level session is its session's
		  // parent, or that session itself.
		  Var source As String = " FROM usage u JOIN sessions us ON us.id = u.session_id " + _
		  "JOIN sessions ts ON ts.id = coalesce(us.parent_id, us.id) JOIN projects p ON p.id = ts.project_id " + _
		  "WHERE " + String.FromArray(clauses, " AND ")
		  
		  Var groups() As WakeUsageGroup
		  Var byKey As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  
		  Var rs As RowSet = mIndex.Database.SelectSQL("SELECT " + keyExpression + " AS group_key, " + _
		  "min(" + labelExpression + ") AS group_label, min(ts.agent) AS agent, count(DISTINCT ts.id) AS session_count, " + _
		  "sum(u.input_tokens + u.output_tokens + u.cache_write_tokens + u.cache_read_tokens) AS tokens" + _
		  source + " GROUP BY group_key ORDER BY " + order, values)
		  
		  For Each row As DatabaseRow In rs
		    Var g As New WakeUsageGroup
		    g.Key = row.Column("group_key").StringValue
		    g.Label = row.Column("group_label").StringValue
		    g.AgentID = row.Column("agent").StringValue
		    g.SessionCount = row.Column("session_count").IntegerValue
		    groups.Add(g)
		    byKey.Value(g.Key) = g
		  Next
		  
		  rs = mIndex.Database.SelectSQL("SELECT " + keyExpression + " AS group_key, u.model AS model, " + _
		  "sum(u.input_tokens) AS input_tokens, sum(u.output_tokens) AS output_tokens, " + _
		  "sum(u.cache_write_tokens) AS cache_write_tokens, sum(u.cache_write_1h_tokens) AS cache_write_1h_tokens, " + _
		  "sum(u.cache_read_tokens) AS cache_read_tokens" + source + " GROUP BY group_key, u.model", values)
		  
		  For Each row As DatabaseRow In rs
		    Var g As WakeUsageGroup = WakeUsageGroup(byKey.Lookup(row.Column("group_key").StringValue, Nil).ObjectValue)
		    If g <> Nil Then g.Add(row.Column("model").StringValue, UsageFrom(row))
		  Next
		  
		  Return groups
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function UsageFrom(row As DatabaseRow, prefix As String = "") As WakeTokenUsage
		  // Token counts from columns named like input_tokens, each with an optional prefix.
		  Var result As New WakeTokenUsage
		  result.InputTokens = row.Column(prefix + "input_tokens").Int64Value
		  result.OutputTokens = row.Column(prefix + "output_tokens").Int64Value
		  result.CacheWriteTokens = row.Column(prefix + "cache_write_tokens").Int64Value
		  result.CacheWrite1hTokens = row.Column(prefix + "cache_write_1h_tokens").Int64Value
		  result.CacheReadTokens = row.Column(prefix + "cache_read_tokens").Int64Value
		  Return result
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mIndex As WakeIndex
	#tag EndProperty


	#tag Enum, Name = ToolGroupings, Type = Integer, Flags = &h0
		Tool
		  ToolAndFileType
		  Command
		File
	#tag EndEnum

	#tag Enum, Name = UsageGroupings, Type = Integer, Flags = &h0
		Day
		  Project
		  Model
		Session
	#tag EndEnum


End Class
#tag EndClass
