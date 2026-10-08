#tag Class
Protected Class ClaudeCodeParser
Implements IAgentParser
	#tag Method, Flags = &h0
		Function AgentID() As String
		  // Part of the IAgentParser interface.
		  Return "claude-code"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplyToolResult(session As WakeSession, block As Dictionary, toolUseResult As Variant, timestamp As DateTime, pendingTools As Dictionary)
		  // Pairs a tool_result block with its tool_use by id. Results can arrive several records
		  // after the call, and in a different order when calls run in parallel.
		  Var toolUseID As String = WakeCore.JSONString(block, "tool_use_id")

		  Var e As WakeEvent
		  If toolUseID <> "" And pendingTools.HasKey(toolUseID) Then
		    e = WakeEvent(pendingTools.Value(toolUseID).ObjectValue)
		    pendingTools.Remove(toolUseID)
		  Else
		    e = session.AddEvent(WakeEvent.Kinds.ToolResult, timestamp)
		    e.ToolUseID = toolUseID
		  End If

		  e.HasResult = True
		  e.ResultTimestamp = timestamp
		  e.ResultIsError = WakeCore.JSONBoolean(block, "is_error")
		  e.ResultText = ToolResultText(block.Lookup("content", Nil), session.Report)

		  // toolUseResult holds richer, tool-specific output than the text sent to the model.
		  Var details As Dictionary = WakeCore.AsDictionary(toolUseResult)
		  If details Is Nil Then Return

		  If details.HasKey("stdout") Then
		    e.Stdout = WakeCore.JSONString(details, "stdout")
		    e.Stderr = WakeCore.JSONString(details, "stderr")
		    e.Interrupted = WakeCore.JSONBoolean(details, "interrupted")
		  End If

		  Var persisted As String = WakeCore.JSONString(details, "persistedOutputPath")
		  If persisted <> "" Then
		    e.PersistedOutputPath = ResolvePersistedOutput(session, persisted)
		    e.PersistedOutputSize = WakeCore.JSONInteger(details, "persistedOutputSize")
		  End If

		  Var hunks() As Variant = WakeCore.JSONArray(details, "structuredPatch")
		  If hunks.Count > 0 Then e.Patch = PatchFromHunks(hunks)
		  If e.FilePath = "" Then e.FilePath = WakeCore.JSONString(details, "filePath")

		  Var agentID As String = WakeCore.JSONString(details, "agentId")
		  If agentID <> "" Then e.SubagentID = agentID
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DefaultRoots() As FolderItem()
		  // Part of the IAgentParser interface.
		  // Claude Code uses ~/.claude/projects on macOS, Linux and Windows alike, unless
		  // CLAUDE_CONFIG_DIR points somewhere else.
		  Var roots() As FolderItem

		  Try
		    Var configDir As String = System.EnvironmentVariable("CLAUDE_CONFIG_DIR")
		    Var root As FolderItem

		    If configDir <> "" Then
		      root = New FolderItem(configDir, FolderItem.PathModes.Native)
		    Else
		      root = SpecialFolder.UserHome.Child(".claude")
		    End If

		    If root <> Nil Then root = root.Child("projects")
		    If root <> Nil And root.Exists And root.IsFolder Then roots.Add(root)
		  Catch err As IOException
		    // No usable default location; the user can still add folders by hand.
		  Catch err As UnsupportedFormatException
		    // CLAUDE_CONFIG_DIR is not a valid path.
		  End Try

		  Return roots
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DisplayName() As String
		  // Part of the IAgentParser interface.
		  Return "Claude Code"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleAssistant(session As WakeSession, record As Dictionary, timestamp As DateTime, pendingTools As Dictionary, seenMessages As Dictionary)
		  Var message As Dictionary = WakeCore.JSONDictionary(record, "message")
		  If message Is Nil Then
		    session.Report.RecordErrors = session.Report.RecordErrors + 1
		    Return
		  End If

		  Var model As String = WakeCore.JSONString(message, "model")
		  Var messageID As String = WakeCore.JSONString(message, "id")
		  Var isError As Boolean = model = kSyntheticModel Or WakeCore.JSONBoolean(record, "isApiErrorMessage")

		  // One response is written as several records (thinking, text, tool_use), and every copy
		  // repeats the same usage. Count it once per message id.
		  If Not isError Then
		    Var key As String = If(messageID <> "", messageID, WakeCore.JSONString(record, "requestId"))
		    If key = "" Or Not seenMessages.HasKey(key) Then
		      If key <> "" Then seenMessages.Value(key) = True
		      session.AddUsage(model, UsageFrom(WakeCore.JSONDictionary(message, "usage")))
		    End If
		  End If

		  Var content As Variant = message.Lookup("content", Nil)
		  If content.Type = Variant.TypeString Then
		    Var e As WakeEvent = session.AddEvent(If(isError, WakeEvent.Kinds.Error, WakeEvent.Kinds.AssistantText), timestamp)
		    e.Text = content.StringValue
		    e.MessageID = messageID
		    e.Model = model
		    Return
		  End If

		  For Each item As Variant In WakeCore.JSONArray(message, "content")
		    Var block As Dictionary = WakeCore.AsDictionary(item)
		    If block Is Nil Then Continue

		    Var e As WakeEvent = Nil
		    Var blockType As String = WakeCore.JSONString(block, "type")

		    Select Case blockType
		    Case "text"
		      e = session.AddEvent(If(isError, WakeEvent.Kinds.Error, WakeEvent.Kinds.AssistantText), timestamp)
		      e.Text = WakeCore.JSONString(block, "text")

		    Case "thinking", "redacted_thinking"
		      e = session.AddEvent(WakeEvent.Kinds.Thinking, timestamp)
		      e.Text = WakeCore.JSONString(block, "thinking")

		    Case "tool_use"
		      e = NewToolEvent(session, block, timestamp)
		      If e.ToolUseID <> "" Then pendingTools.Value(e.ToolUseID) = e

		    Else
		      session.Report.CountUnknownBlockType(blockType)
		    End Select

		    If e <> Nil Then
		      e.MessageID = messageID
		      e.Model = model
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleRecord(session As WakeSession, record As Dictionary, pendingTools As Dictionary, seenMessages As Dictionary)
		  Var recordType As String = WakeCore.JSONString(record, "type")
		  Var timestamp As DateTime = WakeCore.ParseISO8601(WakeCore.JSONString(record, "timestamp"))
		  session.NoteTimestamp(timestamp)

		  // Envelope fields shared by conversation records. The folder name is a lossy encoding of
		  // the working directory, so the project path comes from cwd.
		  Var cwd As String = WakeCore.JSONString(record, "cwd")
		  If session.ProjectPath = "" And cwd <> "" Then session.ProjectPath = cwd

		  Var branch As String = WakeCore.JSONString(record, "gitBranch")
		  If session.GitBranch = "" And branch <> "" Then session.GitBranch = branch

		  Var version As String = WakeCore.JSONString(record, "version")
		  If version <> "" Then session.AgentVersion = version

		  Select Case recordType
		  Case "user"
		    HandleUser(session, record, timestamp, pendingTools)

		  Case "assistant"
		    HandleAssistant(session, record, timestamp, pendingTools, seenMessages)

		  Case "system"
		    HandleSystem(session, record, timestamp)

		  Case "ai-title"
		    // The title is regenerated during a session; the last one wins.
		    Var title As String = WakeCore.JSONString(record, "aiTitle")
		    If title <> "" Then session.Title = title

		  Case "cost-state"
		    If record.HasKey("totalCostUSD") Then
		      session.AgentReportedCostUSD = WakeCore.JSONDouble(record, "totalCostUSD")
		      session.HasAgentReportedCost = True
		    End If

		  Case "attachment", "last-prompt", "mode", "permission-mode", "agent-name", _
		    "file-history-snapshot", "file-history-delta", "queue-operation", "bridge-session", "atis-latch"
		    // Known, but not part of the timeline.
		    session.Report.IgnoredRecords = session.Report.IgnoredRecords + 1

		  Else
		    session.Report.CountUnknownRecordType(recordType)
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleSystem(session As WakeSession, record As Dictionary, timestamp As DateTime)
		  Var subtype As String = WakeCore.JSONString(record, "subtype")

		  If subtype = "turn_duration" Then
		    session.ActiveDurationMs = session.ActiveDurationMs + WakeCore.JSONInteger(record, "durationMs")
		    Return
		  End If

		  Var e As WakeEvent = session.AddEvent(WakeEvent.Kinds.System, timestamp)
		  e.SystemSubtype = subtype
		  e.Text = WakeCore.JSONString(record, "content")

		  If e.Text = "" Then e.Text = subtype.ReplaceAll("_", " ")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleUser(session As WakeSession, record As Dictionary, timestamp As DateTime, pendingTools As Dictionary)
		  Var message As Dictionary = WakeCore.JSONDictionary(record, "message")
		  If message Is Nil Then
		    session.Report.RecordErrors = session.Report.RecordErrors + 1
		    Return
		  End If

		  Var isMeta As Boolean = WakeCore.JSONBoolean(record, "isMeta")
		  Var content As Variant = message.Lookup("content", Nil)

		  If content.Type = Variant.TypeString Then
		    AddUserText(session, content.StringValue, isMeta, timestamp)
		    Return
		  End If

		  If Not content.IsArray Then
		    session.Report.RecordErrors = session.Report.RecordErrors + 1
		    Return
		  End If

		  // toolUseResult describes the record's tool result. In practice there is one result per record.
		  Var toolUseResult As Variant = record.Lookup("toolUseResult", Nil)
		  Var resultsSeen As Integer
		  Var textParts() As String

		  For Each item As Variant In WakeCore.JSONArray(message, "content")
		    Var block As Dictionary = WakeCore.AsDictionary(item)
		    If block Is Nil Then Continue

		    Var blockType As String = WakeCore.JSONString(block, "type")
		    Select Case blockType
		    Case "text"
		      textParts.Add(WakeCore.JSONString(block, "text"))

		    Case "image"
		      textParts.Add("[image]")

		    Case "tool_result"
		      If resultsSeen = 0 Then
		        ApplyToolResult(session, block, toolUseResult, timestamp, pendingTools)
		      Else
		        ApplyToolResult(session, block, Nil, timestamp, pendingTools)
		      End If
		      resultsSeen = resultsSeen + 1

		    Else
		      session.Report.CountUnknownBlockType(blockType)
		    End Select
		  Next

		  If textParts.Count > 0 Then
		    AddUserText(session, String.FromArray(textParts, &u0A), isMeta, timestamp)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddUserText(session As WakeSession, text As String, isMeta As Boolean, timestamp As DateTime)
		  // Slash commands, their output and background notifications arrive as user records,
		  // but the person did not type them as a prompt. Show them as system events.
		  Var e As WakeEvent

		  If isMeta Then
		    e = session.AddEvent(WakeEvent.Kinds.System, timestamp)
		    e.SystemSubtype = "meta"
		  ElseIf IsCommandWrapper(text) Then
		    e = session.AddEvent(WakeEvent.Kinds.System, timestamp)
		    e.SystemSubtype = "command"
		  Else
		    e = session.AddEvent(WakeEvent.Kinds.UserPrompt, timestamp)
		    session.PromptCount = session.PromptCount + 1
		  End If

		  e.Text = text
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsCommandWrapper(text As String) As Boolean
		  Var start As String = text.TrimLeft

		  For Each prefix As String In Array("<command-", "<local-command-", "<task-notification", _
		    "<bash-input", "<bash-stdout", "<bash-stderr", "[Request interrupted by user")
		    If start.BeginsWith(prefix) Then Return True
		  Next

		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsSessionFile(f As FolderItem) As Boolean
		  // Part of the IAgentParser interface.
		  // Sessions are <sessionId>.jsonl directly inside a project folder. Subagent transcripts
		  // (agent-*.jsonl) are loaded with their parent session.
		  If f Is Nil Or Not f.Exists Or f.IsFolder Then Return False

		  Var name As String = f.Name
		  If Not name.EndsWith(".jsonl") Then Return False
		  If name.BeginsWith("agent-") Then Return False

		  Var parent As FolderItem = f.Parent
		  If parent <> Nil And parent.Name = "subagents" Then Return False

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadSubagents(session As WakeSession)
		  // Subagent transcripts live in <project>/<sessionId>/subagents/agent-<agentId>.jsonl,
		  // with metadata in agent-<agentId>.meta.json.
		  Var folder As FolderItem

		  Try
		    folder = session.SourceFile.Parent.Child(session.ID).Child("subagents")
		    If folder Is Nil Or Not folder.Exists Or Not folder.IsFolder Then Return

		    For Each child As FolderItem In folder.Children
		      Var name As String = child.Name
		      If Not name.BeginsWith("agent-") Or Not name.EndsWith(".jsonl") Then Continue

		      Var baseName As String = name.Left(name.Length - 6)
		      Var subagent As WakeSession = ParseTranscript(child, True)
		      subagent.SubagentID = baseName.Middle(6)
		      ReadSubagentMeta(subagent, folder.Child(baseName + ".meta.json"))

		      session.Subagents.Add(subagent)
		      LinkSubagent(session, subagent)
		    Next
		  Catch err As IOException
		    session.Report.FileError = "could not read subagents: " + err.Message
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LinkSubagent(session As WakeSession, subagent As WakeSession)
		  // Attach the subagent to the parent's tool call that started it: by the tool use id from
		  // its metadata, or by the agent id reported in the call's result.
		  For Each e As WakeEvent In session.Events
		    If Not e.IsToolCall Then Continue

		    If (subagent.ParentToolUseID <> "" And e.ToolUseID = subagent.ParentToolUseID) Or _
		      (subagent.SubagentID <> "" And e.SubagentID = subagent.SubagentID) Then
		      e.Subagent = subagent
		      e.SubagentID = subagent.SubagentID
		      If subagent.ParentToolUseID = "" Then subagent.ParentToolUseID = e.ToolUseID
		      Return
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function NewToolEvent(session As WakeSession, block As Dictionary, timestamp As DateTime) As WakeEvent
		  Var name As String = WakeCore.JSONString(block, "name")
		  Var toolInput As Dictionary = WakeCore.JSONDictionary(block, "input")
		  Var e As WakeEvent

		  Select Case name
		  Case "Bash"
		    e = session.AddEvent(WakeEvent.Kinds.ShellCommand, timestamp)
		    e.Command = WakeCore.JSONString(toolInput, "command")

		  Case "Edit"
		    e = session.AddEvent(WakeEvent.Kinds.FileEdit, timestamp)
		    e.FilePath = WakeCore.JSONString(toolInput, "file_path")
		    e.Patch = PatchFromStrings(WakeCore.JSONString(toolInput, "old_string"), WakeCore.JSONString(toolInput, "new_string"))

		  Case "MultiEdit"
		    e = session.AddEvent(WakeEvent.Kinds.FileEdit, timestamp)
		    e.FilePath = WakeCore.JSONString(toolInput, "file_path")
		    Var parts() As String
		    For Each item As Variant In WakeCore.JSONArray(toolInput, "edits")
		      Var edit As Dictionary = WakeCore.AsDictionary(item)
		      parts.Add(PatchFromStrings(WakeCore.JSONString(edit, "old_string"), WakeCore.JSONString(edit, "new_string")))
		    Next
		    e.Patch = String.FromArray(parts, &u0A)

		  Case "Write"
		    // Until the result says otherwise, show the whole content as added.
		    e = session.AddEvent(WakeEvent.Kinds.FileEdit, timestamp)
		    e.FilePath = WakeCore.JSONString(toolInput, "file_path")
		    e.Patch = PatchFromStrings("", WakeCore.JSONString(toolInput, "content"))

		  Case "NotebookEdit"
		    e = session.AddEvent(WakeEvent.Kinds.FileEdit, timestamp)
		    e.FilePath = WakeCore.JSONString(toolInput, "notebook_path")
		    e.Patch = PatchFromStrings("", WakeCore.JSONString(toolInput, "new_source"))

		  Else
		    e = session.AddEvent(WakeEvent.Kinds.ToolCall, timestamp)
		  End Select

		  e.ToolName = name
		  e.ToolUseID = WakeCore.JSONString(block, "id")

		  If toolInput <> Nil Then
		    Try
		      e.ToolInputJSON = GenerateJSON(toolInput)
		    Catch err As JSONException
		      e.ToolInputJSON = ""
		    End Try
		  End If

		  Return e
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ParseSession(f As FolderItem) As WakeSession
		  // Part of the IAgentParser interface.
		  // Never raises for bad content: anything that can't be read is counted in session.Report.
		  Var session As WakeSession = ParseTranscript(f, False)
		  If session.Report.FileError = "" Then LoadSubagents(session)
		  Return session
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RelatedFiles(f As FolderItem) As FolderItem()
		  // Part of the IAgentParser interface.
		  // Subagent transcripts and their metadata are parsed with the session, so a change to
		  // any of them means the session has to be indexed again. tool-results/ is read on demand.
		  Var result() As FolderItem
		  If f Is Nil Or f.Parent Is Nil Then Return result

		  Var name As String = f.Name
		  If name.EndsWith(".jsonl") Then name = name.Left(name.Length - 6)

		  Try
		    Var folder As FolderItem = f.Parent.Child(name).Child("subagents")
		    If folder Is Nil Or Not folder.Exists Or Not folder.IsFolder Then Return result

		    For Each child As FolderItem In folder.Children
		      If child.IsFolder Or Not child.Name.BeginsWith("agent-") Then Continue
		      If child.Name.EndsWith(".jsonl") Or child.Name.EndsWith(".meta.json") Then result.Add(child)
		    Next
		  Catch err As IOException
		    // Unreadable side files: the session is still indexed from its main transcript.
		  End Try

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SessionFiles(root As FolderItem) As FolderItem()
		  // Part of the IAgentParser interface.
		  // root is normally ~/.claude/projects, with one folder per project. A custom folder may
		  // also be a single project folder, so session files directly inside root count too.
		  Var result() As FolderItem
		  If root Is Nil Or Not root.Exists Or Not root.IsFolder Then Return result

		  Try
		    For Each child As FolderItem In root.Children
		      If child.IsFolder Then
		        For Each candidate As FolderItem In child.Children
		          If IsSessionFile(candidate) Then result.Add(candidate)
		        Next
		      ElseIf IsSessionFile(child) Then
		        result.Add(child)
		      End If
		    Next
		  Catch err As IOException
		    // A folder that can't be listed contributes no sessions.
		  End Try

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseTranscript(f As FolderItem, isSubagent As Boolean) As WakeSession
		  Var session As New WakeSession
		  session.AgentID = AgentID
		  session.IsSubagent = isSubagent
		  session.SourceFile = f

		  If f Is Nil Then
		    session.Report.FileError = "no file"
		    Return session
		  End If

		  Var name As String = f.Name
		  session.ID = If(name.EndsWith(".jsonl"), name.Left(name.Length - 6), name)

		  Var pendingTools As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  Var seenMessages As Dictionary = WakeCore.NewCaseSensitiveDictionary
		  Var input As TextInputStream

		  Try
		    // TextInputStream opens the file read-only. Wake never writes transcripts.
		    input = TextInputStream.Open(f)
		    input.Encoding = Encodings.UTF8

		    While Not input.EndOfFile
		      Var line As String = input.ReadLine
		      session.Report.LinesRead = session.Report.LinesRead + 1

		      If line.Trim = "" Then
		        session.Report.BlankLines = session.Report.BlankLines + 1
		        Continue
		      End If

		      Var record As Dictionary
		      Try
		        record = WakeCore.AsDictionary(ParseJSON(line))
		      Catch err As JSONException
		        record = Nil
		      End Try

		      If record Is Nil Then
		        session.Report.MalformedLines = session.Report.MalformedLines + 1
		        Continue
		      End If

		      // A record with an unexpected shape must not stop the rest of the file from loading.
		      Try
		        HandleRecord(session, record, pendingTools, seenMessages)
		        session.Report.RecordsParsed = session.Report.RecordsParsed + 1
		      Catch err As TypeMismatchException
		        session.Report.RecordErrors = session.Report.RecordErrors + 1
		      Catch err As NilObjectException
		        session.Report.RecordErrors = session.Report.RecordErrors + 1
		      Catch err As KeyNotFoundException
		        session.Report.RecordErrors = session.Report.RecordErrors + 1
		      Catch err As OutOfBoundsException
		        session.Report.RecordErrors = session.Report.RecordErrors + 1
		      Catch err As InvalidArgumentException
		        session.Report.RecordErrors = session.Report.RecordErrors + 1
		      End Try
		    Wend
		  Catch err As IOException
		    session.Report.FileError = err.Message
		  End Try

		  If input <> Nil Then input.Close
		  Return session
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PatchFromHunks(hunks() As Variant) As String
		  // structuredPatch is a list of unified-diff hunks: oldStart, oldLines, newStart, newLines, lines.
		  Var output() As String

		  For Each item As Variant In hunks
		    Var hunk As Dictionary = WakeCore.AsDictionary(item)
		    If hunk Is Nil Then Continue

		    output.Add("@@ -" + WakeCore.JSONInteger(hunk, "oldStart").ToString + "," + WakeCore.JSONInteger(hunk, "oldLines").ToString + _
		    " +" + WakeCore.JSONInteger(hunk, "newStart").ToString + "," + WakeCore.JSONInteger(hunk, "newLines").ToString + " @@")

		    For Each patchLine As Variant In WakeCore.JSONArray(hunk, "lines")
		      If patchLine.Type = Variant.TypeString Then output.Add(patchLine.StringValue)
		    Next
		  Next

		  Return String.FromArray(output, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PatchFromStrings(oldText As String, newText As String) As String
		  // A minimal diff from the tool input, used when no structured patch is available.
		  Var output() As String

		  If oldText <> "" Then
		    For Each patchLine As String In oldText.ReplaceLineEndings(&u0A).Split(&u0A)
		      output.Add("-" + patchLine)
		    Next
		  End If

		  If newText <> "" Then
		    Var normalized As String = newText.ReplaceLineEndings(&u0A)
		    If normalized.EndsWith(&u0A) Then normalized = normalized.Left(normalized.Length - 1)
		    For Each patchLine As String In normalized.Split(&u0A)
		      output.Add("+" + patchLine)
		    Next
		  End If

		  Return String.FromArray(output, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ReadSubagentMeta(subagent As WakeSession, metaFile As FolderItem)
		  If metaFile Is Nil Or Not metaFile.Exists Then Return

		  Try
		    Var input As TextInputStream = TextInputStream.Open(metaFile)
		    input.Encoding = Encodings.UTF8
		    Var meta As Dictionary = WakeCore.AsDictionary(ParseJSON(input.ReadAll))
		    input.Close

		    subagent.ParentToolUseID = WakeCore.JSONString(meta, "toolUseId")
		    subagent.SubagentType = WakeCore.JSONString(meta, "agentType")
		    subagent.SubagentDescription = WakeCore.JSONString(meta, "description")
		  Catch err As IOException
		    subagent.Report.FileError = "could not read " + metaFile.Name
		  Catch err As JSONException
		    subagent.Report.MalformedLines = subagent.Report.MalformedLines + 1
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ResolvePersistedOutput(session As WakeSession, recordedPath As String) As String
		  // The recorded path is absolute on the machine that wrote it. Look for the file by name in
		  // this session's tool-results folder, so moved or copied transcript folders still work.
		  Var fileName As String = recordedPath.NthField("/", recordedPath.CountFields("/"))
		  If fileName.IndexOf("\") >= 0 Then fileName = fileName.NthField("\", fileName.CountFields("\"))

		  Try
		    Var sessionFolder As FolderItem
		    If session.IsSubagent Then
		      sessionFolder = session.SourceFile.Parent.Parent
		    Else
		      sessionFolder = session.SourceFile.Parent.Child(session.ID)
		    End If

		    Var candidate As FolderItem = sessionFolder.Child("tool-results").Child(fileName)
		    If candidate <> Nil And candidate.Exists Then Return candidate.NativePath
		  Catch err As NilObjectException
		    // Fall back to the recorded path.
		  Catch err As IOException
		    // Fall back to the recorded path.
		  End Try

		  Return recordedPath
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolResultText(content As Variant, report As WakeParseReport) As String
		  If content.Type = Variant.TypeString Then Return content.StringValue
		  If Not content.IsArray Then Return ""

		  Var items() As Variant
		  Try
		    items = content
		  Catch err As TypeMismatchException
		    Return ""
		  End Try

		  Var parts() As String
		  For Each item As Variant In items
		    Var block As Dictionary = WakeCore.AsDictionary(item)
		    If block Is Nil Then Continue

		    Var blockType As String = WakeCore.JSONString(block, "type")
		    Select Case blockType
		    Case "text"
		      parts.Add(WakeCore.JSONString(block, "text"))
		    Case "image"
		      parts.Add("[image]")
		    Case "tool_reference"
		      parts.Add("[tool reference: " + WakeCore.JSONString(block, "tool_name", WakeCore.JSONString(block, "name")) + "]")
		    Else
		      report.CountUnknownBlockType(blockType)
		    End Select
		  Next

		  Return String.FromArray(parts, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function UsageFrom(usage As Dictionary) As WakeTokenUsage
		  Var result As New WakeTokenUsage
		  If usage Is Nil Then Return result

		  result.InputTokens = WakeCore.JSONInteger(usage, "input_tokens")
		  result.OutputTokens = WakeCore.JSONInteger(usage, "output_tokens")
		  result.CacheWriteTokens = WakeCore.JSONInteger(usage, "cache_creation_input_tokens")
		  result.CacheReadTokens = WakeCore.JSONInteger(usage, "cache_read_input_tokens")
		  Return result
		End Function
	#tag EndMethod


	#tag Constant, Name = kSyntheticModel, Type = String, Dynamic = False, Default = \"<synthetic>", Scope = Private
	#tag EndConstant


End Class
#tag EndClass
