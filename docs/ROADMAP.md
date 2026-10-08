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
- [ ] **4. Browse UI.** Read from the index (`App.IndexThread` reports
  progress and completion) on the main thread's own connection. Main window: agents → projects in a source list, a
  sessions list (date, duration, title or first prompt, agent, token total,
  "partially parsed" badge), and the detail pane. Hide command-only sessions
  by default.
- [ ] **5. Session timeline.** `DesktopHTMLViewer` fed local HTML, with no
  remote resources: collapsible tool calls and results, diffs for file edits,
  long outputs truncated with an option to expand, and the parse-report note.
  Load persisted tool output only on demand.
- [ ] **6. Search.** Full-text search (FTS5) with filters for agent, project,
  date range and event kind.
- [ ] **7. Stats and prices.** Tokens per session, project and day.
  User-editable price table (per model: input, output, cache write and cache
  read per million tokens) stored as JSON in the app data folder. Cost
  estimates show "no price set" for unknown models.
- [ ] **8. Markdown export and polish.** Session → Markdown report (summary,
  prompts, commands, file changes as fenced diffs, token totals), with tests.
  Update the README and do a demo pass on real data.

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
| A session with no `cwd` (empty, or only a slash command) joins the project of **the other sessions in its folder**, if there are any. | Otherwise it shows up as a second project named after the encoded folder. |

## Working notes and gotchas

- **Running tests:** create `Wake/WakeRunTests`, then `Wake/XojoRunProject.txt`.
  Wait for the trigger file to disappear, then for `tests/results.xml` or
  `Wake/XojoCompileErrors.txt` to appear.
- **Don't keep notes in `Wake/CLAUDE.md`.** Xojo's agentic mode deletes it.
  Use the root `CLAUDE.md` and this file.
- **Adding project items:** create the file first, then add its line to
  `Wake/Wake.xojo_project` with a fresh unique `&h…` id and the parent folder's
  id. Never change existing ids.
- **`Assert.AreEqual(n, someArray.Count)` is ambiguous.** Assign the count to
  an `Integer` variable first.
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
