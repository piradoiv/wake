# Wake roadmap

This is the working plan for Wake v0.1 (deadline: early December 2026, for a
live demo). Read it at the start of every session and continue from the first
unchecked milestone. Tick a milestone off in the same commit that finishes it.

## Milestones

Each milestone ends with the tests passing and a commit.

- [x] **0. Repo setup.** git, MIT license, README, `.gitignore`, agent notes.
- [x] **1. Formats, fixtures and test harness.** `docs/FORMATS.md`, synthetic
  fixtures in `tests/fixtures`, vendored XojoUnit with XML output, FTS5 spike
  (it works in Xojo's SQLite).
- [x] **2. Core model and Claude Code parser.** `Wake/Core`: WakeSession,
  WakeEvent, WakeTokenUsage, WakeParseReport, WakeCore helpers, IAgentParser,
  AgentRegistry, ClaudeCodeParser. 14 parser tests.
- [x] **3. Discovery and index.** `Wake/Core/Index`: WakeIndex (SQLite schema
  and writes), WakeIndexer (scan, skip unchanged, re-index changed, remove
  vanished), WakeFolders (app data folder, default roots, custom folders in
  `folders.json`). `WakeIndexThread` (outside Core) runs it on a preemptive
  thread, and `App.StartIndexing` starts it at launch. 10 index tests, 33
  in total. On real data (76 sessions, about 124 MB) the first run takes 3.4 s,
  a run with nothing changed takes 0.01 s, and the index is 21 MB.
- [x] **4. Browse UI.** `WakeCatalog` (Core) reads projects, sessions,
  per-model usage and subagents from the index, as `WakeProjectInfo` and
  `WakeSessionInfo`. `WakeFormat` formats durations, token counts and titles.
  `MainWindow`: agents → projects source list, sessions list (started,
  duration, title, agent, tokens, "Partial" badge; sorts by value), and a
  summary detail pane. "Show command-only sessions" is off by default.
  File → Refresh (Cmd+R) re-indexes. 41 tests.
- [x] **5. Session timeline.** `WakeTimeline` (Core) re-parses a transcript
  and renders one self-contained page: prompts and answers as cards, tool
  calls as collapsible `<details>`, edits as coloured diffs, subagents nested
  under their tool call, and the parse-report note. Blocks longer than 40
  lines or 6,000 characters show a preview, and the page asks for the rest
  (or for persisted tool output) through `executeInXojoSync`. `SessionWindow`
  shows it in a `DesktopHTMLViewer`. Open it by double-click, Return or
  File → Open Timeline (Cmd+O). 53 tests. On real data (78 sessions) the
  slowest page takes 0.24 s to parse and render, and the largest is 680 KB.
- [x] **6. Search.** `WakeCatalog.Search(WakeSearchQuery)` returns
  `WakeSearchHit`s (FTS5, best match first, at most 500) with a snippet whose
  matches are marked, filtered by agent, project, time range and event kind.
  `MainWindow` has a search field (Cmd+F) with kind and period popups. The
  source-list selection scopes the search, and hits replace the sessions list
  while there is text. Opening a hit scrolls the timeline to its event
  (`WakeTimeline.Anchor`, `wakeGoTo`). 62 tests. On real data (11,600 events)
  a query takes 1–45 ms, and two one-letter prefixes about 210 ms.
- [x] **7. Stats and prices.** The index keeps one `usage` row per model
  response, and `WakeCatalog.Usage` groups it by day (local time), project,
  model or session as `WakeUsageGroup`s split by model. `WakePriceTable`
  (`prices.json` in the app data folder) prices input, output, cache write,
  one-hour cache write and cache read per million tokens, and returns a
  `WakeCostEstimate` that lists the models with no price. `MainWindow` has a
  Cost column and an estimated cost per session and model; Window → Usage
  (Cmd+U) shows usage per day, project or model for a period; Window → Prices
  edits the table. 73 tests. On real data the totals per model and the
  number of days match a Python reference exactly.
- [x] **8. Markdown export and polish.** `WakeMarkdown` (Core) turns a parsed
  session into a report: summary table, tokens per model with estimated cost,
  prompts as quotes, every shell command in one `sh` block, and each file
  change as a fenced diff, subagents' work included and labelled. File →
  Export as Markdown (Cmd+E) in both windows. `WakeCore.LoadSession` now
  loads transcripts for the timeline and the export. 82 tests. On real data
  (80 sessions) the slowest export takes 0.13 s and the largest is 880 KB.
  README updated, and the new windows checked in the app.
- [x] **9. Glance stats.** `WakeGlanceTiles` (tinted stat tiles with an
  optional heading) and `WakeDayChart` (a bar per day, tooltip on hover) are
  drawn `DesktopCanvas` subclasses outside Core. The Usage window shows tiles
  for the period (cost, tokens, sessions, busiest day, cache hits) and a
  daily chart of cost, or tokens while no price is set. The main window shows
  tiles for the selected session, or totals for the selected agent or project,
  above the details, and a strip under the Tokens and Cost cells. 84 tests.
  Checked in the app in light and dark.
- [x] **10. Timeline header.** `SessionWindow` shows the same title and four
  tiles as the main window (cost, tokens, duration, prompts) in a native
  `WakeGlanceTiles` above the page, built by `WakeGlanceTiles.ShowSession`
  for both windows, with native Expand all and Collapse all buttons that call
  the page's `wakeAll`. The page itself has no header and doesn't depend on
  prices, so a price change only redraws the tiles. An earlier HTML copy of
  the tiles drifted from the native ones. `WakeSession.TotalUsageByModel`
  rolls up subagents for both the timeline and the export. 84 tests.
- [x] **11. Stats per event.** The parser records each model response as a
  `WakeResponse` (usage, time from the input it answered, the inputs it
  answered). `WakeSession.ComputeStats` estimates the tokens each input
  added to the context and how often later responses re-read them, and
  totals each turn on its prompt (subagents included, active time from
  `turn_duration`). The timeline shows a thin line per response (time,
  context in, output), and duration, ≈ added and ≈ re-read per tool call, and
  turn totals on prompts. Costs are empty slots filled by `wakeSetCosts` with
  `WakeTimeline.CostsJSON`, so the page still doesn't depend on prices.
  91 tests. On real data (12 sessions) the estimates match a Python reference
  exactly, and the slowest page takes 0.16 s.
- [x] **12. Where the tokens went.** The index keeps a `tool_usage` row per
  tool call and model, with the estimated tokens added and re-read, the
  shell program (`WakeEvent.ShellProgram`), the target path and its file
  type (`TargetPath`, `FileType`). `WakeCatalog.ToolUsage` groups them by
  tool, tool and file type, shell command or file as `WakeToolUsageGroup`s.
  The Usage window has these four groupings below the usual three, with
  calls, sessions, ≈ added, ≈ per call, ≈ re-read, ≈ total and cost. Schema 5.
  Schema 6 re-reads commands with quote-aware splitting. 93 tests. On real
  data (all projects) indexing takes 7.9 s and a query 8–14 ms. Shell
  commands on `.xojo_code` files were the largest group.

### Next: from "where the tokens went" to "what to do about it"

Goal: a developer sees that, say, `sed` is expensive and can tell *why* and
*what to change*. Everything stays generic (see the rule in `CLAUDE.md`):
patterns come from the shape of a call, never from a language or project.
Each milestone below is one session's work, ending with tests and a commit.

- [x] **13. Drill down to the calls.** `WakeCatalog.ToolCalls(grouping,
  key, fromTime, limit)` returns the calls of one tool group as
  `WakeToolCallInfo`s, most tokens first (default limit 500): top-level
  session, the event's own session uid and seq, time, tool, the event's
  summary, target, ≈ added, ≈ re-read and usage by model. `Description`
  adds the target when the summary is only the tool's name. In the Usage
  window, selecting a row of a tool grouping lists its calls in `CallsList`
  below it; double-clicking one opens its timeline at that event. The two
  lists share the space below the chart (`LayOutLists`, also on resize).
  94 tests.

- [x] **14. Group calls by intent.** `WakeCallPattern` (Core module)
  classifies each tool call from its shape: line range, section, whole
  file, search, listing, edit, web, run or other, with a `Label` and a
  generic `Advice` per key. `WakeSession.ComputeStats` sets `WakeEvent.
  Pattern` and `IsReread` (a read of a file already read in the same
  context with no edit in between). `WakeEvent.ResolvedTargetPath` joins
  relative shell paths to the session's folder (or a leading `cd`), and the
  index stores that as the target. `tool_usage` gains `pattern` and
  `is_reread` (schema 7). `ToolGroupings.Pattern` puts re-reads in their
  own group. "By intent" in the Usage window, with the advice as the
  label's tooltip and in the status line. The calls list has an Intent
  column (`WakeToolCallInfo.PatternKey`) for every grouping. Fixture session 7 is in its own
  root, `claude-code/patterns/`.
- [x] **15. Waste per file.** `WakeToolUsageGroup` gains `Reads`,
  `Rereads`, `LineRangeReads` and `ReadSessionCount`. `ToolUsage` takes an
  optional group of another grouping to stay within (`withinGrouping`,
  `withinKey`), such as the files of one intent. "By file" shows "Read
  again" (re-reads of reads, with share) and ≈ per read, and names files
  that share a name with as many parent folders as it takes
  (`WakeFormat.ShortPaths`); a selected file's status line reads "Read N
  times in M sessions, R of them again in the same session". "By intent"
  keeps sessions and ≈ per call: its re-reads are their own row, so "Read
  again" was always 0% or 100% there (seen in the app).
- [x] **16. Export the findings as tasks.** `WakeTokenReport` (Core) builds
  Markdown for a period: totals, then a section per intent (re-reads
  included) with ≈ tokens, share, cost when priced, the advice, the top 5
  files and the 3 most expensive calls fenced with `WakeMarkdown.Fence`.
  File → Export Report (Usage window only). 102 tests. On real data
  (6,035 calls) indexing takes 13.7 s (7.9 s at schema 6, on less data),
  and the report 0.23 s.

- [x] **17. Hide projects.** `WakeHiddenProjects` (Core) keeps hidden
  projects by agent and path in `hidden-projects.json`. `WakeCatalog`
  takes them (`HiddenProjects`, `IncludeHidden`): `Projects` leaves them out
  or marks `IsHidden`, and `Sessions`, `Search` and `Usage` across every
  project leave out their sessions. The main window hides or unhides the
  selected project from View → Hide Project or a right-click on its row,
  and View → Show Hidden Projects lists them again, dimmed. 104 tests.

- [x] **18. Live watch.** A `Timer` in `App` starts a quiet index run
  every 10 s when none is running (`StartIndexing(True)`). A quiet run shows
  no progress and updates the windows only when it indexed or removed files,
  or when the last run failed. A normal run asked for during a quiet one
  makes it report. Reloads keep the selection (by file, since ids change on
  re-index), the scroll of every list and which agents are collapsed; the
  Usage window keeps its selected group and call. View → Watch for Changes
  (on by default) is stored by `WakeSettings` in `settings.json`, which keeps
  keys it doesn't know. `WakeSessionInfo.FileModified` and `IsLive` (changed
  in the last 2 minutes) draw a "Live" badge, checked at paint time and
  repainted on every tick. An open timeline compares `WakeCore.FileSignature`
  after each run that changed files: its title and tiles take the index's
  latest figures at once (`WakeCatalog.SessionForFile`, `SessionUsage`),
  and the page shows "Session updated" with a Reload button, which scrolls
  back to where the page was. 108 tests.

