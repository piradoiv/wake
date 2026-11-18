#tag Class
Protected Class WakeCLI
	#tag Method, Flags = &h21
		Private Sub AddCost(item As JSONItem, g As WakeUsageGroup)
		  Var estimate As WakeCostEstimate = Estimate(g)
		  If estimate <> Nil And estimate.PricedTokens > 0 Then
		    item.Value("cost_usd") = estimate.AmountUSD
		    item.Value("cost_complete") = estimate.IsComplete
		  Else
		    item.Value("cost_usd") = Nil
		    item.Value("cost_complete") = False
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddModels(item As JSONItem, g As WakeUsageGroup)
		  // Each model's token counts, so a script can price them itself.
		  Var models As New JSONItem
		  For Each key As Variant In g.ByModel.Keys
		    Var u As WakeTokenUsage = WakeTokenUsage(g.ByModel.Value(key).ObjectValue)
		    Var m As New JSONItem
		    m.Value("input_tokens") = u.InputTokens
		    m.Value("output_tokens") = u.OutputTokens
		    m.Value("cache_write_tokens") = u.CacheWriteTokens
		    m.Value("cache_write_1h_tokens") = u.CacheWrite1hTokens
		    m.Value("cache_read_tokens") = u.CacheReadTokens
		    models.Value(key.StringValue) = m
		  Next
		  item.Value("models") = models
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddPeriod(root As JSONItem)
		  // The period and project every JSON answer names. "to" is the last day included.
		  root.Value("from") = DayValue(mSince)
		  root.Value("to") = If(mUntil Is Nil, DayValue(Clock), DayValue(mUntil.SubtractInterval(0, 0, 1)))
		  If mProject Is Nil Then
		    root.Value("project") = Nil
		  Else
		    root.Value("project") = mProject.Path
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub AddRate(keys() As String, labels() As String, kinds() As String, befores() As Double, afters() As Double, key As String, label As String, kind As String, before As Double, after As Double)
		  keys.Add(key)
		  labels.Add(label)
		  kinds.Add(kind)
		  befores.Add(before)
		  afters.Add(after)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function CallsHelp() As String
		  Var lines() As String
		  lines.Add("Usage: wake calls --key KEY [--by GROUP] [--since PERIOD] [--until DAY] [--project P]")
		  lines.Add("                  [--limit N] [--snippets] [--json] [--all] [--no-index]")
		  lines.Add("")
		  lines.Add("The most expensive tool calls of one group from wake usage, most tokens first, each with")
		  lines.Add("its session id (see wake sessions) to find it in its transcript.")
		  lines.Add("")
		  lines.Add("  --by GROUP      intent (default), tool, file-type, command or file, as in wake usage.")
		  lines.Add("  --key KEY       The group: an intent's label or key (Re-read, re-read, Line range…), a")
		  lines.Add("                  tool, a command, or a file (relative to --project or the current folder).")
		  lines.Add(CommonOptions)
		  Var defaultLimit As Integer = kDefaultLimit
		  lines.Add("  --limit N       Calls to show. Default " + defaultLimit.ToString + ", 0 for all.")
		  lines.Add("  --snippets      Add what each call asked for (its command or input), from the transcript.")
		  lines.Add("  --json          JSON instead of a table, with the transcript path of each call.")
		  Return String.FromArray(lines, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function ChangeText(before As Double, after As Double, kind As String) As String
		  // Shares change in percentage points, everything else in percent.
		  If before < 0 Or after < 0 Then Return ""
		  If kind = "share" Then
		    Var points As Double = (after - before) * 100
		    Return If(points >= 0, "+", "−") + Abs(points).ToString(Locale.Raw, "0.0") + " pts"
		  End If
		  If before = 0 Then Return If(after = 0, "0%", "new")
		  Var change As Double = (after / before - 1) * 100
		  Return If(change >= 0, "+", "−") + Abs(change).ToString(Locale.Raw, "0") + "%"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Clock() As DateTime
		  Return If(CurrentTime Is Nil, DateTime.Now, CurrentTime)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function CommandHelp(command As String) As String
		  // A command's help, or "" when there's no such command.
		  Select Case command
		  Case "usage"
		    Return UsageHelp
		  Case "report"
		    Return ReportHelp
		  Case "calls"
		    Return CallsHelp
		  Case "sessions"
		    Return SessionsHelp
		  Case "compare"
		    Return CompareHelp
		  End Select
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function CommonOptions() As String
		  // The options every command takes, for its help.
		  Var lines() As String
		  lines.Add("  --since PERIOD  Start: today, yesterday, 7d, 4w, 3m or 1y (each counting today), a date")
		  lines.Add("                  (2026-11-01) or all. Days are local. Default 7d.")
		  lines.Add("  --until DAY     Last day included: a date, today or yesterday. 7d, 4w… end where that")
		  lines.Add("                  period starts, so --since 14d --until 7d is the week before last.")
		  lines.Add("  --project P     One project: its path, a folder inside it (. is the current folder), or")
		  lines.Add("                  its name. Default: every project.")
		  lines.Add("  --all           Include the projects hidden in Wake.")
		  lines.Add("  --no-index      Use the index as it is, without reading new transcripts first.")
		  Return String.FromArray(lines, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function CompareHelp() As String
		  Var lines() As String
		  lines.Add("Usage: wake compare --at DAY [--days N] [--project P] [--json] [--all] [--no-index]")
		  lines.Add("       wake compare --before FIRST..LAST --after FIRST..LAST [--project P] [--json] …")
		  lines.Add("")
		  lines.Add("Two periods side by side, to see whether a change (an instruction file, a tool, a habit)")
		  lines.Add("helped. Totals swing with how much work each period had, so it compares rates: tokens per")
		  lines.Add("session and per prompt, tool calls per prompt, tokens per call, and the share of tokens that")
		  lines.Add("went to carrying long sessions, to reads that led nowhere and to each intent. Lower is better,")
		  lines.Add("except for the intents' shares, which add up to 100% and show where tool tokens moved.")
		  lines.Add("Sessions count in the period they started in, since a session started before a change")
		  lines.Add("didn't have it. With few sessions on a side, it says the difference may be chance.")
		  lines.Add("")
		  lines.Add("  --at DAY        The day of the change: compares the --days before it with the days from")
		  lines.Add("                  it on (up to today).")
		  lines.Add("  --days N        Days on each side of --at. Default 14.")
		  lines.Add("  --before R      The period before, as FIRST..LAST (2026-11-01..2026-11-14), both included.")
		  lines.Add("  --after R       The period after, the same way.")
		  lines.Add("  --project P     One project: its path, a folder inside it (. is the current folder), or")
		  lines.Add("                  its name. Default: every project.")
		  lines.Add("  --json          JSON instead of a table, with the exact rates.")
		  lines.Add("  --all           Include the projects hidden in Wake.")
		  lines.Add("  --no-index      Use the index as it is, without reading new transcripts first.")
		  Return String.FromArray(lines, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(indexFile As FolderItem, roots() As WakeIndexRoot)
		  // indexFile Nil keeps the index in memory. roots are the folders a command indexes first.
		  Self.IndexFile = indexFile
		  Self.Roots = roots
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CostText(g As WakeUsageGroup) As String
		  Return WakeFormat.Cost(Estimate(g))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function DayText(d As DateTime) As String
		  Return d.Year.ToString(Locale.Raw, "0000") + "-" + d.Month.ToString(Locale.Raw, "00") + "-" + d.Day.ToString(Locale.Raw, "00")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function DayValue(d As DateTime) As Variant
		  // A day for JSON, or null.
		  If d Is Nil Then Return Nil
		  Return DayText(d)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Estimate(g As WakeUsageGroup) As WakeCostEstimate
		  If Not HasPrices Then Return Nil
		  Return Prices.Estimate(g.ByModel)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Fail(message As String, code As Integer = 1) As Integer
		  mErrors.Add(message)
		  Return code
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FindProject(catalog As WakeCatalog, text As String, ByRef project As WakeProjectInfo) As String
		  // The project that text names: its path, a path inside it (relative paths and "." start
		  // at WorkingFolder), or its name. Hidden projects count too, since they're asked for by
		  // name. Returns an error message, or "" when exactly one project matches.
		  Var wasIncluding As Boolean = catalog.IncludeHidden
		  catalog.IncludeHidden = True
		  Var projects() As WakeProjectInfo = catalog.Projects(True)
		  catalog.IncludeHidden = wasIncluding
		  
		  Var t As String = text.Trim
		  If t = "" Then Return "--project needs a path or a name."
		  
		  Var isPath As Boolean = t = "." Or t.IndexOf("/") >= 0 Or t.IndexOf("\") >= 0
		  If isPath And Not IsAbsolute(t) Then
		    If WorkingFolder = "" Then Return "The current folder is unknown, so --project needs a full path."
		    If t = "." Then
		      t = WorkingFolder
		    Else
		      If t.BeginsWith("./") Then t = t.Middle(2)
		      t = WorkingFolder + If(WorkingFolder.EndsWith("/"), "", "/") + t
		    End If
		  End If
		  While t.Length > 1 And (t.EndsWith("/") Or t.EndsWith("\"))
		    t = t.Left(t.Length - 1)
		  Wend
		  
		  Var matches() As WakeProjectInfo
		  If isPath Then
		    // The project the path is in: the longest project path it starts with.
		    Var longest As Integer
		    For Each p As WakeProjectInfo In projects
		      If p.Path = "" Then Continue
		      If t = p.Path Or t.BeginsWith(p.Path + "/") Or t.BeginsWith(p.Path + "\") Then
		        If p.Path.Length > longest Then
		          matches.RemoveAll
		          longest = p.Path.Length
		        End If
		        If p.Path.Length = longest Then matches.Add(p)
		      End If
		    Next
		  Else
		    For Each p As WakeProjectInfo In projects
		      If p.Name = t Then matches.Add(p)
		    Next
		  End If
		  
		  If matches.Count = 1 Then
		    project = matches(0)
		    Return ""
		  End If
		  
		  Var lines() As String
		  If matches.Count = 0 Then
		    lines.Add("No project matches """ + text + """. Projects Wake knows, most recent first:")
		    For i As Integer = 0 To Min(projects.LastIndex, kMaxProjectsListed - 1)
		      lines.Add("  " + projects(i).Path)
		    Next
		    Var more As Integer = projects.Count - kMaxProjectsListed
		    If more > 0 Then lines.Add("  … and " + more.ToString + " more")
		  Else
		    lines.Add("""" + text + """ matches " + matches.Count.ToString + " projects. Pass one of these paths instead:")
		    For Each p As WakeProjectInfo In matches
		      lines.Add("  " + p.Path + " (" + p.AgentID + ")")
		    Next
		  End If
		  Return String.FromArray(lines, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function GroupHeader(by As String) As String
		  Select Case by
		  Case "file-type"
		    Return "Tool and file type"
		  Case "command"
		    Return "Command"
		  Else
		    Return by.Titlecase
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function HasPrices() As Boolean
		  Return Prices <> Nil And Prices.Models.Count > 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IntentKey(text As String) As String
		  // The intent key that text names, as a key ("re-read") or a label ("Re-read"), or "".
		  For Each key As String In kIntentKeys.ToArray(" ")
		    If text = key Or text = WakeCallPattern.Label(key) Then Return key
		  Next
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function IsAbsolute(path As String) As Boolean
		  // "/x" on macOS and Linux, "C:\x" or "\\server" on Windows.
		  If path.BeginsWith("/") Or path.BeginsWith("\\") Then Return True
		  Return path.Length >= 3 And path.Middle(1, 2) = ":\"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function IsToolGrouping(by As String) As Boolean
		  Return kToolGroupings.ToArray(" ").IndexOf(by) >= 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function IsUsageGrouping(by As String) As Boolean
		  Return kUsageGroupings.ToArray(" ").IndexOf(by) >= 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function MainHelp() As String
		  Var lines() As String
		  lines.Add("wake: where AI coding agents spent their tokens, from Wake's local index of their transcripts.")
		  lines.Add("")
		  lines.Add("Usage: wake <command> [options]")
		  lines.Add("")
		  lines.Add("Commands:")
		  lines.Add("  report    Where the tokens went, with what to change: the place to start.")
		  lines.Add("  usage     Tokens and cost for a period, by project, model, day, session, tool, file type,")
		  lines.Add("            shell command, file or intent (what a tool call was for).")
		  lines.Add("  calls     The most expensive tool calls of one group from wake usage.")
		  lines.Add("  sessions  The sessions of a period, with their totals.")
		  lines.Add("  compare   Two periods side by side, as rates, to see whether a change helped.")
		  lines.Add("  help      This help, or a command's: wake help usage (or wake usage --help).")
		  lines.Add("")
		  lines.Add("Every command first brings the index up to date with new transcripts, which can take a")
		  lines.Add("few seconds after a lot of new work (--no-index skips it). Wake only reads transcripts:")
		  lines.Add("it never changes them, and nothing leaves the computer.")
		  lines.Add("")
		  lines.Add("By default output holds figures, paths and ids only. --snippets adds text from the")
		  lines.Add("transcripts (commands, prompts, titles), which may come from other projects.")
		  lines.Add("")
		  lines.Add("Exit codes: 0 done, 1 bad arguments, 2 index unavailable.")
		  Return String.FromArray(lines, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Measure(fromTime As DateTime, untilTime As DateTime) As Dictionary
		  // The figures compare works from: the sessions that started in the period (each with its
		  // whole totals) and the tool calls made in it. Raises DatabaseException.
		  Var m As New Dictionary
		  Var sessions() As WakeSessionInfo = mCatalog.Sessions("", ProjectID, False, fromTime, untilTime)
		  Var prompts As Integer
		  Var tokens, carried As Int64
		  Var priced As New WakeUsageGroup
		  For Each s As WakeSessionInfo In sessions
		    prompts = prompts + s.PromptCount
		    tokens = tokens + s.TotalUsage.Total
		    carried = carried + s.CarriedTokens
		    If HasPrices Then
		      Var g As WakeUsageGroup = mCatalog.SessionUsage(s.ID)
		      For Each model As Variant In g.ByModel.Keys
		        priced.Add(model.StringValue, WakeTokenUsage(g.ByModel.Value(model).ObjectValue))
		      Next
		    End If
		  Next
		  m.Value("sessions") = sessions.Count
		  m.Value("prompts") = prompts
		  m.Value("tokens") = tokens
		  m.Value("carried") = carried
		  If HasPrices Then
		    Var estimate As WakeCostEstimate = Prices.Estimate(priced.ByModel)
		    If estimate.PricedTokens > 0 Then m.Value("cost") = estimate.AmountUSD
		  End If
		  
		  Var calls As Integer
		  Var toolTokens, nowhere As Int64
		  For Each g As WakeToolUsageGroup In mCatalog.ToolUsage(WakeCatalog.ToolGroupings.Pattern, fromTime, WakeCatalog.ToolGroupings.Tool, "", ProjectID, untilTime)
		    calls = calls + g.Calls
		    toolTokens = toolTokens + g.AddedTokens + g.CarriedTokens
		    nowhere = nowhere + g.NowhereTokens
		    m.Value("intent:" + g.Key) = g.AddedTokens + g.CarriedTokens
		  Next
		  m.Value("calls") = calls
		  m.Value("tool_tokens") = toolTokens
		  m.Value("nowhere") = nowhere
		  Return m
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function NewJSON(by As String, since As DateTime, untilTime As DateTime, project As WakeProjectInfo) As JSONItem
		  // The fields every usage answer starts with. "to" is the last day included.
		  Var root As New JSONItem
		  root.Value("command") = "usage"
		  root.Value("by") = by
		  root.Value("from") = DayValue(since)
		  root.Value("to") = If(untilTime Is Nil, DayValue(If(CurrentTime Is Nil, DateTime.Now, CurrentTime)), DayValue(untilTime.SubtractInterval(0, 0, 1)))
		  If project Is Nil Then
		    root.Value("project") = Nil
		  Else
		    root.Value("project") = project.Path
		  End If
		  root.Value("estimated") = IsToolGrouping(by)
		  Return root
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function OpenCatalog(args As WakeCLIArgs) As Integer
		  // Opens (and updates) the index and finds --project, into mIndex, mCatalog, mProject and
		  // mScope. Returns -1 when the command can go on, otherwise its exit code.
		  mIndex = OpenIndex(Not args.Has("no-index"))
		  If mIndex Is Nil Then Return 2
		  
		  Try
		    mCatalog = New WakeCatalog(mIndex)
		    mCatalog.HiddenProjects = HiddenProjects
		    mCatalog.IncludeHidden = args.Has("all")
		    
		    If args.Has("project") Then
		      Var problem As String = FindProject(mCatalog, args.Value("project"), mProject)
		      If problem <> "" Then Return Fail(problem)
		    End If
		  Catch err As DatabaseException
		    Return Fail("Could not read Wake's index: " + err.Message, 2)
		  End Try
		  
		  If mProject <> Nil Then
		    mScope = mProject.Path
		  ElseIf Not mCatalog.IncludeHidden And HiddenProjects <> Nil And HiddenProjects.Count > 0 Then
		    mScope = "every project but the " + HiddenProjects.Count.ToString + " hidden in Wake (--all includes them)"
		  Else
		    mScope = "every project"
		  End If
		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function OpenIndex(update As Boolean) As WakeIndex
		  // The index, brought up to date with Roots first unless update is False. Nil when it can't
		  // be opened, with the reason in the error output.
		  Var index As New WakeIndex(IndexFile)
		  Try
		    index.Open
		  Catch err As DatabaseException
		    mErrors.Add("Could not open Wake's index: " + err.Message)
		    Return Nil
		  Catch err As IOException
		    mErrors.Add("Could not open Wake's index: " + err.Message)
		    Return Nil
		  End Try
		  
		  If Not update Then Return index
		  
		  Var indexer As New WakeIndexer(index)
		  For Each root As WakeIndexRoot In Roots
		    indexer.AddRoot(root)
		  Next
		  
		  Try
		    Var result As WakeIndexRunResult = indexer.Run
		    If result.FilesFailed > 0 Then
		      mErrors.Add("Note: " + result.FilesFailed.ToString + If(result.FilesFailed = 1, " transcript", " transcripts") + _
		      " could not be indexed, so their sessions are missing.")
		    End If
		  Catch err As DatabaseException
		    mErrors.Add("Note: could not bring the index up to date (" + err.Message + "), so it may miss recent sessions.")
		  End Try
		  
		  Return index
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function Pad(text As String, width As Integer, alignRight As Boolean) As String
		  Var gap As Integer = width - text.Length
		  If gap <= 0 Then Return text
		  Var parts() As String
		  parts.ResizeTo(gap)
		  Var spaces As String = String.FromArray(parts, " ")
		  Return If(alignRight, spaces + text, text + spaces)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseLimit(args As WakeCLIArgs, ByRef limit As Integer) As Boolean
		  Var defaultLimit As Integer = kDefaultLimit
		  Var limitText As String = args.Value("limit", defaultLimit.ToString)
		  limit = limitText.ToInteger
		  If limit.ToString = limitText.Trim And limit >= 0 Then Return True
		  mErrors.Add("--limit needs a whole number, 0 for every row.")
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseRange(text As String, name As String, ByRef fromTime As DateTime, ByRef untilTime As DateTime) As Boolean
		  // "A..B": the start of A to the end of B, as --since and --until read them.
		  Var parts() As String = text.ToArray("..")
		  Var ok As Boolean = parts.Count = 2
		  If ok Then ok = WakeCLIArgs.ParseStart(parts(0), Clock, fromTime) And fromTime <> Nil
		  If ok Then ok = WakeCLIArgs.ParseEnd(parts(1), Clock, untilTime)
		  If ok Then ok = untilTime.SecondsFrom1970 > fromTime.SecondsFrom1970
		  If Not ok Then mErrors.Add("--" + name + " """ + text + """ isn't a range. Use FIRST..LAST, as dates (2026-11-01..2026-11-14), both days included.")
		  Return ok
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PeriodText(since As DateTime, untilTime As DateTime) As String
		  // "2026-11-12 to 2026-11-18", "all time", "from 2026-11-01" or "until 2026-10-31".
		  If since Is Nil And untilTime Is Nil Then Return "all time"
		  If untilTime Is Nil Then
		    Var today As DateTime = If(CurrentTime Is Nil, DateTime.Now, CurrentTime)
		    If DayText(since) = DayText(today) Then Return "today (" + DayText(since) + ")"
		    Return DayText(since) + " to " + DayText(today)
		  End If
		  Var lastDay As String = DayText(untilTime.SubtractInterval(0, 0, 1))
		  If since Is Nil Then Return "until " + lastDay
		  If DayText(since) = lastDay Then Return lastDay
		  Return DayText(since) + " to " + lastDay
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Prepare(args As WakeCLIArgs) As Integer
		  // Reads the period, opens (and updates) the index and finds the project, into mSince, mUntil,
		  // mIndex, mCatalog, mProject and mScope. Returns -1 when the command can go on, otherwise its
		  // exit code. RunCommand closes the index.
		  mSince = Nil
		  mUntil = Nil
		  mProject = Nil
		  
		  Var now As DateTime = Clock
		  If Not WakeCLIArgs.ParseStart(args.Value("since", "7d"), now, mSince) Then
		    Return Fail("--since """ + args.Value("since") + """ isn't a period. Use today, yesterday, 7d, 4w, 3m, 1y, a date (2026-11-01) or all.")
		  End If
		  If args.Has("until") And Not WakeCLIArgs.ParseEnd(args.Value("until"), now, mUntil) Then
		    Return Fail("--until """ + args.Value("until") + """ isn't a day. Use today, yesterday, 7d, 4w, 3m, 1y or a date (2026-11-01).")
		  End If
		  If mSince <> Nil And mUntil <> Nil And mUntil.SecondsFrom1970 <= mSince.SecondsFrom1970 Then
		    Return Fail("--until must come after --since.")
		  End If
		  
		  Return OpenCatalog(args)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ProjectID() As Integer
		  Return If(mProject Is Nil, 0, mProject.ID)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function RateText(value As Double, kind As String) As String
		  If value < 0 Then Return "—"
		  Select Case kind
		  Case "share"
		    Var percent As Double = value * 100
		    Return percent.ToString(Locale.Raw, "0.0") + "%"
		  Case "tokens"
		    Return WakeFormat.Tokens(Round(value))
		  Case "usd"
		    Return WakeFormat.USD(value)
		  Case "count"
		    Return Round(value).ToString(Locale.Raw, "0")
		  Else
		    Return value.ToString(Locale.Raw, "0.0")
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function Ratio(m As Dictionary, part As String, whole As String) As Double
		  // part / whole, or -1 when whole is 0 (nothing to compare).
		  Var w As Double = m.Lookup(whole, 0).DoubleValue
		  If w <= 0 Then Return -1
		  Return m.Lookup(part, 0).DoubleValue / w
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function ReportHelp() As String
		  Var lines() As String
		  lines.Add("Usage: wake report [--since PERIOD] [--until DAY] [--project P] [--snippets] [--all] [--no-index]")
		  lines.Add("")
		  lines.Add("Where the tokens went, as Markdown: totals, then a section per intent (what the tool calls")
		  lines.Add("were for) with what to change, the files it cost most on and its most expensive calls, then")
		  lines.Add("the reads that led nowhere and the sessions that carried most. The same report as File →")
		  lines.Add("Export Report in Wake. A good place to start.")
		  lines.Add("")
		  lines.Add(CommonOptions)
		  lines.Add("  --snippets      Include text from the transcripts: the calls' commands, session titles")
		  lines.Add("                  and prompts. Without it, calls show their tool, file and session id.")
		  Return String.FromArray(lines, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Run(args() As String) As Integer
		  // Runs one command line (without the program's name). What it prints goes to Output and
		  // ErrorOutput, one line per element joined with line feeds. Returns the exit code.
		  mLines.RemoveAll
		  mErrors.RemoveAll
		  
		  Var code As Integer = RunCommand(args)
		  
		  Output = String.FromArray(mLines, &u0A)
		  ErrorOutput = String.FromArray(mErrors, &u0A)
		  Return code
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunCalls(args As WakeCLIArgs) As Integer
		  // The most expensive calls of one group of wake usage.
		  Var by As String = args.Value("by", "intent").Lowercase
		  If Not IsToolGrouping(by) Then Return Fail("--by " + by + " isn't a tool grouping. Use " + kToolGroupings.ReplaceAll(" ", ", ") + ".")
		  If Not args.Has("key") Or args.Value("key").Trim = "" Then
		    Return Fail("wake calls needs --key: the group to list, as wake usage --by " + by + " names it.")
		  End If
		  
		  Var key As String = args.Value("key").Trim
		  If by = "intent" Then
		    key = IntentKey(key)
		    If key = "" Then Return Fail("--key """ + args.Value("key") + """ isn't an intent. Use one of: " + kIntentKeys.ReplaceAll(" ", ", ") + ".")
		  End If
		  
		  Var limit As Integer
		  If Not ParseLimit(args, limit) Then Return 1
		  
		  Var code As Integer = Prepare(args)
		  If code >= 0 Then Return code
		  
		  // A relative file starts at the project, or else at the working folder.
		  If by = "file" And Not IsAbsolute(key) Then
		    Var folder As String = If(mProject Is Nil, WorkingFolder, mProject.Path)
		    If folder <> "" Then key = folder + If(folder.EndsWith("/"), "", "/") + If(key.BeginsWith("./"), key.Middle(2), key)
		  End If
		  
		  Var calls() As WakeToolCallInfo
		  Var callLimit As Integer = kNoLimit
		  If limit > 0 Then callLimit = limit
		  Try
		    calls = mCatalog.ToolCalls(ToolGrouping(by), key, mSince, callLimit, ProjectID, mUntil)
		  Catch err As DatabaseException
		    Return Fail("Could not read Wake's index: " + err.Message, 2)
		  End Try
		  
		  Var snippets As Boolean = args.Has("snippets")
		  If args.Has("json") Then
		    Var root As New JSONItem
		    root.Value("command") = "calls"
		    root.Value("by") = by
		    root.Value("key") = key
		    AddPeriod(root)
		    Var rows As New JSONItem("[]")
		    For Each c As WakeToolCallInfo In calls
		      Var item As New JSONItem
		      item.Value("time") = TimeValue(c.Timestamp)
		      item.Value("tool") = c.ToolName
		      item.Value("intent") = c.PatternKey
		      item.Value("target") = c.TargetPath
		      item.Value("added_tokens") = c.AddedTokens
		      item.Value("reread_tokens") = c.CarriedTokens
		      item.Value("total_tokens") = c.AddedTokens + c.CarriedTokens
		      item.Value("led_nowhere") = c.LedNowhere
		      If c.Session <> Nil Then
		        item.Value("session") = c.Session.UID
		        item.Value("transcript") = c.Session.FilePath
		        item.Value("project") = c.Session.ProjectPath
		      End If
		      If c.Session <> Nil And c.EventSessionUID <> c.Session.UID Then item.Value("subagent") = c.EventSessionUID
		      item.Value("seq") = c.Sequence
		      If snippets Then item.Value("summary") = c.Description
		      AddCost(item, c.Usage)
		      rows.Add(item)
		    Next
		    root.Value("rows") = rows
		    root.Value("prices_set") = HasPrices
		    mLines.Add(root.ToString)
		    Return 0
		  End If
		  
		  Var label As String = If(by = "intent", WakeCallPattern.Label(key), ShownPath(key))
		  mLines.Add("Calls in " + by + " """ + label + """, " + PeriodText(mSince, mUntil) + ", " + mScope + _
		  ". Most tokens first; tokens per call are estimates (≈).")
		  If calls.Count = 0 Then
		    mLines.Add("No calls in this group and period. wake usage --by " + by + " lists the groups.")
		    Return 0
		  End If
		  mLines.Add("")
		  
		  Var headers() As String = Array("#", "Time", "≈ Total", "≈ Added", "Tool", "Intent", "Target", "Session")
		  If HasPrices Then headers.Add("Cost")
		  Var cells() As String
		  For Each header As String In headers
		    cells.Add(header)
		  Next
		  For i As Integer = 0 To calls.LastIndex
		    Var c As WakeToolCallInfo = calls(i)
		    Var number As Integer = i + 1
		    cells.Add(number.ToString)
		    cells.Add(TimeText(c.Timestamp))
		    cells.Add(WakeFormat.Tokens(c.AddedTokens + c.CarriedTokens))
		    cells.Add(WakeFormat.Tokens(c.AddedTokens))
		    cells.Add(c.ToolName)
		    cells.Add(WakeCallPattern.Label(c.PatternKey) + If(c.LedNowhere, ", led nowhere", ""))
		    cells.Add(ShownPath(c.TargetPath))
		    cells.Add(If(c.Session Is Nil, "", c.Session.UID))
		    If HasPrices Then cells.Add(CostText(c.Usage))
		  Next
		  mLines.Add(Table(cells, headers.Count, Array(1, 4, 5, 6, 7)))
		  
		  If snippets Then
		    mLines.Add("")
		    mLines.Add("What each call asked for:")
		    For i As Integer = 0 To calls.LastIndex
		      Var number As Integer = i + 1
		      mLines.Add("  " + number.ToString + ". " + WakeFormat.OneLine(calls(i).Description, kSnippetLength))
		    Next
		  End If
		  
		  If limit > 0 And calls.Count = limit Then
		    mLines.Add("")
		    mLines.Add("Showing the first " + limit.ToString + " (--limit 0 for all). --snippets adds what each call asked for.")
		  ElseIf Not snippets Then
		    mLines.Add("")
		    mLines.Add("--snippets adds what each call asked for.")
		  End If
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunCommand(args() As String) As Integer
		  Var command As String = If(args.Count > 0, args(0), "")
		  Var rest() As String
		  For i As Integer = 1 To args.LastIndex
		    rest.Add(args(i))
		  Next
		  
		  Select Case command
		  Case "", "help", "--help", "-h"
		    If command = "help" And rest.Count > 0 Then
		      Var help As String = CommandHelp(rest(0))
		      If help = "" Then Return Fail("No help for """ + rest(0) + """: it isn't a command. " + kCommandList)
		      mLines.Add(help)
		      Return 0
		    End If
		    mLines.Add(MainHelp)
		    Return 0
		    
		  Case "--version"
		    mLines.Add("wake " + If(Version = "", "(unknown version)", Version))
		    Return 0
		  End Select
		  
		  If CommandHelp(command) = "" Then Return Fail("Unknown command """ + command + """. " + kCommandList)
		  
		  // Every command takes the period, project and index options; the rest are its own.
		  Var flags() As String = Array("help", "all", "no-index")
		  Var values() As String = Array("project")
		  If command <> "compare" Then
		    values.Add("since")
		    values.Add("until")
		  End If
		  Select Case command
		  Case "compare"
		    flags.Add("json")
		    values.Add("before")
		    values.Add("after")
		    values.Add("at")
		    values.Add("days")
		  Case "usage"
		    flags.Add("json")
		    values.Add("by")
		    values.Add("limit")
		  Case "report"
		    flags.Add("snippets")
		  Case "calls"
		    flags.Add("json")
		    flags.Add("snippets")
		    values.Add("by")
		    values.Add("key")
		    values.Add("limit")
		  Case "sessions"
		    flags.Add("json")
		    flags.Add("snippets")
		    values.Add("limit")
		  End Select
		  
		  Var parsed As New WakeCLIArgs(rest, flags, values)
		  If parsed.Error <> "" Then Return Fail(parsed.Error + " See wake " + command + " --help.")
		  If parsed.Has("help") Then
		    mLines.Add(CommandHelp(command))
		    Return 0
		  End If
		  If parsed.Words.Count > 0 Then
		    Return Fail("wake " + command + " takes only options, not """ + parsed.Words(0) + """. See wake " + command + " --help.")
		  End If
		  
		  Var code As Integer
		  Select Case command
		  Case "usage"
		    code = RunUsage(parsed)
		  Case "report"
		    code = RunReport(parsed)
		  Case "calls"
		    code = RunCalls(parsed)
		  Case "sessions"
		    code = RunSessions(parsed)
		  Case "compare"
		    code = RunCompare(parsed)
		  End Select
		  
		  If mIndex <> Nil Then mIndex.Close
		  mIndex = Nil
		  mCatalog = Nil
		  Return code
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunCompare(args As WakeCLIArgs) As Integer
		  // Two periods as rates, so a change shows apart from how much work each period had.
		  Var beforeFrom, beforeUntil, afterFrom, afterUntil As DateTime
		  If args.Has("at") Then
		    If args.Has("before") Or args.Has("after") Then Return Fail("Use either --at or --before and --after, not both.")
		    Var at As DateTime
		    If Not WakeCLIArgs.ParseStart(args.Value("at"), Clock, at) Or at Is Nil Then
		      Return Fail("--at """ + args.Value("at") + """ isn't a day. Use the date of the change, such as 2026-11-10.")
		    End If
		    Var daysText As String = args.Value("days", "14")
		    Var days As Integer = daysText.ToInteger
		    If days.ToString <> daysText.Trim Or days < 1 Then Return Fail("--days needs a whole number of days, 1 or more.")
		    beforeFrom = at.SubtractInterval(0, 0, days)
		    beforeUntil = at
		    afterFrom = at
		    afterUntil = at.AddInterval(0, 0, days)
		    Var tomorrow As DateTime
		    Call WakeCLIArgs.ParseEnd("today", Clock, tomorrow)
		    If afterUntil.SecondsFrom1970 > tomorrow.SecondsFrom1970 Then afterUntil = tomorrow
		    If afterUntil.SecondsFrom1970 <= afterFrom.SecondsFrom1970 Then Return Fail("--at is in the future, so there's nothing after it yet.")
		  ElseIf args.Has("before") And args.Has("after") Then
		    If Not ParseRange(args.Value("before"), "before", beforeFrom, beforeUntil) Then Return 1
		    If Not ParseRange(args.Value("after"), "after", afterFrom, afterUntil) Then Return 1
		  Else
		    Return Fail("wake compare needs --at DAY, or --before and --after. See wake compare --help.")
		  End If
		  
		  Var code As Integer = OpenCatalog(args)
		  If code >= 0 Then Return code
		  
		  Var before, after As Dictionary
		  Try
		    before = Measure(beforeFrom, beforeUntil)
		    after = Measure(afterFrom, afterUntil)
		  Catch err As DatabaseException
		    Return Fail("Could not read Wake's index: " + err.Message, 2)
		  End Try
		  
		  // The rates: key, label, kind, and the value on each side (-1 when there's nothing to divide).
		  Var keys() As String
		  Var labels() As String
		  Var kinds() As String
		  Var befores() As Double
		  Var afters() As Double
		  AddRate(keys, labels, kinds, befores, afters, "sessions", "Sessions", "count", before.Value("sessions").DoubleValue, after.Value("sessions").DoubleValue)
		  AddRate(keys, labels, kinds, befores, afters, "prompts", "Prompts", "count", before.Value("prompts").DoubleValue, after.Value("prompts").DoubleValue)
		  AddRate(keys, labels, kinds, befores, afters, "tokens_per_session", "Tokens per session", "tokens", Ratio(before, "tokens", "sessions"), Ratio(after, "tokens", "sessions"))
		  AddRate(keys, labels, kinds, befores, afters, "tokens_per_prompt", "Tokens per prompt", "tokens", Ratio(before, "tokens", "prompts"), Ratio(after, "tokens", "prompts"))
		  If before.HasKey("cost") Or after.HasKey("cost") Then
		    AddRate(keys, labels, kinds, befores, afters, "cost_per_session", "Cost per session", "usd", Ratio(before, "cost", "sessions"), Ratio(after, "cost", "sessions"))
		  End If
		  AddRate(keys, labels, kinds, befores, afters, "carried_share", "≈ Carried, share of tokens", "share", Ratio(before, "carried", "tokens"), Ratio(after, "carried", "tokens"))
		  AddRate(keys, labels, kinds, befores, afters, "calls_per_prompt", "Tool calls per prompt", "number", Ratio(before, "calls", "prompts"), Ratio(after, "calls", "prompts"))
		  AddRate(keys, labels, kinds, befores, afters, "tokens_per_call", "≈ Tokens per tool call", "tokens", Ratio(before, "tool_tokens", "calls"), Ratio(after, "tool_tokens", "calls"))
		  AddRate(keys, labels, kinds, befores, afters, "led_nowhere_share", "Reads that led nowhere, share of tool tokens", "share", Ratio(before, "nowhere", "tool_tokens"), Ratio(after, "nowhere", "tool_tokens"))
		  For Each intent As String In kIntentKeys.ToArray(" ")
		    If Not before.HasKey("intent:" + intent) And Not after.HasKey("intent:" + intent) Then Continue
		    AddRate(keys, labels, kinds, befores, afters, intent + "_share", WakeCallPattern.Label(intent) + ", share of tool tokens", "share", _
		    Ratio(before, "intent:" + intent, "tool_tokens"), Ratio(after, "intent:" + intent, "tool_tokens"))
		  Next
		  
		  Var fewest As Integer = Min(before.Value("sessions").IntegerValue, after.Value("sessions").IntegerValue)
		  
		  If args.Has("json") Then
		    Var root As New JSONItem
		    root.Value("command") = "compare"
		    If mProject Is Nil Then
		      root.Value("project") = Nil
		    Else
		      root.Value("project") = mProject.Path
		    End If
		    Var sides As New JSONItem
		    sides.Value("from") = DayText(beforeFrom)
		    sides.Value("to") = DayText(beforeUntil.SubtractInterval(0, 0, 1))
		    root.Value("before") = sides
		    sides = New JSONItem
		    sides.Value("from") = DayText(afterFrom)
		    sides.Value("to") = DayText(afterUntil.SubtractInterval(0, 0, 1))
		    root.Value("after") = sides
		    root.Value("few_sessions") = fewest < kFewSessions
		    Var rows As New JSONItem("[]")
		    For i As Integer = 0 To keys.LastIndex
		      Var item As New JSONItem
		      item.Value("key") = keys(i)
		      item.Value("label") = labels(i)
		      item.Value("before") = Nil
		      item.Value("after") = Nil
		      If befores(i) >= 0 Then item.Value("before") = befores(i)
		      If afters(i) >= 0 Then item.Value("after") = afters(i)
		      rows.Add(item)
		    Next
		    root.Value("rates") = rows
		    mLines.Add(root.ToString)
		    Return 0
		  End If
		  
		  mLines.Add("Before: " + PeriodText(beforeFrom, beforeUntil) + ". After: " + PeriodText(afterFrom, afterUntil) + ". " + mScope.Left(1).Uppercase + mScope.Middle(1) + ".")
		  mLines.Add("Sessions count by when they started (with their whole totals), tool calls by when they were made.")
		  mLines.Add("Lower is better for every rate down to reads that led nowhere. The intents' shares add up to 100%: they show where tool tokens moved.")
		  mLines.Add("")
		  Var cells() As String = Array("Rate", "Before", "After", "Change")
		  For i As Integer = 0 To keys.LastIndex
		    cells.Add(labels(i))
		    cells.Add(RateText(befores(i), kinds(i)))
		    cells.Add(RateText(afters(i), kinds(i)))
		    cells.Add(If(kinds(i) = "count", "", ChangeText(befores(i), afters(i), kinds(i))))
		  Next
		  mLines.Add(Table(cells, 4, Array(0)))
		  
		  If fewest < kFewSessions Then
		    mLines.Add("")
		    mLines.Add("Only " + fewest.ToString + If(fewest = 1, " session", " sessions") + " on one side: too few to tell a change from chance. Compare longer periods.")
		  End If
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunReport(args As WakeCLIArgs) As Integer
		  // WakeTokenReport, as File → Export Report writes it, for the period and project.
		  Var code As Integer = Prepare(args)
		  If code >= 0 Then Return code
		  
		  Try
		    Var label As String = PeriodText(mSince, mUntil)
		    If mProject <> Nil Then label = label + ", " + mProject.Path
		    Var report As New WakeTokenReport(mCatalog, Prices, mSince, label)
		    report.ProjectID = ProjectID
		    report.UntilTime = mUntil
		    report.LeaveOutText = Not args.Has("snippets")
		    mLines.Add(report.Markdown.TrimRight)
		  Catch err As DatabaseException
		    Return Fail("Could not read Wake's index: " + err.Message, 2)
		  End Try
		  
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunSessions(args As WakeCLIArgs) As Integer
		  // The sessions that started in the period, newest first, with their whole totals.
		  Var limit As Integer
		  If Not ParseLimit(args, limit) Then Return 1
		  
		  Var code As Integer = Prepare(args)
		  If code >= 0 Then Return code
		  
		  Var sessions() As WakeSessionInfo
		  Var usage() As WakeUsageGroup
		  Var shown As Integer
		  Var total As Int64
		  Try
		    sessions = mCatalog.Sessions("", ProjectID, False, mSince, mUntil)
		    shown = If(limit = 0, sessions.Count, Min(limit, sessions.Count))
		    For i As Integer = 0 To sessions.LastIndex
		      total = total + sessions(i).TotalUsage.Total
		      If i < shown Then usage.Add(mCatalog.SessionUsage(sessions(i).ID))
		    Next
		  Catch err As DatabaseException
		    Return Fail("Could not read Wake's index: " + err.Message, 2)
		  End Try
		  
		  Var snippets As Boolean = args.Has("snippets")
		  If args.Has("json") Then
		    Var root As New JSONItem
		    root.Value("command") = "sessions"
		    AddPeriod(root)
		    Var rows As New JSONItem("[]")
		    For i As Integer = 0 To shown - 1
		      Var s As WakeSessionInfo = sessions(i)
		      Var item As New JSONItem
		      item.Value("session") = s.UID
		      item.Value("transcript") = s.FilePath
		      item.Value("project") = s.ProjectPath
		      item.Value("agent") = s.AgentID
		      item.Value("started") = TimeValue(s.StartTime)
		      item.Value("ended") = TimeValue(s.EndTime)
		      item.Value("prompts") = s.PromptCount
		      item.Value("subagents") = s.SubagentCount
		      item.Value("tokens") = s.TotalUsage.Total
		      item.Value("carried_tokens") = s.CarriedTokens
		      item.Value("starting_context_tokens") = s.StartingContextTokens
		      If snippets Then item.Value("title") = s.DisplayTitle
		      AddCost(item, usage(i))
		      AddModels(item, usage(i))
		      rows.Add(item)
		    Next
		    root.Value("rows") = rows
		    root.Value("row_count") = sessions.Count
		    root.Value("prices_set") = HasPrices
		    mLines.Add(root.ToString)
		    Return 0
		  End If
		  
		  mLines.Add("Sessions started " + PeriodText(mSince, mUntil) + ", " + mScope + ". Newest first, each with its whole totals.")
		  If sessions.Count = 0 Then
		    mLines.Add("No sessions started in this period.")
		    Return 0
		  End If
		  mLines.Add("")
		  
		  Var headers() As String = Array("#", "Started")
		  If mProject Is Nil Then headers.Add("Project")
		  headers.Add("Prompts")
		  headers.Add("Tokens")
		  headers.Add("≈ Carried")
		  If HasPrices Then headers.Add("Cost")
		  headers.Add("Session")
		  Var cells() As String
		  For Each header As String In headers
		    cells.Add(header)
		  Next
		  For i As Integer = 0 To shown - 1
		    Var s As WakeSessionInfo = sessions(i)
		    Var number As Integer = i + 1
		    cells.Add(number.ToString)
		    cells.Add(TimeText(s.StartTime))
		    If mProject Is Nil Then cells.Add(WakeFormat.ProjectName(s.ProjectPath))
		    cells.Add(s.PromptCount.ToString)
		    cells.Add(WakeFormat.Tokens(s.TotalUsage.Total))
		    cells.Add(If(s.CarriedTokens > 0, WakeFormat.Tokens(s.CarriedTokens), ""))
		    If HasPrices Then cells.Add(CostText(usage(i)))
		    cells.Add(s.UID)
		  Next
		  Var leftColumns() As Integer = Array(1, headers.LastIndex)
		  If mProject Is Nil Then leftColumns.Add(2)
		  mLines.Add(Table(cells, headers.Count, leftColumns))
		  
		  If snippets Then
		    mLines.Add("")
		    mLines.Add("Titles:")
		    For i As Integer = 0 To shown - 1
		      Var number As Integer = i + 1
		      mLines.Add("  " + number.ToString + ". " + sessions(i).DisplayTitle)
		    Next
		  End If
		  
		  mLines.Add("")
		  Var parts() As String
		  parts.Add("Total: " + sessions.Count.ToString + If(sessions.Count = 1, " session, ", " sessions, ") + WakeFormat.Tokens(total) + " tokens")
		  If shown < sessions.Count Then parts.Add("showing " + shown.ToString + " (--limit 0 for all)")
		  If Not snippets Then parts.Add("--snippets adds their titles")
		  mLines.Add(String.FromArray(parts, " · "))
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunUsage(args As WakeCLIArgs) As Integer
		  Var by As String = args.Value("by", "project").Lowercase
		  If Not IsUsageGrouping(by) And Not IsToolGrouping(by) Then
		    Return Fail("--by " + by + " isn't a grouping. Use " + kUsageGroupings.ReplaceAll(" ", ", ") + ", " + kToolGroupings.ReplaceAll(" ", ", ") + ".")
		  End If
		  
		  Var limit As Integer
		  If Not ParseLimit(args, limit) Then Return 1
		  
		  Var code As Integer = Prepare(args)
		  If code >= 0 Then Return code
		  
		  Try
		    If IsUsageGrouping(by) Then
		      WriteUsage(mCatalog.Usage(UsageGrouping(by), mSince, "", ProjectID, mUntil), by, mSince, mUntil, mProject, mScope, limit, args.Has("json"))
		    Else
		      WriteToolUsage(mCatalog.ToolUsage(ToolGrouping(by), mSince, WakeCatalog.ToolGroupings.Tool, "", ProjectID, mUntil), _
		      by, mSince, mUntil, mProject, mScope, limit, args.Has("json"))
		    End If
		  Catch err As DatabaseException
		    Return Fail("Could not read Wake's index: " + err.Message, 2)
		  End Try
		  
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function SessionsHelp() As String
		  Var lines() As String
		  lines.Add("Usage: wake sessions [--since PERIOD] [--until DAY] [--project P] [--limit N] [--snippets]")
		  lines.Add("                     [--json] [--all] [--no-index]")
		  lines.Add("")
		  lines.Add("The sessions that started in the period, newest first, each with its whole totals:")
		  lines.Add("prompts, tokens (subagents included), what its turns carried and its cost.")
		  lines.Add("")
		  lines.Add(CommonOptions)
		  Var defaultLimit As Integer = kDefaultLimit
		  lines.Add("  --limit N       Sessions to show. Default " + defaultLimit.ToString + ", 0 for all.")
		  lines.Add("  --snippets      Add each session's title (or first prompt), from the transcript.")
		  lines.Add("  --json          JSON instead of a table, with transcript paths and tokens per model.")
		  Return String.FromArray(lines, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ShownPath(path As String) As String
		  // A path as text output shows it: relative to the project when one was asked for.
		  If mProject Is Nil Then Return path
		  Return WakeCore.RelativePath(path, mProject.Path)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function Table(cells() As String, columns As Integer, leftColumns() As Integer) As String
		  // cells row by row, the first row being the headers, as aligned text: the columns in
		  // leftColumns (text) on the left, the others (figures) on the right.
		  Var widths() As Integer
		  widths.ResizeTo(columns - 1)
		  For i As Integer = 0 To cells.LastIndex
		    widths(i Mod columns) = Max(widths(i Mod columns), cells(i).Length)
		  Next
		  
		  Var lines() As String
		  Var parts() As String
		  For i As Integer = 0 To cells.LastIndex
		    Var column As Integer = i Mod columns
		    parts.Add(Pad(cells(i), widths(column), leftColumns.IndexOf(column) < 0))
		    If column = columns - 1 Then
		      lines.Add(String.FromArray(parts, "  ").TrimRight)
		      parts.RemoveAll
		    End If
		  Next
		  Return String.FromArray(lines, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function TimeText(d As DateTime) As String
		  // "2026-11-18 10:04", local.
		  If d Is Nil Then Return ""
		  Return d.SQLDateTime.Left(16)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function TimeValue(d As DateTime) As Variant
		  // A moment for JSON, as local "YYYY-MM-DD HH:MM:SS", or null.
		  If d Is Nil Then Return Nil
		  Return d.SQLDateTime
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function ToolGrouping(by As String) As WakeCatalog.ToolGroupings
		  Select Case by
		  Case "file-type"
		    Return WakeCatalog.ToolGroupings.ToolAndFileType
		  Case "command"
		    Return WakeCatalog.ToolGroupings.Command
		  Case "file"
		    Return WakeCatalog.ToolGroupings.File
		  Case "intent"
		    Return WakeCatalog.ToolGroupings.Pattern
		  Else
		    Return WakeCatalog.ToolGroupings.Tool
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function UsageGrouping(by As String) As WakeCatalog.UsageGroupings
		  Select Case by
		  Case "model"
		    Return WakeCatalog.UsageGroupings.Model
		  Case "day"
		    Return WakeCatalog.UsageGroupings.Day
		  Case "session"
		    Return WakeCatalog.UsageGroupings.Session
		  Else
		    Return WakeCatalog.UsageGroupings.Project
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function UsageHelp() As String
		  Var lines() As String
		  lines.Add("Usage: wake usage [--since PERIOD] [--until DAY] [--project P] [--by GROUP] [--limit N]")
		  lines.Add("                  [--json] [--all] [--no-index]")
		  lines.Add("")
		  lines.Add("Tokens, and cost when prices are set in Wake, for a period: one row per group, most")
		  lines.Add("tokens first (days newest first). Subagents count toward the session that started them.")
		  lines.Add("")
		  lines.Add(CommonOptions)
		  lines.Add("  --by GROUP      What a row is. Every token the agents' responses used, by")
		  lines.Add("                    project (default), model, day or session.")
		  lines.Add("                  Tool calls, with tokens estimated (≈) per call, by")
		  lines.Add("                    tool, file-type (tool and file type), command (shell program),")
		  lines.Add("                    file, or intent (line range, whole file, search, re-read…, with advice).")
		  Var defaultLimit As Integer = kDefaultLimit
		  lines.Add("  --limit N       Rows to show. Default " + defaultLimit.ToString + ", 0 for all.")
		  lines.Add("  --json          JSON instead of a table, with exact counts and tokens per model.")
		  lines.Add("")
		  lines.Add("Columns:")
		  lines.Add("  Tokens       Input, output, cache writes and cache reads.")
		  lines.Add("  ≈ Carried    Tokens spent re-sending earlier turns of a long session (beyond its")
		  lines.Add("               starting context). /clear between unrelated tasks avoids them.")
		  lines.Add("  ≈ Added      What the calls' results added to the context.")
		  lines.Add("  ≈ Re-read    What later responses paid to send those results again.")
		  lines.Add("  Read again   Reads of a file already read in the same context, with no edit between.")
		  lines.Add("  Led nowhere  Tokens of reads whose file nothing later edited or mentioned.")
		  lines.Add("  Cost         Wake's estimate from the prices set in Wake, ≥ when some models have none.")
		  Return String.FromArray(lines, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteFooter(rowCount As Integer, shown As Integer, total As WakeUsageGroup, totalText As String, json As JSONItem)
		  If json <> Nil Then
		    json.Value("row_count") = rowCount
		    json.Value("prices_set") = HasPrices
		    Var totals As New JSONItem
		    totals.Value("tokens") = total.Total.Total
		    AddCost(totals, total)
		    json.Value("total") = totals
		    mLines.Add(json.ToString)
		    Return
		  End If
		  
		  Var parts() As String
		  parts.Add("Total: " + totalText)
		  If HasPrices Then parts.Add(CostText(total))
		  If shown < rowCount Then parts.Add("showing " + shown.ToString + " of " + rowCount.ToString + " rows (--limit 0 for all)")
		  mLines.Add(String.FromArray(parts, " · "))
		  If Not HasPrices Then mLines.Add("No prices are set in Wake, so there are no costs.")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteToolUsage(groups() As WakeToolUsageGroup, by As String, since As DateTime, untilTime As DateTime, project As WakeProjectInfo, scope As String, limit As Integer, asJSON As Boolean)
		  Var shown As Integer = If(limit = 0, groups.Count, Min(limit, groups.Count))
		  Var total As New WakeUsageGroup
		  Var added, carried As Int64
		  For Each g As WakeToolUsageGroup In groups
		    added = added + g.AddedTokens
		    carried = carried + g.CarriedTokens
		    For Each key As Variant In g.ByModel.Keys
		      total.Add(key.StringValue, WakeTokenUsage(g.ByModel.Value(key).ObjectValue))
		    Next
		  Next
		  
		  If asJSON Then
		    Var root As JSONItem = NewJSON(by, since, untilTime, project)
		    Var rows As New JSONItem("[]")
		    For i As Integer = 0 To shown - 1
		      Var g As WakeToolUsageGroup = groups(i)
		      Var item As New JSONItem
		      item.Value("key") = g.Key
		      item.Value("label") = g.Label
		      If by = "intent" Then item.Value("advice") = WakeCallPattern.Advice(g.Key)
		      item.Value("calls") = g.Calls
		      item.Value("sessions") = g.SessionCount
		      item.Value("added_tokens") = g.AddedTokens
		      item.Value("reread_tokens") = g.CarriedTokens
		      item.Value("total_tokens") = g.AddedTokens + g.CarriedTokens
		      item.Value("reads") = g.Reads
		      item.Value("reads_again") = g.Rereads
		      item.Value("line_range_reads") = g.LineRangeReads
		      item.Value("reads_led_nowhere") = g.NowhereReads
		      item.Value("led_nowhere_tokens") = g.NowhereTokens
		      AddCost(item, g)
		      AddModels(item, g)
		      rows.Add(item)
		    Next
		    root.Value("rows") = rows
		    WriteFooter(groups.Count, shown, total, "", root)
		    Return
		  End If
		  
		  Var note As String = If(by = "file" And project <> Nil, " Paths are relative to the project.", "")
		  mLines.Add("Tool calls by " + by + ", " + PeriodText(since, untilTime) + ", " + scope + ". Tokens per call are estimates (≈)." + note)
		  If groups.Count = 0 Then
		    mLines.Add("No tool calls in this period.")
		    Return
		  End If
		  mLines.Add("")
		  
		  Var isFile As Boolean = by = "file"
		  Var headers() As String = Array(GroupHeader(by), "Calls", "Sessions", "≈ Added", "≈ Re-read", "≈ Total")
		  If isFile Then headers.Add("Read again")
		  headers.Add("Led nowhere")
		  If HasPrices Then headers.Add("Cost")
		  
		  Var cells() As String
		  For Each header As String In headers
		    cells.Add(header)
		  Next
		  For i As Integer = 0 To shown - 1
		    Var g As WakeToolUsageGroup = groups(i)
		    // Within one project, its files are named from its folder: shorter, and what the agent
		    // working there would type.
		    Var label As String = g.Label
		    If isFile And project <> Nil Then label = WakeCore.RelativePath(label, project.Path)
		    cells.Add(If(label = "", "(none)", label))
		    cells.Add(g.Calls.ToString)
		    cells.Add(g.SessionCount.ToString)
		    cells.Add(WakeFormat.Tokens(g.AddedTokens))
		    cells.Add(WakeFormat.Tokens(g.CarriedTokens))
		    cells.Add(WakeFormat.Tokens(g.AddedTokens + g.CarriedTokens))
		    If isFile Then cells.Add(If(g.Reads > 0, g.Rereads.ToString + " of " + g.Reads.ToString, ""))
		    cells.Add(If(g.Reads > 0 And g.NowhereTokens > 0, WakeFormat.Tokens(g.NowhereTokens), ""))
		    If HasPrices Then cells.Add(CostText(g))
		  Next
		  mLines.Add(Table(cells, headers.Count, Array(0)))
		  mLines.Add("")
		  
		  If by = "intent" Then
		    Var advice() As String
		    For i As Integer = 0 To shown - 1
		      Var text As String = WakeCallPattern.Advice(groups(i).Key)
		      If text <> "" Then advice.Add("  " + groups(i).Label + ": " + text)
		    Next
		    If advice.Count > 0 Then
		      mLines.Add("What would send less:")
		      mLines.Add(String.FromArray(advice, &u0A))
		      mLines.Add("")
		    End If
		  End If
		  
		  WriteFooter(groups.Count, shown, total, "≈" + WakeFormat.Tokens(added) + " added, ≈" + WakeFormat.Tokens(carried) + " re-read", Nil)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteUsage(groups() As WakeUsageGroup, by As String, since As DateTime, untilTime As DateTime, project As WakeProjectInfo, scope As String, limit As Integer, asJSON As Boolean)
		  Var shown As Integer = If(limit = 0, groups.Count, Min(limit, groups.Count))
		  Var total As New WakeUsageGroup
		  Var carried As Int64
		  For Each g As WakeUsageGroup In groups
		    carried = carried + g.CarriedTokens
		    For Each key As Variant In g.ByModel.Keys
		      total.Add(key.StringValue, WakeTokenUsage(g.ByModel.Value(key).ObjectValue))
		    Next
		  Next
		  
		  If asJSON Then
		    Var root As JSONItem = NewJSON(by, since, untilTime, project)
		    Var rows As New JSONItem("[]")
		    For i As Integer = 0 To shown - 1
		      Var g As WakeUsageGroup = groups(i)
		      Var item As New JSONItem
		      item.Value("key") = g.Key
		      item.Value("label") = g.Label
		      If by = "project" Or by = "session" Then item.Value("agent") = g.AgentID
		      item.Value("sessions") = g.SessionCount
		      item.Value("tokens") = g.Total.Total
		      item.Value("carried_tokens") = g.CarriedTokens
		      AddCost(item, g)
		      AddModels(item, g)
		      rows.Add(item)
		    Next
		    root.Value("rows") = rows
		    WriteFooter(groups.Count, shown, total, "", root)
		    Return
		  End If
		  
		  mLines.Add("Tokens by " + by + ", " + PeriodText(since, untilTime) + ", " + scope + ".")
		  If groups.Count = 0 Then
		    mLines.Add("No usage in this period.")
		    Return
		  End If
		  mLines.Add("")
		  
		  Var headers() As String = Array(GroupHeader(by), "Sessions", "Tokens", "≈ Carried")
		  If HasPrices Then headers.Add("Cost")
		  
		  Var cells() As String
		  For Each header As String In headers
		    cells.Add(header)
		  Next
		  For i As Integer = 0 To shown - 1
		    Var g As WakeUsageGroup = groups(i)
		    cells.Add(If(g.Label = "", "(unknown)", g.Label))
		    cells.Add(g.SessionCount.ToString)
		    cells.Add(WakeFormat.Tokens(g.Total.Total))
		    cells.Add(If(g.CarriedTokens > 0, WakeFormat.Tokens(g.CarriedTokens), ""))
		    If HasPrices Then cells.Add(CostText(g))
		  Next
		  mLines.Add(Table(cells, headers.Count, Array(0)))
		  mLines.Add("")
		  
		  WriteFooter(groups.Count, shown, total, WakeFormat.Tokens(total.Total.Total) + " tokens, ≈" + WakeFormat.Tokens(carried) + " carried", Nil)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		#tag Note
			The time commands take as now, for tests. Nil means the clock's.
		#tag EndNote
		CurrentTime As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		ErrorOutput As String
	#tag EndProperty

	#tag Property, Flags = &h0
		HiddenProjects As WakeHiddenProjects
	#tag EndProperty

	#tag Property, Flags = &h0
		IndexFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCatalog As WakeCatalog
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mErrors() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIndex As WakeIndex
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLines() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mProject As WakeProjectInfo
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScope As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSince As DateTime
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUntil As DateTime
	#tag EndProperty

	#tag Property, Flags = &h0
		Output As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Prices As WakePriceTable
	#tag EndProperty

	#tag Property, Flags = &h0
		Roots() As WakeIndexRoot
	#tag EndProperty

	#tag Property, Flags = &h0
		Version As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The folder relative --project paths start at, usually the shell's current folder.
		#tag EndNote
		WorkingFolder As String
	#tag EndProperty


	#tag Constant, Name = kCommandList, Type = String, Dynamic = False, Default = \"Commands: report\x2C usage\x2C calls\x2C sessions\x2C compare\x2C help. See wake --help.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDefaultLimit, Type = Double, Dynamic = False, Default = \"20", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFewSessions, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kIntentKeys, Type = String, Dynamic = False, Default = \"line-range section whole-file search listing edit web run re-read other", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaxProjectsListed, Type = Double, Dynamic = False, Default = \"15", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoLimit, Type = Double, Dynamic = False, Default = \"1000000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSnippetLength, Type = Double, Dynamic = False, Default = \"300", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolGroupings, Type = String, Dynamic = False, Default = \"tool file-type command file intent", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUsageGroupings, Type = String, Dynamic = False, Default = \"project model day session", Scope = Private
	#tag EndConstant


End Class
#tag EndClass
