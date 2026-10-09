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

- [ ] **13. Drill down to the calls.** In the Usage window, selecting a row
  of a tool grouping lists that group's calls below it, most tokens first.
  - Core: `WakeCatalog.ToolCalls(grouping, key, fromTime, limit)` returns
    `WakeToolCallInfo`s (new class in `Core/Index`): session id and uid,
    session title, seq, timestamp, tool, the event's `summary` (join
    `events` on `session_id` and `seq`), target, ≈ added, ≈ re-read and
    usage by model for the cost. Default limit 500.
  - UI: a second list box under `UsageList` (columns: time, session,
    call, ≈ added, ≈ re-read, cost), shown only for tool groupings, with the
    same `RowComparison` sorting by cell tag. Double-clicking a call opens
    its timeline at that event, the way search hits do (`SessionWindow.
    ShowEvent(uid, seq)`). Copy the list's property list from `UsageList`.
    This edits the window by hand, so ask the maintainer to save afterwards.
  - Tests: on the fixtures, the `Read` group lists 2 calls, the larger
    first, with their summaries; a subagent's call (`Grep`) points to the
    subagent's uid.

- [ ] **14. Group calls by intent.** Classify every tool call by what it
  was trying to get, so the fix is obvious from the group.
  - Core: a `WakeCallPattern` module with an enum and `Classify(e As
    WakeEvent)`. Patterns and the shape that decides them:
    - **Line range:** Read with `offset`/`limit`; `sed -n` with numeric
      addresses (`10,80p`); `head`; `tail`.
    - **Section:** `sed`/`awk` with a regex address range (`/a/,/b/p`).
    - **Whole file:** Read without a range; `cat`, `less`, `more` with a file.
    - **Search:** Grep; `grep`, `rg`, `ag`, `ack`, `git grep`.
    - **Listing:** Glob; `ls`, `find`, `tree`, `git ls-files`.
    - **Edit:** Edit, MultiEdit, Write, NotebookEdit.
    - **Web:** WebFetch, WebSearch, browser MCP tools (name contains
      `browser` or `chrome`).
    - **Run:** any other shell command (builds, tests, git, scripts).
    - **Other:** everything else.
    Use `WakeEvent.ShellWords` for shell commands (make it public if
    needed), and the program from `ShellProgram`.
  - **Re-reads:** in `WakeSession.ComputeStats`, flag a read (line range,
    section, whole file) of a target already read earlier in the same
    session, unless an Edit or Write to that target came in between.
  - `WakeCallPattern.Advice(pattern)` gives one generic sentence per
    pattern, e.g. line range: "Reads by line number suggest the agent
    can't ask for a symbol or section by name. A tool or index that returns
    one function or section by name would send less."; whole file: "Whole
    files sent at once. An outline first, then only the parts needed, would
    send less."; re-reads: "The same file read again in a session. It is
    already in the context, so guidance or a cache can avoid it."
  - Index: `tool_usage` gains `pattern TEXT` and `is_reread INTEGER`.
    Bump `kSchemaVersion`. `WakeCatalog.ToolGroupings` gains `Pattern`,
    with re-reads as their own group ("Re-read") ahead of their pattern.
  - UI: "By intent" in the grouping popup; the advice shows in the status
    line for the selected row and as the label's tooltip.
  - Tests: classification of hand-built events across languages (`.py`,
    `.go`, `.ts`, `.rs`, a file with spaces in its path); a re-read, and a
    read after an edit that is not a re-read. Add a fixture session 7 to
    `generate_claude_code.py` with a `sed -n` range, `cat`, `head`, a
    regex-range `awk`, and the same file read twice, and document it in
    `tests/fixtures/README.md`.

- [ ] **15. Waste per file.** The "By file" grouping shows what makes a
  file expensive to work with.
  - Catalog: `ToolUsage` also returns, per group, reads, re-reads and the
    number of distinct line-range reads. Add these to `WakeToolUsageGroup`.
  - UI: for "By file" and "By intent", show reads, re-reads (with share)
    and ≈ per read instead of sessions and ≈ per call. Status line for a
    selected file: "Read N times in M sessions, R of them again in the
    same session".
  - Tests: on fixture session 7, the twice-read file has 1 re-read.