- [x] **19. DesktopTable instead of DesktopListBox.** The seven list boxes
  (`MainWindow`: SourceList, SessionsList, DetailList, HitsList;
  `UsageWindow`: UsageList, CallsList; `PricesWindow`: PricesList) are
  `DesktopTable`s that keep their own rows (`DataSource = Nil`). Sorting,
  badges, collapsible agents, price editing, keys, double-click, borders and
  keeping selection and scroll on reload work as before (checked by eye).
  `DetailList` no longer selects rows. A `TableDataSource` can come later if
  the sessions list grows. 108 tests.

- [x] **20. Unified title bar (macOS).** The main and Usage windows have a
  unified bar, as Mail does: `WakeTitleBar` (declares on the `NSWindow`) turns
  on the full-size content view, a transparent title bar, the hidden title and
  the unified toolbar style, and the content starts at `WakeTitleBar.Height`.
  Their filters are `DesktopToolbar` DropDown items (`UsageToolbar`,
  `MainWindowToolbar`), icons only, which mirror the popups
  (`WakeTitleBar.MirrorPopup`): the popups stay the model and are what Windows
  and Linux show, with the toolbar hidden. `StyleToolbarItems` borders the
  items, so macOS 26 draws them in a Liquid Glass capsule, at 32 by 32 for a
  round hover. The main window's search is AppKit's `NSSearchToolbarItem`
  holding the `DesktopSearchField` (`AddSearchItem`). Empty parts of the bar
  drag the window and follow the double-click setting. Full screen works, as
  the items move to AppKit's overlay. The timeline and Prices windows keep
  the standard title bar. Checked by eye on macOS 26; Windows and Linux
  aren't checked. 108 tests.

