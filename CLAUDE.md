# Wake: project notes for agents

Wake is a read-only, local-only desktop explorer for AI coding-agent sessions.

- Never write to, move or delete agent transcript files. Open them read-only.
- No network code and no telemetry.
- Keep everything in `Wake/Core/` free of Desktop* UI classes, because a console
  companion will reuse it later.
- Unknown record types and fields must be skipped and counted, never crash.
- Transcript formats are documented in `docs/FORMATS.md`. Update it when a
  parser learns something new.
- Never copy real transcripts into `tests/fixtures`. Fixtures are
  hand-written and anonymized.
- Parser tests use XojoUnit. To run them, create a `WakeRunTests` marker file
  in `Wake/`, then `Wake/XojoRunProject.txt`. Results are written to
  `tests/results.xml`.
- Don't keep notes in `Wake/CLAUDE.md`: Xojo's agentic mode manages the agent
  files inside the project folder and deletes that file when it runs.
