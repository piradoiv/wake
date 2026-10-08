#tag Class
Protected Class WakeCatalog
	#tag Method, Flags = &h0
		Sub Constructor(index As WakeIndex)
		  // Read-only queries for browsing. index must be open, on the caller's own connection.
		  mIndex = index
		End Sub
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

		    s.OwnUsage = New WakeTokenUsage
		    s.OwnUsage.InputTokens = row.Column("input_tokens").Int64Value
		    s.OwnUsage.OutputTokens = row.Column("output_tokens").Int64Value
		    s.OwnUsage.CacheWriteTokens = row.Column("cache_write_tokens").Int64Value
		    s.OwnUsage.CacheReadTokens = row.Column("cache_read_tokens").Int64Value

		    s.TotalUsage = New WakeTokenUsage
		    s.TotalUsage.InputTokens = row.Column("total_input_tokens").Int64Value
		    s.TotalUsage.OutputTokens = row.Column("total_output_tokens").Int64Value
		    s.TotalUsage.CacheWriteTokens = row.Column("total_cache_write_tokens").Int64Value
		    s.TotalUsage.CacheReadTokens = row.Column("total_cache_read_tokens").Int64Value

		    result.Add(s)
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
		    Var usage As New WakeTokenUsage
		    usage.InputTokens = row.Column("input_tokens").Int64Value
		    usage.OutputTokens = row.Column("output_tokens").Int64Value
		    usage.CacheWriteTokens = row.Column("cache_write_tokens").Int64Value
		    usage.CacheReadTokens = row.Column("cache_read_tokens").Int64Value
		    s.Models.Add(row.Column("model").StringValue : usage)
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


	#tag Property, Flags = &h21
		Private mIndex As WakeIndex
	#tag EndProperty


End Class
#tag EndClass