- [x] **21. Context growth.** `WakeSession.ComputeStats` sets the
  session's `StartingContextTokens` (its first response's context) and, on
  each prompt, `TurnContextTokens`, `TurnCarriedTokens` and
  `TurnCarriedUsage` (as cache reads per model): every response of a turn
  re-sends the context from before the turn, beyond the starting context,
  until a compaction. `WakeResponse.TurnSequence` names its prompt. The
  index has a `turns` row per turn and model, and `sessions` gains
  `starting_context_tokens` and `carried_tokens` (schema 10).
  `WakeCatalog.Usage` fills `WakeUsageGroup.CarriedTokens`, and
  `LongSessions` returns `WakeLongSession`s with the first turn whose carried
  tokens outweighed its own work. "≈ Carried" in the sessions list, the
  detail pane and the Usage window's usage groupings (a ninth column the tool
  groupings drop), and on each prompt's turn line. `WakeContextChart` in the
  timeline header draws the context per response, compactions in orange,
  every other turn on a faint band (none when turns are under 4 px wide);
  pressing a point scrolls to its prompt. The report ends with "Long
  sessions". Fixture session 8 is in its own root, `claude-code/context/`.
  112 tests. On real data (121 files, 403 turns) 27% of all tokens were
  carried, 50–75% in the longest sessions, where carrying overtook the work
  by turns 2–5. Checked by eye.

- [x] **22. Reads that led nowhere.** `WakeSession.ComputeStats` sets
  `WakeEvent.LedNowhere` on a read (line range, section, whole file, re-reads
  included) when nothing later in the same context names its file: an
  answer, or a later tool call's input (edits, commands, subagent prompts).
  Reading the same file again doesn't count, and a name must stand alone
  (`util.h` isn't in `util.hpp`). Never flagged: a read whose result is an
  image (`WakeEvent.ResultHasImage`), and a read of a file outside the
  project folder that no prompt, answer or call named before it, such as a
  tool's saved output (`IsHandedFile`). `tool_usage.led_nowhere` (schema 12;
  11 had neither exception).
  `WakeToolUsageGroup` gains `NowhereReads` and `NowhereTokens`,
  `WakeToolCallInfo` gains `LedNowhere`. "By intent" and "By file" have a
  ninth column, "≈ Led nowhere" with its share of the group's tokens; the
  calls list a "Led nowhere" column; a file's status line counts them. The
  report has "Reads that led nowhere" with the top files
  (`WakeCallPattern.LedNowhereAdvice`). Fixture session 9 is in its own root,
  `claude-code/nowhere/`. 116 tests. On real data (1,125 reads) 181 led
  nowhere, ≈24M tokens, 6% of all tool tokens; whole files 13%, line ranges
  21%. Before the two exceptions it was 356: screenshots were nearly always
  flagged, as were saved outputs. Checked by eye.

- [ ] **23. Translucent sidebar (macOS).** The main window's source list sits
  on the sidebar material, as Finder and Mail do. Declares (in a module
  beside `WakeTitleBar`) put an `NSVisualEffectView` (sidebar material,
  behind-window blending, following the active state) under `SourceList`
  and turn off the backgrounds that `SourceList`'s own views draw, so the
  blur shows through, with its border turned off. Start with a test run that
  logs the class names of `SourceList.Handle`'s view and its subviews:
  nothing documents what `DesktopTable` is made of on macOS, and if it paints
  its own background through declares can't switch off, that's a roadblock
  to raise, not to work around. Only the translucent background is in scope:
  `SourceList` stays a regular `DesktopTable` (same selection, text and
  layout), so it carries over to Windows and Linux, which keep today's look.
  It doesn't have to match Mail exactly. Checked by eye in light, dark, and
  with the window inactive.
  **Blocked on Xojo:** tried and reverted. In light mode `DesktopTable` fills
  its own view with opaque white, in front of anything behind it, and
  returning True from `PaintCellBackground` doesn't remove the fill (see the
  `DesktopTable` gotcha). Dark mode worked. Pick this up again once Xojo
  can make the list transparent in both appearances. Skip it while blocked.