- [ ] **16. Export the findings as tasks.** File → Export Report in the
  Usage window writes Markdown that a developer can paste into an issue or
  give to an agent as a spec.
  - Core: `WakeTokenReport` builds it from the catalog for a period: totals,
    then one section per intent with ≈ tokens, cost, calls, the advice, the
    top 5 files, and 3 example calls (most expensive) as code blocks, using
    `WakeMarkdown`'s fence rule. Re-reads get their own section. Examples
    are commands from the user's own transcripts, and the user chooses
    where the file goes.
  - Tests: the report for the fixtures has a section per pattern present,
    fences longer than any backtick run in an example, and no section for
    patterns with no calls.

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
| The window opens its index connection **only after an indexing run finishes**, and reloads after each run. | Opening it while the thread creates or rebuilds the schema would race it. A run with nothing changed takes about 10 ms, so the wait is invisible. |
| A session with no `cwd` (empty, or only a slash command) joins the project of **the other sessions in its folder**, if there are any. | Otherwise it shows up as a second project named after the encoded folder. |
| The timeline **opens in its own window** (`SessionWindow`), one per session. | It needs the full width for diffs and output, and two sessions can be compared side by side. |
| The timeline page has a **CSP of `default-src 'none'`** with inline style and script, and the viewer **cancels every navigation** after the page loads. | Transcripts are untrusted text. Nothing in them may load a remote resource or move the viewer off the page. |
| The timeline page holds **no amounts**. Its cost slots are filled by `wakeSetCosts` after load and after every price change. | Reloading the page would lose the scroll position and the open blocks. |
| Where the tokens went is a set of **groupings in the Usage window**, not its own window. | It shares the period, tiles and chart, and needs no new layout. |
| A shell command's **program** is the first word of its first line after `cd`, `export`, `source` and `VAR=value` parts, and its **target** is the last file-like word on that line. Words are split the way the shell would: quotes keep spaces, and only unquoted `&&`, `\|\|`, `\|`, `&` and `;` start a new command. | Commands rarely say what they read in a structured way. This finds `sed`, `cat` and `grep` reads of a file. Loops show up as `for`. |
| Token figures per tool call are **estimates, marked ≈**, from context growth between responses, split among the inputs by text length. | Transcripts record usage only per response, so this is the only per-result signal. Attachments and reminders Wake can't see inflate it a little. |
| Search words match as **prefixes**, `"quoted text"` as a phrase, and every term must match. Every term is quoted, so FTS5 operators are plain words. | Search as you type needs partial words, and no input may raise an FTS5 syntax error. |
| Search lives **in the main window**, scoped by the source-list selection, not in its own window. | Agent and project filters come for free, and the detail pane shows the hit's session. |
| Search runs **on the main thread**, 250 ms after the last keystroke. | Queries take milliseconds on real data. |
| Wake ships **no prices**. Until the user sets one, costs read "no price set", and a partly priced total reads "≥ $x". | Prices change and must not be hardcoded. "≥" keeps a partial sum from looking complete. |
| **One-hour cache writes** are counted apart (`CacheWrite1hTokens`, part of `CacheWriteTokens`) and have their own price, which falls back to the cache-write price when empty. | 98% of cache writes in real data are one-hour writes, which cost 2× input instead of 1.25×. One price for both would be far off. |
| A **dated model name** (`claude-haiku-4-5-20251001`) uses the price of its undated name when it has none of its own. Other prefixes never match. | `claude-opus-5` must not price `claude-opus-5-5`. |
| Usage **per day** groups responses by their own timestamp in the **local time zone**, at query time. Subagent usage counts toward the session that started it. | A session can span midnight, and the time zone can change between runs. |
| The Usage window covers **every agent and project**, not the main window's selection. | It's a summary across everything. Per project is one of its groupings. |
| A Markdown export lists **prompts, commands and file changes**, not the answers or tool output. | It's a record of what was asked and what changed. The timeline has the rest. |
| Code blocks and inline code in exports use a **fence longer than any backtick run** in their text. | Transcripts often contain Markdown, and a stray fence would break the report. |
| The daily chart covers **at least 14 days**, with days outside the chosen period drawn lighter, and at most five years. | One bar for "Today" says nothing, and a bad timestamp mustn't draw thousands of bars. |
| Long blocks and persisted output are **fetched on demand** with `executeInXojoSync`, not embedded. | Keeps the page small for 10 MB transcripts. Persisted output is read only when asked for, capped at 4 MB. |

## Working notes and gotchas

- **Shared borders in MainWindow:** neighbouring bordered list boxes overlap by
  1 px so their borders draw as one line: the left lists' right border and
  `DetailList`'s left border both sit at x 880. `GlanceTiles` draws no border,
  so it starts at 881 and the left list's border shows beside it.
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
- **Leaving an edited listbox cell fires both `CellAction` and
  `CellFocusLost`**, so whatever they call must be safe to run twice.
- **A method call on a string literal doesn't parse** (`"abc".IndexOf(x)`).
  Assign the literal to a variable first.
- **`String` has no `LastIndexOf`.** Split, or loop with `IndexOf`.
- **`DesktopProgressWheel.Active` can't be set in code.** Leave it `True` in
  the layout and toggle `Visible`.
- **Window layouts are written by hand** in `MainWindow.xojo_window`. Copy
  control property lists from the Xojo IDE's own windows (under
  `~/Developer/Xojo/Xojo/<version>/IDE`), which are in the same text format.
- **The shell can't take screenshots** (no screen-recording permission), so
  the maintainer has to check UI changes by eye.
- **Search snippets mark matches with `&u02` and `&u03`.** The index replaces
  those characters in the text it stores.
- **Subagents are one level deep.** Search finds an event's top-level session
  as its session's parent. Revisit this if nested subagents appear.
- **No IDE window uses `DesktopSearchField`**, so there's no property list to
  copy. The search field is a `DesktopTextField` with a hint, and Escape clears it.
- **Opening a hit runs `wakeGoTo` with `ExecuteJavaScript`** after
  `DocumentComplete`. The page's CSP doesn't block native script calls
  (checked in the app on macOS).
- **Drawn controls use `Color.TextColor`** and check `Color.IsDarkMode` for
  tints, so they follow the appearance. For quieter text use
  `WakeGlanceTiles.SecondaryTextColor`: `Color.DisabledTextColor` is too faint
  on tinted tiles. Colour constants are `Type = Color`.
- **`PaintCellText` draws the cell text in `g.DrawingColor`** when it returns
  False, so restore that colour after drawing anything else in the cell.
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
  a property named `Usage`.
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
- **Checking against real data:** a temporary test group that parses
  `~/.claude/projects` and writes a summary to the scratchpad, compared with
  a Python reference, is a good check. Never commit it, and never copy real
  transcript content into the repo.
