# Wake: project notes for agents

Wake is a read-only, local-only desktop explorer for AI coding-agent sessions.

**Start here:** read `docs/ROADMAP.md` for milestone status, decisions already
made and Xojo gotchas. Continue from the first unchecked milestone, and tick it
off in the same commit that finishes it.

**You maintain this file and `docs/ROADMAP.md`.** The maintainer won't edit
them. Whenever you learn something a future session would need, update the
right file in the same commit as the work:
- New rules or project-wide conventions go here.
- Gotchas, decisions and milestone status go in the roadmap.
- Format discoveries go in `docs/FORMATS.md`.

Remove anything that turns out to be wrong. Keep all three short and current.

- Never write to, move or delete agent transcript files. Open them read-only.
- No network code and no telemetry.
- Keep everything in `Wake/Core/` free of Desktop* UI classes, because a console
  companion will reuse it later.
- Unknown record types and fields must be skipped and counted, never crash.
- Transcript formats are documented in `docs/FORMATS.md`. Update it when a
  parser learns something new.
- Never copy real transcripts into `tests/fixtures`. Fixtures are
  hand-written and anonymized.
- The SQLite index is a disposable cache. When you change its schema, bump
  `WakeIndex.kSchemaVersion` instead of writing a migration.
- Tests that change files work on a scratch copy made with
  `TestSupport.NewScratchFolder` and `CopyFolder`, never on `tests/fixtures`.
- Parser tests use XojoUnit. To run them, create a `WakeRunTests` marker file
  in `Wake/`, then `Wake/XojoRunProject.txt`. Results are written to
  `tests/results.xml`.
- Don't keep notes in `Wake/CLAUDE.md`: Xojo's agentic mode manages the agent
  files inside the project folder and deletes that file when it runs.
