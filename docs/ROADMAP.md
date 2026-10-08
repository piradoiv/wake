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
- [ ] **3. Discovery and index.**
  - Default roots per OS (Claude Code: `~/.claude/projects`, or
    `$CLAUDE_CONFIG_DIR/projects`; `ClaudeCodeParser.DefaultRoots` already
    does this) plus user-added custom folders.
  - SQLite index in `SpecialFolder.ApplicationData/Wake/index.sqlite`. Tables:
    files (path, size, mtime, agent, parse report), projects, sessions,
    events, and `events_fts` (FTS5).
  - Re-index a file only when its size or modification time changes, with one
    transaction per file. Remove rows for files that disappeared.
  - Background indexing on a preemptive `Thread` that reports progress with
    `AddUserInterfaceUpdate`. The indexer itself lives in Core and must stay
    UI-free.
  - Tests: re-indexing skips unchanged files and picks up changed and deleted
    ones. Use a temporary copy of the fixtures, never the originals.
- [ ] **4. Browse UI.** Main window: agents → projects in a source list, a
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
- **Checking against real data:** a temporary test group that parses
  `~/.claude/projects` and writes a summary to the scratchpad, compared with
  a Python reference, is a good check. Never commit it, and never copy real
  transcript content into the repo.