- [x] **24. Files view.** The main window gets a second view beside the
  sessions list: the files agents changed, for the source-list selection.
  A Sessions/Files switch sits in the toolbar on macOS (a real toolbar
  item, see Decisions) and in View → Sessions (Cmd+1) / Files (Cmd+2) on
  every platform. If `DesktopToolbar` can't make a two-segment item, that's
  a roadblock to raise, not to work around: fall back to two toggle
  buttons. The date menu, today only for search, filters both views
  (by a session's start for sessions, by the change's own time for files).
  The index gets a `file_changes` row per edit or write a session made,
  subagents included: session, seq, the turn's prompt seq, time, the path
  resolved and made relative to the project folder (absolute when outside
  it), the action (create, edit, write) and lines added and removed, from
  `structuredPatch` or the written content (schema bump). Only the agent's
  edit and write tools count, not shell commands. `WakeCatalog.ChangedFiles`
  returns `WakeChangedFile`s (path, edits, sessions, lines added and
  removed, reads, last changed, ≈ tokens spent on it). The list is a tree:
  folders sum their files, single-child folder chains collapse
  (`Wake/Core/Index`), and files outside the project folder go in a last
  "Outside the project" group. A project or agent selection lists each
  project as a top node. Columns: Name, Edits, Sessions, +/−, Reads, Last
  changed, ≈ Tokens; sorts by value. Files no longer on disk are grey (an
  existence check, nothing else is read). Selecting a file fills the detail
  pane with its summary and its changes, newest first: date, session title,
  the prompt on one line, +/−. Double-clicking a file opens its history
  (milestone 25); double-clicking a change opens its session timeline at
  that edit. A session's detail pane gains "Files changed", and clicking
  one switches to the Files view with it selected. Fixture: a session that
  creates, edits and rewrites files, one inside and one outside its folder,
  one with a subagent edit. Checked by eye.
  **Core done** (schema 13, 122 tests): the parser sets
  `WakeEvent.ChangeAction` (`kChangeCreate`, `kChangeEdit`, `kChangeWrite`),
  `ChangedLineCounts` counts the patch, failed calls don't count.
  `file_changes` keeps `target` (resolved, as in `tool_usage`) beside the
  relative `path`. `WakeCatalog.ChangedFiles(agent, project, from, session)`
  returns `WakeChangedFile`s, `FileChanges(project, target, from)` returns
  `WakeFileChangeInfo`s, and `WakeFileNode.Build` makes the tree (`Sort`
  keeps Outside last). Fixture session 10 is in `claude-code/changes/`.
  **UI, checked by eye:** `FilesList` (sorted by
  `WakeFileNode.Sort` from `ColumnHeaderPressed`, children added in
  `RowExpanded`, last folder opened first), `ShowFileDetail`, "Files
  changed" in a session's details (a click goes to the file), View →
  Sessions/Files, and `WakeCatalog.Sessions` takes the period.
  `DesktopToolbar` has no segmented item, so the switch is AppKit's
  `NSToolbarItemGroup` (`WakeTitleBar.AddViewSwitch`), made by the same
  delegate subclass as the search item. On real
  data (126 transcripts) 567 changes to 265 files, 118 of those files
  outside their project; 222 creates and 15 rewrites, as many as the Write
  results.

