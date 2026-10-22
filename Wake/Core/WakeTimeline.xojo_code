#tag Class
Protected Class WakeTimeline
	#tag Method, Flags = &h21
		Private Sub AddCard(out() As String, cssClass As String, label As String, timestamp As DateTime, body As String, stats As String = "")
		  out.Add("<section class=""card " + cssClass + """><div class=""head""><span class=""who"">" + EscapeHTML(label) + "</span>" + _
		  "<span>" + stats + TimeHTML(timestamp) + "</span></div>" + body + "</section>")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddEvent(out() As String, e As WakeEvent)
		  Select Case e.Kind
		  Case WakeEvent.Kinds.UserPrompt
		    AddCard(out, "user", "You", e.Timestamp, Block(e.Text, False, "prose"), TurnStats(e))
		    
		  Case WakeEvent.Kinds.AssistantText
		    AddCard(out, "assistant", "Assistant", e.Timestamp, Block(e.Text, False, "prose"))
		    
		  Case WakeEvent.Kinds.Error
		    AddCard(out, "error", "Error", e.Timestamp, Block(e.Text, False, "prose"))
		    
		  Case WakeEvent.Kinds.Thinking
		    // The thinking text is usually redacted and only its signature is kept.
		    If e.Text.Trim = "" Then
		      out.Add("<div class=""line thinking"">" + TimeHTML(e.Timestamp) + "Thinking <span class=""muted"">(not recorded)</span></div>")
		    Else
		      out.Add("<details class=""thinking""><summary>" + TimeHTML(e.Timestamp) + "Thinking</summary>" + _
		      Block(e.Text, False, "prose") + "</details>")
		    End If
		    
		  Case WakeEvent.Kinds.System
		    AddSystem(out, e)
		    
		  Case WakeEvent.Kinds.ToolCall, WakeEvent.Kinds.ShellCommand, WakeEvent.Kinds.FileEdit, WakeEvent.Kinds.ToolResult
		    AddTool(out, e)
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddEvents(out() As String, session As WakeSession)
		  If session.Events.Count = 0 Then
		    out.Add("<p class=""muted"">No events in this transcript.</p>")
		    Return
		  End If
		  
		  // Each event gets an anchor, so a search hit can scroll to it with wakeGoTo.
		  Var uid As String = If(session.IsSubagent And session.SubagentID <> "", session.SubagentID, session.ID)
		  Var lastModel As String
		  
		  For Each e As WakeEvent In session.Events
		    // A thin line opens each response, with its usage. The model is named when it changes.
		    If e.Response <> Nil And e.Response.FirstSequence = e.Sequence Then
		      AddResponse(out, e.Response, e.Response.Model <> lastModel)
		      lastModel = e.Response.Model
		    End If
		    
		    Var anchor As String = NewAnchor(uid, e.Sequence)
		    out.Add("<div class=""ev"" id=""" + anchor + """>")
		    AddEvent(out, e)
		    out.Add("</div>")
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddParseNote(out() As String, session As WakeSession)
		  If Not session.Report.IsPartial Then Return
		  out.Add("<div class=""warning""><b>Partially parsed.</b> " + EscapeHTML(session.Report.Summary) + "</div>")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddResponse(out() As String, response As WakeResponse, showModel As Boolean)
		  // A response's context is everything the model read: new input plus cache writes and reads.
		  Var u As WakeTokenUsage = response.Usage
		  Var parts() As String
		  If showModel And response.Model <> "" Then parts.Add(response.Model)
		  If response.Seconds >= 0 Then parts.Add(WakeFormat.Seconds(response.Seconds))
		  parts.Add(WakeFormat.Tokens(response.ContextTokens) + " in")
		  parts.Add(WakeFormat.Tokens(u.OutputTokens) + " out")
		  
		  Var detail As String = "Input " + WakeFormat.Count(u.InputTokens) + ", cache write " + WakeFormat.Count(u.CacheWriteTokens) + _
		  ", cache read " + WakeFormat.Count(u.CacheReadTokens) + ", output " + WakeFormat.Count(u.OutputTokens)
		  If response.StartsNewContext Then detail = detail + ". The context shrank here, so it was probably compacted."
		  
		  Var usage As New WakeUsageGroup
		  usage.Add(response.Model, u)
		  out.Add("<div class=""resp"">" + Stats(parts, usage, detail) + "</div>")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddSubagent(out() As String, child As WakeSession)
		  Var label As String = "Subagent"
		  If child.SubagentType <> "" Then label = label + " · " + child.SubagentType
		  If child.SubagentDescription <> "" Then label = label + " · " + child.SubagentDescription
		  
		  Var facts As String = WakeFormat.Tokens(child.TotalUsage.Total) + " tokens, " + _
		  If(child.Events.Count = 1, "1 event", WakeFormat.Count(child.Events.Count) + " events")
		  
		  Var noParts() As String
		  out.Add("<details class=""subagent""><summary>" + Stats(noParts, child.TotalUsageByModel, "") + EscapeHTML(label) + _
		  " <span class=""muted"">" + EscapeHTML(facts) + "</span></summary><div class=""body"">")
		  AddParseNote(out, child)
		  AddEvents(out, child)
		  out.Add("</div></details>")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddSystem(out() As String, e As WakeEvent)
		  // Slash commands, notifications and CLI messages. Their text is often wrapped in tags such
		  // as <command-name>, so the one-line form drops the tags.
		  Var shortText As String = WakeFormat.OneLine(StripTags(e.Text), 160)
		  If shortText = "" Then shortText = If(e.SystemSubtype <> "", e.SystemSubtype, "system")
		  
		  If e.Text.IndexOf(&u0A) < 0 And e.Text.Length <= 160 And e.Text = shortText Then
		    out.Add("<div class=""line system"">" + TimeHTML(e.Timestamp) + EscapeHTML(shortText) + "</div>")
		  Else
		    out.Add("<details class=""system""><summary>" + TimeHTML(e.Timestamp) + EscapeHTML(shortText) + "</summary>" + _
		    Block(e.Text, False, "") + "</details>")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddTool(out() As String, e As WakeEvent)
		  Var summary As String
		  Var body() As String
		  
		  Select Case e.Kind
		  Case WakeEvent.Kinds.ShellCommand
		    summary = "<span class=""tool"">" + EscapeHTML(e.ToolName) + "</span> <code>$ " + EscapeHTML(WakeFormat.OneLine(e.Command, 160)) + "</code>"
		    If e.Command.IndexOf(&u0A) >= 0 Or e.Command.Length > 160 Then body.Add(Section("Command", Block(e.Command, False, "")))
		    
		  Case WakeEvent.Kinds.FileEdit
		    Var added, removed As Integer
		    For Each patchLine As String In e.Patch.Split(&u0A)
		      If patchLine.BeginsWith("+") Then
		        added = added + 1
		      ElseIf patchLine.BeginsWith("-") Then
		        removed = removed + 1
		      End If
		    Next
		    summary = "<span class=""tool"">" + EscapeHTML(e.ToolName) + "</span> <code>" + EscapeHTML(e.FilePath) + "</code>" + _
		    " <span class=""add"">+" + added.ToString + "</span> <span class=""del"">−" + removed.ToString + "</span>"
		    If e.Patch <> "" Then body.Add(Block(e.Patch, True, ""))
		    
		  Case WakeEvent.Kinds.ToolCall
		    summary = "<span class=""tool"">" + EscapeHTML(e.ToolName) + "</span> " + EscapeHTML(WakeFormat.OneLine(InputSummary(e), 160))
		    Var inputText As String = InputText(e)
		    If inputText <> "" Then body.Add(Section("Input", Block(inputText, False, "")))
		    
		  Else
		    summary = "<span class=""tool"">Tool result</span>"
		  End Select
		  
		  If e.HasResult And e.ResultIsError Then summary = summary + "<span class=""badge error"">error</span>"
		  If e.Interrupted Then summary = summary + "<span class=""badge"">interrupted</span>"
		  If e.IsToolCall And Not e.HasResult Then summary = summary + "<span class=""badge"">no result</span>"
		  summary = ToolStats(e) + summary
		  
		  If e.Subagent <> Nil Then AddSubagent(body, e.Subagent)
		  
		  // An edit's result only says the file was updated, so it is shown only when it failed.
		  If e.HasResult And (e.Kind <> WakeEvent.Kinds.FileEdit Or e.ResultIsError) Then
		    If e.Stdout <> "" Or e.Stderr <> "" Then
		      If e.Stdout <> "" Then body.Add(Section("Output", Block(e.Stdout, False, "")))
		      If e.Stderr <> "" Then body.Add(Section("Errors", Block(e.Stderr, False, "stderr")))
		    ElseIf e.ResultText <> "" Then
		      body.Add(Section(If(e.ResultIsError, "Error", "Result"), Block(e.ResultText, False, If(e.ResultIsError, "stderr", ""))))
		    ElseIf e.PersistedOutputPath = "" Then
		      body.Add(Section("Result", "<p class=""muted"">No output.</p>"))
		    End If
		  End If
		  
		  // Large outputs are stored outside the transcript and read only when asked for.
		  If e.PersistedOutputPath <> "" Then
		    Var id As String = NewBlockID
		    mPersisted.Value(id) = e.PersistedOutputPath
		    Var size As String = If(e.PersistedOutputSize > 0, ", " + WakeFormat.Bytes(e.PersistedOutputSize), "")
		    body.Add(Section("Full output", "<div class=""persisted"" id=""" + id + """><span class=""muted"">Saved separately" + size + _
		    ".</span> <button onclick=""wakeLoad('persisted','" + id + "',this)"">Load full output</button></div>"))
		  End If
		  
		  Var classes As String = "tool-call" + If(e.HasResult And e.ResultIsError, " failed", "")
		  If body.Count = 0 Then
		    out.Add("<div class=""line " + classes + """>" + TimeHTML(e.Timestamp) + summary + "</div>")
		  Else
		    out.Add("<details class=""" + classes + """><summary>" + TimeHTML(e.Timestamp) + summary + "</summary><div class=""body"">" + _
		    String.FromArray(body, "") + "</div></details>")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Anchor(sessionUID As String, sequence As Integer) As String
		  // The element id of an event in the page, or "" if there is no such event. sessionUID is the
		  // session's or subagent's uid, as the index stores it.
		  Call HTML
		  Return KnownAnchor(sessionUID, sequence)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Block(text As String, isDiff As Boolean, cssClass As String, previewLines As Integer = 0, previewCharacters As Integer = 0) As String
		  // Text or a diff, cut to a preview when it is long. The full block stays in memory and the
		  // page asks for it with wakeLoad('expand', id), so large sessions load quickly. A preview
		  // limit of 0 takes the timeline's own.
		  Var maxLines As Integer = If(previewLines > 0, previewLines, kPreviewLines)
		  Var maxCharacters As Integer = If(previewCharacters > 0, previewCharacters, kPreviewCharacters)
		  Var lines() As String = SplitLines(text)
		  Var preview() As String
		  Var used As Integer
		  Var truncated As Boolean
		  
		  For Each textLine As String In lines
		    If preview.Count >= maxLines Or used >= maxCharacters Then
		      truncated = True
		      Exit
		    End If
		    
		    Var shown As String = textLine
		    If used + shown.Length > maxCharacters Then
		      shown = shown.Left(maxCharacters - used) + WakeFormat.kEllipsis
		      truncated = True
		    End If
		    preview.Add(shown)
		    used = used + shown.Length + 1
		  Next
		  
		  Var tag As String = If(isDiff, "div", "pre")
		  Var classes As String = If(isDiff, "diff", "text") + If(cssClass <> "", " " + cssClass, "")
		  
		  If Not truncated Then Return "<" + tag + " class=""" + classes + """>" + RenderLines(preview, isDiff) + "</" + tag + ">"
		  
		  Var id As String = NewBlockID
		  mBlocks.Value(id) = text : isDiff
		  Var label As String = If(lines.Count > 1, "Show all " + WakeFormat.Count(lines.Count) + " lines", "Show full text")
		  
		  Return "<" + tag + " class=""" + classes + """ id=""" + id + """>" + RenderLines(preview, isDiff) + "</" + tag + ">" + _
		  "<button class=""more"" onclick=""wakeLoad('expand','" + id + "',this)"">" + label + " (" + WakeFormat.Bytes(text.Bytes) + ")</button>"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(session As WakeSession)
		  mSession = session
		  mAnchors = WakeCore.NewCaseSensitiveDictionary
		  mCosts = WakeCore.NewCaseSensitiveDictionary
		  mBlocks = WakeCore.NewCaseSensitiveDictionary
		  mPersisted = WakeCore.NewCaseSensitiveDictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CostsJSON(prices As WakePriceTable) As String
		  // The cost of every stat on the page, as a JSON object of element id to text, for the page's
		  // wakeSetCosts. The page never depends on prices, so a price change doesn't reload it.
		  Call HTML
		  
		  Var result As New Dictionary
		  For Each key As Variant In mCosts.Keys
		    Var text As String
		    If prices <> Nil Then
		      Var estimate As WakeCostEstimate = prices.Estimate(WakeUsageGroup(mCosts.Value(key).ObjectValue).ByModel)
		      If estimate.PricedTokens > 0 Then text = WakeFormat.Cost(estimate)
		    End If
		    result.Value(key.StringValue) = text
		  Next
		  
		  Return GenerateJSON(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function EscapeHTML(text As String) As String
		  Return text.ReplaceAll("&", "&amp;").ReplaceAll("<", "&lt;").ReplaceAll(">", "&gt;").ReplaceAll("""", "&quot;").ReplaceAll("'", "&#39;")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExpandedHTML(blockID As String) As String
		  // The full contents of a block that HTML showed only in part.
		  If Not mBlocks.HasKey(blockID) Then Return ""
		  
		  Var entry As Pair = mBlocks.Value(blockID)
		  Var text As String = entry.Left.StringValue
		  Var isDiff As Boolean = entry.Right.BooleanValue
		  
		  Var limit As Integer = kExpandLimit
		  Var note As String
		  If text.Length > limit Then
		    note = "[" + WakeFormat.Count(text.Length - limit) + " more characters not shown]"
		    text = text.Left(limit)
		  End If
		  
		  Var lines() As String = SplitLines(text)
		  If note <> "" Then lines.Add(note)
		  Return RenderLines(lines, isDiff)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTML() As String
		  // A self-contained page: inline style and script, and a content policy that blocks every
		  // remote resource, so nothing in a transcript can make the viewer reach the network.
		  If mHTML <> "" Then Return mHTML
		  
		  Var out() As String
		  out.Add("<!DOCTYPE html><html><head><meta charset=""utf-8"">")
		  out.Add("<meta http-equiv=""Content-Security-Policy"" content=""default-src 'none'; style-src 'unsafe-inline'; " + _
		  "script-src 'unsafe-inline'; img-src data:"">")
		  out.Add("<style>" + StyleSheet + "</style>")
		  out.Add("<script>" + ScriptSource + "</script>")
		  out.Add("</head><body>")
		  AddParseNote(out, mSession)
		  AddEvents(out, mSession)
		  out.Add("</body></html>")
		  
		  mHTML = String.FromArray(out, &u0A)
		  Return mHTML
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InputDictionary(e As WakeEvent) As Dictionary
		  If e.ToolInputJSON = "" Then Return Nil
		  
		  Try
		    Return WakeCore.AsDictionary(ParseJSON(e.ToolInputJSON))
		  Catch err As JSONException
		    Return Nil
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InputSummary(e As WakeEvent) As String
		  // The most telling input field of a tool call: a path, pattern, URL or description.
		  Var toolInput As Dictionary = InputDictionary(e)
		  If toolInput Is Nil Then Return ""
		  
		  For Each key As String In Array("file_path", "notebook_path", "path", "pattern", "url", "query", "description", "prompt", "command")
		    Var value As String = WakeCore.JSONString(toolInput, key)
		    If value <> "" Then Return value
		  Next
		  
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InputText(e As WakeEvent) As String
		  // The tool input as "key: value" lines, easier to read than the raw JSON.
		  Var toolInput As Dictionary = InputDictionary(e)
		  If toolInput Is Nil Then Return e.ToolInputJSON
		  
		  Var lines() As String
		  For Each key As Variant In toolInput.Keys
		    Var value As Variant = toolInput.Value(key)
		    Var shown As String
		    
		    Select Case value.Type
		    Case Variant.TypeString
		      shown = value.StringValue
		    Case Variant.TypeNil
		      shown = "null"
		    Case Variant.TypeBoolean
		      shown = If(value.BooleanValue, "true", "false")
		    Case Variant.TypeInt32, Variant.TypeInt64, Variant.TypeDouble
		      shown = value.StringValue
		    Else
		      Try
		        shown = GenerateJSON(value)
		      Catch err As JSONException
		        shown = "(unreadable)"
		      Catch err As TypeMismatchException
		        shown = "(unreadable)"
		      End Try
		    End Select
		    
		    lines.Add(key.StringValue + ": " + shown)
		  Next
		  
		  Return String.FromArray(lines, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsTagName(name As String) As Boolean
		  If name.Length > 40 Then Return False
		  
		  For i As Integer = 0 To name.Length - 1
		    Var c As String = name.Middle(i, 1)
		    If Not ((c >= "a" And c <= "z") Or c = "-" Or c = "_") Then Return False
		  Next
		  
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function KnownAnchor(sessionUID As String, sequence As Integer) As String
		  // An anchor NewAnchor has made so far, without rendering the page, for use while rendering.
		  Return mAnchors.Lookup(sessionUID + "/" + sequence.ToString, "").StringValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Load(agentID As String, filePath As String) As WakeTimeline
		  // Parses a transcript for display. Never raises: a missing file or agent shows as a note.
		  Return New WakeTimeline(WakeCore.LoadSession(agentID, filePath))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LocalTime(d As DateTime) As DateTime
		  // Parsed timestamps keep the zone they were written in, usually UTC.
		  Return New DateTime(d.SecondsFrom1970, TimeZone.Current)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function NewAnchor(sessionUID As String, sequence As Integer) As String
		  // A new element id for an event, which Anchor finds by its session uid and sequence.
		  mNextAnchor = mNextAnchor + 1
		  Var anchor As String = "e" + mNextAnchor.ToString
		  mAnchors.Value(sessionUID + "/" + sequence.ToString) = anchor
		  Return anchor
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function NewBlockID() As String
		  mNextID = mNextID + 1
		  Return "b" + mNextID.ToString
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PersistedOutputHTML(blockID As String) As String
		  // Reads a tool's persisted output, read-only and only on request.
		  If Not mPersisted.HasKey(blockID) Then Return ""
		  Var path As String = mPersisted.Value(blockID).StringValue
		  
		  Try
		    Var f As New FolderItem(path, FolderItem.PathModes.Native)
		    If Not f.Exists Then Return "<p class=""muted"">" + EscapeHTML("The saved output is no longer at " + path + ".") + "</p>"
		    
		    Var stream As BinaryStream = BinaryStream.Open(f, False)
		    Var size As Int64 = stream.Length
		    Var count As Integer = kPersistedLimit
		    If size < count Then count = size
		    Var text As String = stream.Read(count, Encodings.UTF8)
		    stream.Close
		    
		    If size > count Then
		      // Don't leave half a multi-byte character at the cut.
		      Var cut As Integer = text.Bytes
		      While cut > 0 And Bitwise.BitAnd(text.MiddleBytes(cut - 1, 1).AscByte, &hC0) = &h80
		        cut = cut - 1
		      Wend
		      If cut > 0 And text.MiddleBytes(cut - 1, 1).AscByte >= &hC0 Then cut = cut - 1
		      text = text.LeftBytes(cut) + &u0A + "[" + WakeFormat.Bytes(size - cut) + " more not shown]"
		    End If
		    
		    Return Block(text, False, "")
		  Catch err As IOException
		    Return "<p class=""muted"">" + EscapeHTML("The saved output could not be read: " + err.Message) + "</p>"
		  Catch err As UnsupportedFormatException
		    Return "<p class=""muted"">" + EscapeHTML("The saved output path is not valid: " + path) + "</p>"
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RenderLines(lines() As String, isDiff As Boolean) As String
		  If Not isDiff Then Return EscapeHTML(String.FromArray(lines, &u0A))
		  
		  Var parts() As String
		  For Each patchLine As String In lines
		    Var kind As String = "ctx"
		    If patchLine.BeginsWith("@@") Then
		      kind = "hunk"
		    ElseIf patchLine.BeginsWith("+") Then
		      kind = "add"
		    ElseIf patchLine.BeginsWith("-") Then
		      kind = "del"
		    End If
		    parts.Add("<div class=""dl " + kind + """>" + EscapeHTML(patchLine) + "</div>")
		  Next
		  
		  Return String.FromArray(parts, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Request(method As String, blockID As String) As String
		  // Answers the page's executeInXojoSync calls with an HTML fragment, or "" when unknown.
		  Select Case method
		  Case "expand"
		    Return ExpandedHTML(blockID)
		  Case "persisted"
		    Return PersistedOutputHTML(blockID)
		  End Select
		  
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ScriptSource() As String
		  Var js() As String
		  js.Add("function wakeAll(open) {")
		  js.Add("  document.querySelectorAll('details').forEach(function (d) { d.open = open; });")
		  js.Add("}")
		  js.Add("function wakeLoad(method, id, button) {")
		  js.Add("  if (typeof executeInXojoSync !== 'function') return;")
		  js.Add("  var html = executeInXojoSync(method, id);")
		  js.Add("  var target = document.getElementById(id);")
		  js.Add("  if (!target || !html) return;")
		  js.Add("  target.innerHTML = html;")
		  js.Add("  if (button && button.parentNode) button.parentNode.removeChild(button);")
		  js.Add("}")
		  js.Add("function wakeSetCosts(costs) {")
		  js.Add("  document.querySelectorAll('.cost').forEach(function (c) { c.textContent = costs[c.id] || ''; });")
		  js.Add("}")
		  js.Add("function wakeGoTo(id) {")
		  js.Add("  var target = document.getElementById(id);")
		  js.Add("  if (!target) return;")
		  js.Add("  for (var p = target; p; p = p.parentElement) { if (p.tagName === 'DETAILS') p.open = true; }")
		  js.Add("  var first = target.firstElementChild;")
		  js.Add("  if (first && first.tagName === 'DETAILS') first.open = true;")
		  js.Add("  document.querySelectorAll('.ev.hit').forEach(function (e) { e.classList.remove('hit'); });")
		  js.Add("  target.classList.add('hit');")
		  js.Add("  target.scrollIntoView({ block: 'center' });")
		  js.Add("}")
		  Return String.FromArray(js, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Section(label As String, content As String) As String
		  Return "<div class=""label"">" + EscapeHTML(label) + "</div>" + content
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Session() As WakeSession
		  Return mSession
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SplitLines(text As String) As String()
		  Var lines() As String = text.ReplaceLineEndings(&u0A).Split(&u0A)
		  While lines.Count > 1 And lines(lines.LastIndex) = ""
		    lines.RemoveAt(lines.LastIndex)
		  Wend
		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Stats(parts() As String, usage As WakeUsageGroup, detail As String) As String
		  // Right-aligned figures. The cost is left empty and filled in by wakeSetCosts.
		  Var html As String = EscapeHTML(String.FromArray(parts, " · "))
		  
		  If usage <> Nil And Not usage.Total.IsEmpty Then
		    mNextCost = mNextCost + 1
		    Var id As String = "c" + mNextCost.ToString
		    mCosts.Value(id) = usage
		    html = html + "<span class=""cost" + If(parts.Count = 0, " alone", "") + """ id=""" + id + """></span>"
		  End If
		  
		  If html = "" Then Return ""
		  Var title As String = If(detail <> "", " title=""" + EscapeHTML(detail) + """", "")
		  Return "<span class=""stats""" + title + ">" + html + "</span>"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StripTags(text As String) As String
		  // Removes tag-like markers such as <command-name> and </bash-stdout>, keeping their content.
		  Var result() As String
		  Var pos As Integer
		  
		  While pos < text.Length
		    Var openAt As Integer = text.IndexOf(pos, "<")
		    If openAt < 0 Then Exit
		    
		    Var closeAt As Integer = text.IndexOf(openAt, ">")
		    If closeAt < 0 Then Exit
		    
		    Var name As String = text.Middle(openAt + 1, closeAt - openAt - 1)
		    If name.BeginsWith("/") Then name = name.Middle(1)
		    
		    If name <> "" And IsTagName(name) Then
		      result.Add(text.Middle(pos, openAt - pos))
		      result.Add(" ")
		    Else
		      result.Add(text.Middle(pos, closeAt + 1 - pos))
		    End If
		    pos = closeAt + 1
		  Wend
		  
		  If pos < text.Length Then result.Add(text.Middle(pos))
		  Return String.FromArray(result, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function StyleSheet() As String
		  Var css() As String
		  css.Add(":root { color-scheme: light dark; --bg: #ffffff; --fg: #1d1d1f; --muted: #6e6e73; --line: #e2e2e6; --card: #f5f5f7;")
		  css.Add("  --user: #eef4ff; --user-line: #c8dbff; --code: #f2f2f4; --add-bg: #e6f6ea; --add: #1a7f37; --del-bg: #fdecec;")
		  css.Add("  --del: #c2272d; --hunk: #6639ba; --warn-bg: #fff4e0; --warn: #8a5300; --err: #c2272d; --hit: #f5b400; }")
		  css.Add("@media (prefers-color-scheme: dark) { :root { --bg: #1e1e20; --fg: #e8e8ea; --muted: #98989d; --line: #3a3a3e;")
		  css.Add("  --card: #2a2a2d; --user: #1f2a3d; --user-line: #34507a; --code: #28282b; --add-bg: #16301f; --add: #63d283;")
		  css.Add("  --del-bg: #3a1b1d; --del: #ff7b7f; --hunk: #b59cff; --warn-bg: #3a2c12; --warn: #f2b84b; --err: #ff7b7f; } }")
		  css.Add("body { margin: 0; padding: 16px 24px 48px; background: var(--bg); color: var(--fg);")
		  css.Add("  font: 13px/1.5 -apple-system, BlinkMacSystemFont, ""Segoe UI"", sans-serif; }")
		  css.Add(".muted { color: var(--muted); }")
		  css.Add("button { font: inherit; font-size: 12px; padding: 1px 10px; margin-right: 6px; border: 1px solid var(--line);")
		  css.Add("  border-radius: 5px; background: var(--card); color: var(--fg); cursor: pointer; }")
		  css.Add("button.more { margin: 0 0 6px; }")
		  css.Add(".warning { background: var(--warn-bg); color: var(--warn); border-radius: 6px; padding: 8px 12px; margin: 0 0 16px; }")
		  css.Add(".card { border: 1px solid var(--line); border-radius: 8px; padding: 8px 12px; margin: 12px 0; }")
		  css.Add(".card.user { background: var(--user); border-color: var(--user-line); }")
		  css.Add(".card.error { border-color: var(--err); }")
		  css.Add(".card.error .who { color: var(--err); }")
		  css.Add(".head { display: flex; justify-content: space-between; margin-bottom: 4px; font-size: 11px; font-weight: 600;")
		  css.Add("  text-transform: uppercase; letter-spacing: .04em; color: var(--muted); }")
		  css.Add(".time { color: var(--muted); font-size: 11px; font-weight: normal; font-variant-numeric: tabular-nums;")
		  css.Add("  text-transform: none; letter-spacing: 0; margin-right: 8px; }")
		  css.Add("pre, .diff { font: 12px/1.45 ui-monospace, Menlo, monospace; white-space: pre-wrap; overflow-wrap: anywhere;")
		  css.Add("  background: var(--code); border-radius: 5px; margin: 4px 0; }")
		  css.Add("pre { padding: 6px 8px; }")
		  css.Add(".diff { padding: 4px 0; }")
		  css.Add("pre.prose { font: inherit; background: none; padding: 0; margin: 0; }")
		  css.Add(".dl { padding: 0 8px; min-height: 1.45em; }")
		  css.Add(".dl.add { background: var(--add-bg); color: var(--add); }")
		  css.Add(".dl.del { background: var(--del-bg); color: var(--del); }")
		  css.Add(".dl.hunk { color: var(--hunk); }")
		  css.Add(".add { color: var(--add); }")
		  css.Add(".del { color: var(--del); }")
		  css.Add(".stderr { color: var(--err); }")
		  css.Add(".line, details { margin: 3px 0; }")
		  css.Add(".line { padding: 2px 6px 2px 20px; }")
		  css.Add("summary { cursor: pointer; padding: 2px 6px; border-radius: 5px; }")
		  css.Add("summary:hover { background: var(--card); }")
		  css.Add("summary code, .line code { font: 12px ui-monospace, Menlo, monospace; }")
		  css.Add(".tool { font-weight: 600; }")
		  css.Add(".failed > summary .tool { color: var(--err); }")
		  css.Add(".body { margin: 4px 0 10px 12px; padding-left: 10px; border-left: 2px solid var(--line); }")
		  css.Add(".label { margin-top: 6px; font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: .05em; color: var(--muted); }")
		  css.Add(".badge { display: inline-block; margin-left: 6px; padding: 0 6px; border-radius: 8px; font-size: 10px; font-weight: 700;")
		  css.Add("  background: var(--line); color: var(--muted); vertical-align: 1px; }")
		  css.Add(".badge.error { background: var(--err); color: #fff; }")
		  css.Add(".system, .thinking { color: var(--muted); font-size: 12px; }")
		  css.Add(".subagent { border: 1px dashed var(--line); border-radius: 8px; padding: 4px 8px; margin: 6px 0; }")
		  css.Add(".persisted { margin: 4px 0; }")
		  css.Add(".stats { float: right; margin-left: 12px; color: var(--muted); font-size: 11px; font-weight: normal;")
		  css.Add("  font-variant-numeric: tabular-nums; text-transform: none; letter-spacing: 0; }")
		  css.Add(".head .stats { float: none; margin: 0 8px 0 0; }")
		  css.Add(".cost { color: var(--fg); }")
		  css.Add(".cost:not(:empty):not(.alone)::before { content: "" · ""; color: var(--muted); }")
		  css.Add(".resp { clear: both; margin: 10px 0 0; border-top: 1px solid var(--line); }")
		  css.Add(".resp::after { content: """"; display: block; clear: both; }")
		  css.Add(".ev.hit > * { outline: 2px solid var(--hit); outline-offset: 2px; border-radius: 6px; }")
		  Return String.FromArray(css, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function TimeHTML(timestamp As DateTime) As String
		  If timestamp Is Nil Then Return ""
		  
		  Var d As DateTime = LocalTime(timestamp)
		  Return "<span class=""time"">" + d.Hour.ToString(Locale.Raw, "00") + ":" + d.Minute.ToString(Locale.Raw, "00") + ":" + _
		  d.Second.ToString(Locale.Raw, "00") + "</span>"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ToolStats(e As WakeEvent) As String
		  // The tokens a result added are an estimate from the growth of the next response's context.
		  // Every later response reads them again from the cache, until the context is compacted.
		  Var parts() As String
		  If e.ResultSeconds >= 0 Then parts.Add(WakeFormat.Seconds(e.ResultSeconds))
		  If e.AddedTokens > 0 Then parts.Add("≈" + WakeFormat.Tokens(e.AddedTokens) + " added")
		  If e.CarriedTokens > 0 Then parts.Add("≈" + WakeFormat.Tokens(e.CarriedTokens) + " re-read")
		  
		  Var usage As New WakeUsageGroup
		  For Each group As WakeUsageGroup In Array(e.AddedUsage, e.CarriedUsage)
		    If group Is Nil Then Continue
		    For Each key As Variant In group.ByModel.Keys
		      usage.Add(key.StringValue, WakeTokenUsage(group.ByModel.Value(key).ObjectValue))
		    Next
		  Next
		  
		  Var detail As String
		  If e.AddedTokens > 0 Then
		    Var times As Int64 = e.CarriedTokens \ e.AddedTokens
		    detail = "About " + WakeFormat.Count(e.AddedTokens) + " tokens added to the context, read again by " + _
		    If(times = 1, "1 later response", WakeFormat.Count(times) + " later responses") + ". Estimated from the growth of the context."
		  End If
		  
		  Return Stats(parts, usage, detail)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TurnStats(e As WakeEvent) As String
		  // Everything the prompt led to, up to the next prompt, subagents included.
		  If e.TurnUsage Is Nil Then Return ""
		  
		  Var parts() As String
		  If e.TurnActiveMs > 0 Then parts.Add(WakeFormat.Seconds(e.TurnActiveMs / 1000) + " active")
		  If e.TurnResponses > 0 Then parts.Add(If(e.TurnResponses = 1, "1 response", WakeFormat.Count(e.TurnResponses) + " responses"))
		  Var total As WakeTokenUsage = e.TurnUsage.Total
		  If Not total.IsEmpty Then parts.Add(WakeFormat.Tokens(total.Total) + " tokens")
		  If e.TurnCarriedTokens > 0 Then parts.Add("≈" + WakeFormat.Tokens(e.TurnCarriedTokens) + " carried")
		  
		  Var detail As String = "This turn, up to the next prompt"
		  If e.TurnCarriedTokens > 0 Then
		    detail = detail + ". About " + WakeFormat.Count(e.TurnCarriedTokens) + " of its tokens re-sent context from " + _
		    "earlier turns, beyond the session's starting context."
		  End If
		  Return Stats(parts, e.TurnUsage, detail)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mAnchors As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBlocks As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCosts As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHTML As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mNextAnchor As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mNextCost As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mNextID As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPersisted As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSession As WakeSession
	#tag EndProperty


	#tag Constant, Name = kExpandLimit, Type = Double, Dynamic = False, Default = \"2000000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPersistedLimit, Type = Double, Dynamic = False, Default = \"4000000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPreviewCharacters, Type = Double, Dynamic = False, Default = \"6000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPreviewLines, Type = Double, Dynamic = False, Default = \"40", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
