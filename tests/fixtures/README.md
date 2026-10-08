# Test fixtures

These are **hand-written, fully synthetic** transcripts. None of them were
copied from real sessions. Paths use `/Users/dev/...`, and ids are made-up
UUIDs (`00000000-0000-4000-8000-00000000000N`).

**Never put real transcripts here.** They can contain secrets and private code.

`claude-code/projects/` mirrors the layout of `~/.claude/projects/`. You can
regenerate it with:

```sh
rm -rf tests/fixtures/claude-code/projects
python3 tests/fixtures/generate_claude_code.py "$PWD/tests/fixtures/claude-code/projects"
```

If you change the generator, update the expected values below and the tests
that use them.

## Claude Code sessions

Session `N` means the file `00000000-0000-4000-8000-00000000000N.jsonl`.

Token totals are counted **once per `message.id`**, and `<synthetic>` messages
are excluded. Columns are: input / output / cache write / cache read.

| N | Project folder                   | What it covers | Expected |
|---|----------------------------------|----------------|----------|
| 1 | `-Users-dev-demo`                | Basic prompt and answer. One response is split into thinking and text records with repeated usage. Includes `ai-title`, `last-prompt`, `turn_duration` and `permission-mode`. | 1 prompt, 1 response. Tokens 100 / 50 / 1000 / 2000. Title "Explain parse function". |
| 2 | `-Users-dev-demo`                | Tools: Bash with an error result (`is_error: true`); two parallel Reads whose results arrive in reverse order; Edit with `structuredPatch`; Write (create); Bash with persisted output in `tool-results/bfixture01.txt` (120 lines); two `ai-title` records; `cost-state`. | 6 tool calls, all paired. 6 responses. Tokens 22 / 190 / 700 / 17500. Title is the **last** `ai-title`: "Fix failing CSV quoting test". Branch `feature/csv`. |
| 3 | `-Users-dev-demo`                | Robustness: a slash-command wrapper, an `isMeta` user record, a text+image prompt, a malformed line cut mid-object, an unknown record type `future-record-kind`, an unknown content block `hologram`, unknown fields, a blank line, a `not json` line, a `<synthetic>` API error, a `<task-notification>`, and a truncated final line with no newline. | 3 malformed lines (the blank line is ignored, not counted). 1 unknown record type and 1 unknown block type. 1 real prompt. 1 Error event. Tokens 10 / 10 / 0 / 0. Must parse as **partial**, not fail. |
| 4 | `-Users-dev-demo`                | Subagent: the parent's `Agent` tool call `toolu_agent_01` and its subagent transcript `subagents/agent-a0fixture000001.jsonl` with `.meta.json` (records have `isSidechain: true` and the parent's `sessionId`). | Parent tokens 25 / 50 / 100 / 400. Subagent tokens 110 / 25 / 0 / 0 (model `claude-haiku-4-5-20251001`). |
| 5 | `-Users-dev-demo`                | Empty file. | Listed as a session with no events. Doesn't crash. |
| 6 | `-Users-dev-Open-Source-demo-app`| `cwd` with a space and a dot. The folder name can't be decoded. | Project path is `/Users/dev/Open Source/demo.app` (from `cwd`). Tokens 7 / 9 / 0 / 0. |

`-Users-dev-demo/memory/` isn't a session and must be ignored by discovery.