- [x] **25. File history.** A `FileHistoryWindow`, one per file, shows
  every change agents made to a file across sessions, oldest first: a page
  rendered by `WakeFileHistory` (Core) with the same rules as the timeline
  (self-contained, CSP `default-src 'none'`, transcript text escaped with
  `WakeTimeline.EscapeHTML`, diffs drawn as the timeline draws them, costs
  filled after load). It groups by session, then by prompt: the session's
  title and date, the prompt that asked for the change, each edit as a
  diff, and the agent's first answer after the edits as the "why", cut to
  a few lines with a "more" link. Changes made by subagents sit under the
  prompt that started the subagent, marked "subagent". A switch shows the
  reads of the file too, as one-line rows. Each group's header opens its
  session timeline at the first edit. The page re-parses only the sessions
  that changed the file. A header line says what the history can't show:
  the user's own edits, and whether a change is still in the file. Markdown
  export (Cmd+E) lists the prompts and diffs. Checked by eye.
  **Done, checked by eye** (130 tests): `WakeFileHistory`
  (Core) inherits `WakeTimeline`, whose page helpers (`Block` with optional
  preview limits, `ToolStats`, `TimeHTML`, `StyleSheet`, `ScriptSource`,
  `NewAnchor`, `LocalTime`) are now Protected. `AddSession` splits a parsed
  session into `WakeHistoryTurn`s of `WakeHistoryEntry`s (changes by the
  index's rule, reads by `WakeCallPattern.IsRead`, both by resolved path);
  `Load` parses each session of `WakeCatalog.FileChanges` once. Headers call
  `wakeOpen(id)` and `ChangeFor(id)` gives the session and event;
  `Anchor(uid, seq)` finds a change for milestone 26. Reads show only for
  the sessions that changed the file. `FileHistoryWindow` (a "Show reads"
  check box above the page) opens from a double-click in the Files view;
  `App.OpenTimeline` (moved from `MainWindow`) and `App.OpenFileHistory`
  reuse an open window. Fixture session 11 is in its own root,
  `claude-code/history/`. It doesn't watch for new changes yet.

- [x] **26. Line blame.** The file history window gets a Blame tab: the
  file as it is on disk now (read-only, capped in size, text files only),
  each line marked with the latest agent change whose added lines produce
  it, matched by text, nearest position first. Pressing a mark jumps to
  that change in the history. Lines no change accounts for read "not from
  an agent edit, or changed since". Stays a heuristic and says so. Tests
  for moved lines, repeated lines and edits that later edits overwrote.
  **Done, checked by eye** (138 tests): `WakeBlame` (Core)
  takes each change's patch oldest first. Removed lines cancel the nearest
  live line an earlier change added with that text; a create, or a write
  with no hunks, cancels everything. Positions come from hunk headers (or
  the line number for a whole-file write), and a patch built from the tool
  input drops the lines its old and new text share. `Blame` lets the latest
  change claim first, each added line one file line. `WakeFileHistory`
  reads the file in `Load` (`ReadFileOnDisk`, 512 KB cap, no NUL bytes,
  valid UTF-8; `UseFileText` for tests) and puts both views in one page,
  switched by in-page tabs (`wakeTab`, chosen over a native control). A
  mark calls `wakeJump(anchor)`; `wakeTab` tells the window, which greys
  out "Show reads" on Blame.

- [ ] **27. About window.** The classic About box: Wake → About Wake on
  macOS (a `DesktopApplicationMenuItem`, so it lands in the app menu), and
  a new Help → About Wake on Windows and Linux. One `AboutWindow`, fixed
  size, not resizable, reused if already open, closed with Cmd+W or Esc.
  It shows, centred: the app icon, "Wake", the version and build from
  `App.Version` (nothing hardcoded), the one-line description from the
  README, the copyright line (`© 2026 Ricardo Cruz`, as in the project's
  `LongVersion`), and "Reads transcripts read-only. No network, no
  telemetry." A link to `github.com/piradoiv/wake` opens in the default
  browser (`System.GotoURL`, which hands the URL to the browser; Wake itself
  still opens no connection). Below, an **Acknowledgements** section: built
  with Xojo; SQLite and its FTS5 search (public domain, no notice
  required); XojoUnit, © 2014-2021 Xojo, Inc., MIT, worded so it also
  tells the user that automated tests cover Wake ("Tested with XojoUnit",
  no count, which would drift). A License button (or
  disclosure) shows the full texts in a read-only scrolling field: Wake's
  `LICENSE`, then XojoUnit's `Wake/Tests/XojoUnit/LICENSE.txt`, whose MIT
  terms require the notice in every copy because the test classes are
  compiled into the app. The texts are read from the app's resources,
  copied there from those two files by a Copy Files build step (ask the
  maintainer to add it in the IDE), so there's one source for each and it
  can't drift. A last line: "Wake is not affiliated with Anthropic or the
  makers of the agents it reads." Before adding anything else to the
  acknowledgements, check what the build actually ships (vendored code,
  fonts, artwork not drawn for Wake); today that's only the above. Checked
  by eye in light and dark on macOS.

After v0.1: Codex CLI and Gemini CLI parsers, once real sessions exist on a
machine to inspect, and the console companion.

## Decisions

| Decision | Why |
|----------|-----|
| v0.1 supports **Claude Code only**. | No Codex sessions or Gemini install were available to inspect, and formats must come from real files, not memory. |
| **MIT** license. | Chosen by the maintainer. |
| Tests use **vendored XojoUnit**, with JUnit XML in `tests/results.xml`. | Chosen by the maintainer. XML lets agents read the results. |
| Slash commands, `!` shell commands, `isMeta` records and task notifications are **system events, not prompts**. | The person didn't type them as prompts. Counting them would distort prompt counts and "first prompt". |
| **Subagent tokens** are stored on the subagent and **rolled up** into the parent's total (`WakeSession.TotalUsage`). | The parent's cost should include the work it delegated, while the subagent stays inspectable on its own. |
| **Command-only sessions** (e.g. just `/clear`) are **hidden by default** in the browse UI. | 9 of 75 real sessions were like this, and they're noise. |
| Wake shows **its own cost estimate** from the price table, and the agent's `cost-state` figure **labelled "reported by agent"**. | Prices must not be hardcoded, but the agent's figure is a useful cross-check. |
| Events are ordered by **file order**, not by timestamp. | Timestamps go backwards often in real files. |
| The index is a **cache**. A different `WakeIndex.kSchemaVersion` drops and rebuilds it. No migrations. | The transcripts are the source of truth, and rebuilding takes seconds. |
| The `events` table holds a one-line **summary** per event, and search text goes into `events_fts`, cut to 64K characters per event. The timeline re-parses the transcript. Persisted tool output isn't indexed. | Keeps the index at about a sixth of the transcripts' size. |
| A session is re-indexed when the size or modification time of its file **or of its subagent files** changes. | Subagent transcripts are parsed with the parent. |
| Files that disappear, including ones under a custom folder that's no longer available, are **removed** from the index. | The index mirrors what's on disk. |
| **Live watch polls**: a quiet index run every 10 s, not file-system events. | A run with nothing changed takes about 10 ms, it reuses the indexer as is, and it works the same on every platform. |
| An open timeline **never reloads by itself**. It shows "Session updated" and a Reload button. | Reloading would lose the reader's place and open blocks while they read. |
| A session is **live** while its main transcript changed in the last 2 minutes. Subagent files don't count. | The index stores only the main file's time, and the badge is a hint, not a promise. |
| The window opens its index connection **only after an indexing run finishes**, and reloads after each run. | Opening it while the thread creates or rebuilds the schema would race it. A run with nothing changed takes about 10 ms, so the wait is invisible. |
| A session with no `cwd` (empty, or only a slash command) joins the project of **the other sessions in its folder**, if there are any. | Otherwise it shows up as a second project named after the encoded folder. |
| The timeline **opens in its own window** (`SessionWindow`), one per session. | It needs the full width for diffs and output, and two sessions can be compared side by side. |
| The timeline page has a **CSP of `default-src 'none'`** with inline style and script, and the viewer **cancels every navigation** after the page loads. | Transcripts are untrusted text. Nothing in them may load a remote resource or move the viewer off the page. |
| The timeline page holds **no amounts**. Its cost slots are filled by `wakeSetCosts` after load and after every price change. | Reloading the page would lose the scroll position and the open blocks. |
| Where the tokens went is a set of **groupings in the Usage window**, not its own window. | It shares the period, tiles and chart, and needs no new layout. |
| A shell command's **program** is the first word of its first line after `cd`, `export`, `source` and `VAR=value` parts, and its **target** is the last file-like word on that line. Words are split the way the shell would: quotes keep spaces, and only unquoted `&&`, `\|\|`, `\|`, `&`, `;`, `$(`, `(`, `)` and backticks start a new command. | Commands rarely say what they read in a structured way. This finds `sed`, `cat` and `grep` reads of a file, also in `f=$(grep …)`. Loops show up as `for`. |
| A call's **intent** comes only from its shape: the tool, the program and how it asks (`sed -n 10,80p` is a line range, `/a/,/b/` a section, `sed -n /x/p` a search, `sed -i` and `cat > f` an edit). Only the first command of a line counts. | The rule in `CLAUDE.md`: reports work for any language and project. |
| A **re-read** is any read (line range, section, whole file) of a file already read in the same context, unless an edit or write to it came in between. Compaction starts a new context. Re-reads are their own intent, not counted in their read's pattern. | The content is already in the context, so reading it again is the waste to show. After an edit or compaction, reading again is needed. |
| Index **targets are resolved** against the session's folder (or a leading `cd`). | Otherwise `src/a.c` and `/work/src/a.c` are two files, and re-reads across shell and Read are missed. |
| **≈ Carried** is counted per turn, against the context from before the turn and beyond the session's starting context, and only for the session's own responses. | The starting context (system prompt, tools) is paid in any session, so only what earlier turns left behind is the cost of a long session. Subagents start contexts of their own. |
| A read **led nowhere** when no later answer or tool call input in the same context names its file. It's a flag, not an intent, and thinking doesn't count. Image results and files the agent was handed (outside the project, named first by a tool's output) are never flagged. | Whether a read was used can't be seen, but a file the agent never names again, edits or hands on was most likely not needed. Names, not paths, so relative and absolute mentions both count. A screenshot or a generated file name is used without being named, so the rule can't judge it. |
| Token figures per tool call are **estimates, marked ≈**, from context growth between responses, split among the inputs by text length. | Transcripts record usage only per response, so this is the only per-result signal. Attachments and reminders Wake can't see inflate it a little. |
| Search words match as **prefixes**, `"quoted text"` as a phrase, and every term must match. Every term is quoted, so FTS5 operators are plain words. | Search as you type needs partial words, and no input may raise an FTS5 syntax error. |
| Search lives **in the main window**, scoped by the source-list selection, not in its own window. | Agent and project filters come for free, and the detail pane shows the hit's session. |
| Search runs **on the main thread**, 250 ms after the last keystroke. | Queries take milliseconds on real data. |
| Wake ships **no prices**. Until the user sets one, costs read "no price set", and a partly priced total reads "≥ $x". | Prices change and must not be hardcoded. "≥" keeps a partial sum from looking complete. |
| **One-hour cache writes** are counted apart (`CacheWrite1hTokens`, part of `CacheWriteTokens`) and have their own price, which falls back to the cache-write price when empty. | 98% of cache writes in real data are one-hour writes, which cost 2× input instead of 1.25×. One price for both would be far off. |
| A **dated model name** (`claude-haiku-4-5-20251001`) uses the price of its undated name when it has none of its own. Other prefixes never match. | `claude-opus-5` must not price `claude-opus-5-5`. |
| Usage **per day** groups responses by their own timestamp in the **local time zone**, at query time. Subagent usage counts toward the session that started it. | A session can span midnight, and the time zone can change between runs. |
| The Usage window covers **every agent and project**, not the main window's selection. | It's a summary across everything. Per project is one of its groupings. |
| **Hidden projects** are hidden from the main window only (sidebar, agent totals, sessions, search). The Usage window still counts them. They are keyed by agent and path, not index id. | Hiding is about clutter, and the spending totals must stay complete. Index ids change on every rebuild. |
| A Markdown export lists **prompts, commands and file changes**, not the answers or tool output. | It's a record of what was asked and what changed. The timeline has the rest. |
| Code blocks and inline code in exports use a **fence longer than any backtick run** in their text. | Transcripts often contain Markdown, and a stray fence would break the report. |
| The daily chart covers **at least 14 days**, with days outside the chosen period drawn lighter, and at most five years. | One bar for "Today" says nothing, and a bad timestamp mustn't draw thousands of bars. |
| On macOS the main and Usage windows have a **unified bar** whose controls are **real toolbar items**, not Xojo controls laid out in the bar. | AppKit moves toolbar items into its overlay in full screen, where it hides anything else in the bar, and only toolbar items get the Liquid Glass look of Apple's own apps. |
| The main window's search is AppKit's **`NSSearchToolbarItem`**, added through a **runtime subclass of Xojo's toolbar delegate**. | `DesktopToolbar` has no search item and only the delegate can create one. A field in a plain item drew no capsule. The maintainer accepted the risk of a Xojo update breaking it (four releases a year). |
| Changed files are a **second view in the main window** (Sessions/Files), not a window of their own, and a file's full history **opens in its own window**. | The view shares the source list, date filter and detail pane. A history needs the width for diffs, as the timeline does. |
| A file's history shows **what agents changed and why** (the prompt and the answer around each edit). It is built from transcripts only, never from git or the user's own edits. | Transcripts are the only source Wake reads. The view says so, because a change in the history may no longer be in the file. |
| Changes come only from **edit and write tool calls**, not shell commands. | `sed -i`, `mv` or a script's writes can't be read reliably from a command's shape. |
| **Line blame matches by text**, not by replaying patches: the latest change that added a line with the same text claims it, nearest position first, and the page says it's a guess. | Transcripts hold patches, not file states, and the user's own edits are invisible, so a replay would break at the first gap. Text matching degrades one line at a time. |
| The blame is a **tab in the history page**, not a native control. | No window uses a segmented control or tab panel yet, and a mark's jump to its change stays inside the page. |
| Long blocks and persisted output are **fetched on demand** with `executeInXojoSync`, not embedded. | Keeps the page small for 10 MB transcripts. Persisted output is read only when asked for, capped at 4 MB. |

## Working notes and gotchas

- **Shared borders in MainWindow:** neighbouring bordered tables overlap by
  1 px so their borders draw as one line: the left lists' right border and
  `DetailList`'s left border both sit at x 880. `GlanceTiles` draws no border,
  so it starts at 881 and the left list's border shows beside it.
- **Ids change when a file is indexed again**: `StoreSession` deletes and
  re-inserts its rows. Anything that outlives an indexing run (selections,
  open timelines) must find its session by file path, and events by
  session uid and sequence.
- **A parser change that alters what the index stores** (such as which
  sessions are partial) needs a `kSchemaVersion` bump, because unchanged
  files are never re-indexed. Schemas 8 and 9 are only that.
- **Running tests:** create `Wake/WakeRunTests`, then `Wake/XojoRunProject.txt`.
  Wait for the trigger file to disappear, then for `tests/results.xml` or
  `Wake/XojoCompileErrors.txt` to appear.
- **Don't keep notes in `Wake/CLAUDE.md`.** Xojo's agentic mode deletes it.
  Use the root `CLAUDE.md` and this file.
- **Write files the way the IDE saves them**, or its next save shows up as a
  diff. A blank line inside a method body holds the indentation of the block
  it's in: two tabs and two spaces at the top of the body, two more spaces
  inside each `If`, `For`, `Try` and so on. Methods are sorted by name. Event signatures keep the IDE's own
  spelling, such as `DocumentComplete(url as String)`. The IDE re-saves only
  the items it has opened, so older files may still have empty blank lines.
  Commit a reformat on its own ("Reformat X as saved by the Xojo IDE"), so
  commit your own work before asking for the save.
- **Stage files by name, never `git commit -a`.** The IDE saves files in
  the background (reformats, project settings), and `-a` sweeps them into
  your commit. Run `git status` first and commit IDE changes on their own.
- **Adding project items:** create the file first, then add its line to
  `Wake/Wake.xojo_project` with a fresh unique `&h…` id and the parent folder's
  id. Never change existing ids.
- **The app icon** is drawn in `Artwork/` (SVG sources and the rendered PNGs).
  The maintainer adds the PNGs in the IDE, which stores them in the binary
  `Wake/Wake.xojo_resources`. `Artwork/README.md` has the render commands.
  After changing it, check the build: `iconutil -c iconset` on
  `Wake.app/Contents/Resources/App.icns` and compare each slot with
  `Artwork/IconSet`. The 128 and 32 @2x slots once came out blurry (cause
  unknown) until the PNGs were dropped into them again.
- **Releases** are built for Direct Distribution: signed with the Developer
  ID Application certificate (not Apple Distribution), hardened runtime on,
  notarized by the IDE, no entitlements, no sandbox. Check a build with
  `spctl -a -vv -t exec Wake.app` (expect "Notarized Developer ID") and zip
  it with `ditto -c -k --keepParent`. A Mac App Store build would need the
  sandbox, which hides `~/.claude`: the user would have to pick the folder,
  and Wake would keep a security-scoped bookmark to it.
- **`WakeTimeline.Anchor` renders the page first**, so calling it while
  the page renders recurses into a stack overflow. Use the Protected
  `KnownAnchor` there.
- **`Assert.AreEqual(n, someArray.Count)` is ambiguous.** Assign the count to
  an `Integer` variable first.
- **`(expression).ToString` doesn't parse.** Assign to a variable first.
- **`New Foo(x).Bar` doesn't parse either.** Assign the new object first.
- **HTML viewer callbacks:** page JavaScript calls `executeInXojoSync(method,
  arg)`, which raises `JavaScriptRequest(method, parameters())` and returns
  its String to the page. `LoadPage(html, Nil)` loads the page as
  `about:blank`, and `CancelLoad` fires for it too, so let the first load
  through and block the rest.
- **`String.ToDouble` follows the user's locale.** In Spanish, `"3.00".ToDouble`
  is 300. Read numbers the user types with `WakePriceTable.ParsePrice`, and
  numbers Wake wrote itself with `Val` or JSON.
- **Leaving an edited cell fires both `CellAction` and `CellFocusLost`**
  (seen on the list box; the table may do the same), so whatever they call
  must be safe to run twice.
- **`DesktopTable` differs from the list box in a few names.** Headings are
  `ColumnHeaderAt`, not `HeaderAt`. `DoublePressed(row, column)` gets the
  row, so a handler returns early on `row < 0`. In the layout, `HasHeader`
  becomes `HasColumnHeader`, there's no `HeadingIndex`, `InitialParent` or
  `_ScrollOffset`/`_ScrollWidth`, and `AllowColumnReordering` and
  `AllowResizableRows` are added. The IDE's inspector can't set a column's
  type or alignment, so set them in code (`ColumnTypeAt`, `ColumnAlignmentAt`
  with `DesktopTable.CellTypes` and `DesktopTable.Alignments`). There's no
  "no selection" type: a read-only table (`DetailList`) returns True from
  `MouseDown`, has `TabStop` off and clears any selection that gets through.
- **A method call on a string literal doesn't parse** (`"abc".IndexOf(x)`).
  Assign the literal to a variable first.
- **String constants with commas:** how the IDE escapes a comma in a
  constant's `Default` isn't documented, so put such text in a method
  (`WakeTokenReport.LongSessionAdvice`) or a literal instead.
- **`DesktopTable.ColumnCount` and `ColumnWidths` can be set in code.**
  Lowering the count drops the columns on the right, so reset
  `SortingColumn` first if it points at one (`UsageWindow.SetHeaders`).
- **`String` has no `LastIndexOf`.** Split, or loop with `IndexOf`.
- **`DesktopProgressWheel.Active` can't be set in code.** Leave it `True` in
  the layout and toggle `Visible`.
- **Window layouts are written by hand.** Copy control property lists from
  this project's own windows. Never read Xojo's own sources (the IDE or the
  framework): work from the public docs, as any Xojo user would. For a
  control or property no window here uses yet, ask the maintainer to add it
  in the IDE, then copy what the IDE saves.
- **The shell can't take screenshots** (no screen-recording permission), so
  the maintainer has to check UI changes by eye.
- **Search snippets mark matches with `&u02` and `&u03`.** The index replaces
  those characters in the text it stores.
- **Subagents are one level deep.** Search finds an event's top-level session
  as its session's parent. Revisit this if nested subagents appear.
- **The search field is a `DesktopSearchField`** (it was a text field before
  milestone 20). The docs list no `SelectAll` for it, so Cmd+F only focuses it.
- **`DesktopToolbar` in a unified bar:** the docs' `DesktopToolbarStyles` is
  `DesktopToolbar.Styles` in code. In the file, `ButtonStyle = 3` is DropDown,
  4 SeparateDropDown and 1 Separator (unsupported on macOS); add spaces in
  code with the enum. Each item is an `NSToolbarItem` whose view is Xojo's own
  button, so setting the item's image does nothing. Xojo resets the window's
  toolbar style when it first shows, so windows apply `Unify` from `Opening`
  and again with `Timer.CallLater(0, …)`. Captions under the icons made the
  bar 66 points instead of 52; icons only fixes it. Bordered neighbours share
  one glass capsule; a space between them gives capsules of different sizes.
  Divided capsules (Mail's) need an `NSToolbarItemGroup`, which only the
  delegate can make (`AddViewSwitch`). Its target is Xojo's delegate, which
  disables items it doesn't know on validation, so the group and its
  subitems need `autovalidates` off and `enabled` on, or they're grey and
  dead. Their own capsule must be skipped by `StyleToolbarItems`.
- **`DesktopTable` on macOS** is a `XOJCanvasView` holding an `NSScrollView`
  (`DLB2PassThruScrollView`, document view `DLB2FlippedDocView`); it isn't an
  `NSTableView`. Xojo draws the rows on the outer `XOJCanvasView` itself, so a
  subview added inside covers them: a view meant to show behind the list goes
  in its superview, below it, and the list needs a layer to stay in front of
  a layer-backed sibling. In dark mode the empty parts are transparent; in
  light mode Xojo fills the whole view with opaque white, and returning True
  from `PaintCellBackground` doesn't stop that (it only drops the selection
  highlight). The scroll and clip views draw no background in either.
- **Declares that read an `NSRect`** go through key-value coding
  (`valueForKey:` and `getValue:size:` into a `MemoryBlock`), so no declare
  returns a structure (the docs don't show how a `Structure` is written in a
  text project). `array` is a reserved word, so don't use it as a declare
  parameter name.
- **The window buttons aren't centred in a unified bar:** in a 66-point bar
  they sat at 25.5 points. Not needed now that the controls are
  toolbar items, but worth knowing before laying out controls in the bar.
- **Two builds share one index.** A release build left open and a debug run
  with a different `kSchemaVersion` rebuild the index over each other on
  every live-watch tick. Quit the other build before checking real data.
- **Running the project** after edits doesn't need the maintainer: create
  `Wake/XojoRunProject.txt` (Agentic Mode reloads the files), and read
  `Wake/XojoCompileErrors.txt` if it appears. `System.DebugLog` output can be
  read with `/usr/bin/log show --predicate 'composedMessage CONTAINS "…"'`
  (plain `log` is a zsh builtin).
- **Opening a hit runs `wakeGoTo` with `ExecuteJavaScript`** after
  `DocumentComplete`. The page's CSP doesn't block native script calls
  (checked in the app on macOS).
- **Drawn controls use `Color.TextColor`** and check `Color.IsDarkMode` for
  tints, so they follow the appearance. For quieter text use
  `WakeGlanceTiles.SecondaryTextColor`: `Color.DisabledTextColor` is too faint
  on tinted tiles. Colour constants are `Type = Color`.
- **`PaintCellText` draws the cell text in `g.DrawingColor`** when it returns
  False, so restore that colour after drawing anything else in the cell.
- **A `DesktopTable` header whose sort direction is `None` ignores clicks**
  (no `ColumnHeaderPressed`). To show the arrow on one column only, give
  every column a direction and set `HeadingIndex`, as `ShowFileSortColumn` does.
- **Xojo adds no File → Close item.** `FileCloseWindow` (Cmd+W) has a
  `Self.Close` handler in each window. A handler in `App` closing `WindowAt(0)`
  didn't close the front window. A new window needs its own handler.
- **Menu handlers in `App` never run** in this project, even with no window
  handling the item (confirmed with a breakpoint). So auto-enable greys
  their items out, and enabling them by hand only gives a dead item. Put menu
  handlers in every window instead (Window → Usage and Prices are in all four).
- **Closing the main window quits Wake** (`MainWindow.Closing` calls `Quit`).
  `AllowAutoQuit = True` in `App.Opening` covers the last-window case.
- **`call` is a reserved word** in Xojo. Don't use it as a variable name.
- **Xojo identifiers are case-insensitive.** A parameter named `usage` shadows
  a property named `Usage`, and a local `callKey` a method `CallKey`.
- **A plain `New Dictionary` compares string keys case-insensitively.** Use
  `WakeCore.NewCaseSensitiveDictionary` for ids.
- **Avoid string constants with escapes** such as `"\n"`. Use `&u0A` in code.
- **Don't invent `Description = <hex>` attributes** on methods or properties.
- **`Child()` of a folder that doesn't exist returns Nil**, so create parent
  folders before you build paths inside them.
- **Preemptive threads:** each thread opens its own `SQLiteDatabase`
  connection, and the index uses WAL so the UI can read during indexing.
  Shared lazy globals such as `AgentRegistry.Parsers` must be filled on the
  main thread before the thread starts.
- **A new index table goes in `CreateSchema`'s drop list** as well as in
  `SchemaStatements`, or the next schema bump fails because the table
  already exists.
- **Foreign-key cascades fire triggers**, so deleting a `files` row clears
  its sessions, events and `events_fts` rows. A test checks this.
- **Async XojoUnit tests:** call `AsyncAwait(seconds)` before starting the
  work and `AsyncComplete` in the callback. Remove any `AddHandler` that
  points back at the test, or the test is never released and `TearDown`
  never runs.
- **Fixtures that would change shared counts** go in a root of their own
  under `tests/fixtures/claude-code/` (like `patterns/`), indexed only by
  their own test group. Adding a session to `projects/` breaks a dozen counts.
- **Checking against real data:** a temporary test group that parses
  `~/.claude/projects` and writes a summary to the scratchpad, compared with
  a Python reference, is a good check. Never commit it, and never copy real
  transcript content into the repo.
