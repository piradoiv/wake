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
- [x] **10. Timeline header.** The timeline page's header shows the same
  four tiles as the main window (cost, tokens, duration, prompts), as HTML and
  CSS in `WakeTimeline`. `WakeTimeline` takes the price table, and when the
  prices change the page reloads only the cost tile through the `cost`
  request, keeping its scroll position. `WakeSession.TotalUsageByModel` rolls
  up subagents for both the timeline and the export. 85 tests. Checked in the
  app.

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
- **Xojo adds no File → Close item.** `FileClose` (Cmd+W) is handled in `App`
  and closes `WindowAt(0)`, the frontmost window.
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
