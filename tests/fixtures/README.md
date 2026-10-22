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
that use them. Session 7 is written to `claude-code/patterns/` (see below).

## Claude Code sessions

Session `N` means the file `00000000-0000-4000-8000-00000000000N.jsonl`.

Token totals are counted **once per `message.id`**, and `<synthetic>` messages
are excluded. Columns are: input / output / cache write / cache read.

| N | Project folder                   | What it covers | Expected |
|---|----------------------------------|----------------|----------|
| 1 | `-Users-dev-demo`                | Basic prompt and answer. One response is split into thinking and text records with repeated usage. Includes `ai-title`, `last-prompt`, `turn_duration`, `permission-mode`, the three `api-request*` logs (two compact, one with spaces) the two `artifact-*` records, `relocated` and `worktree-state`. | 1 prompt, 1 response. 9 ignored records, not partial. Tokens 100 / 50 / 1000 / 2000. Title "Explain parse function". |
| 2 | `-Users-dev-demo`                | Tools: Bash with an error result (`is_error: true`); two parallel Reads whose results arrive in reverse order; Edit with `structuredPatch`; Write (create); Bash with persisted output in `tool-results/bfixture01.txt` (120 lines); two `ai-title` records; `cost-state`. | 6 tool calls, all paired. 6 responses. Tokens 22 / 190 / 700 / 17500. Title is the **last** `ai-title`: "Fix failing CSV quoting test". Branch `feature/csv`. |
| 3 | `-Users-dev-demo`                | Robustness: a slash-command wrapper, an `isMeta` user record, a text+image prompt, a malformed line cut mid-object, an unknown record type `future-record-kind`, an unknown content block `hologram`, unknown fields, a blank line, a `not json` line, a `<synthetic>` API error, a `<task-notification>`, and a truncated final line with no newline. | 3 malformed lines (the blank line is ignored, not counted). 1 unknown record type and 1 unknown block type. 1 real prompt. 1 Error event. Tokens 10 / 10 / 0 / 0. Must parse as **partial**, not fail. |
| 4 | `-Users-dev-demo`                | Subagent: the parent's `Agent` tool call `toolu_agent_01` and its subagent transcript `subagents/agent-a0fixture000001.jsonl` with `.meta.json` (records have `isSidechain: true` and the parent's `sessionId`). | Parent tokens 25 / 50 / 100 / 400. Subagent tokens 110 / 25 / 0 / 0 (model `claude-haiku-4-5-20251001`). |
| 5 | `-Users-dev-demo`                | Empty file. | Listed as a session with no events. Doesn't crash. |
| 6 | `-Users-dev-Open-Source-demo-app`| `cwd` with a space and a dot. The folder name can't be decoded. | Project path is `/Users/dev/Open Source/demo.app` (from `cwd`). Tokens 7 / 9 / 0 / 0. |

`-Users-dev-demo/memory/` isn't a session and must be ignored by discovery.

## Call patterns (`claude-code/patterns/`)

Session 7 lives in its own root, so the counts above don't change. Only the
call-pattern and report tests index it. Regenerating writes both roots:

```sh
rm -rf tests/fixtures/claude-code/projects tests/fixtures/claude-code/patterns
python3 tests/fixtures/generate_claude_code.py "$PWD/tests/fixtures/claude-code/projects"
```

| N | Project folder   | What it covers | Expected |
|---|------------------|----------------|----------|
| 7 | `-Users-dev-lab` | One tool call per response, each growing the context: `sed -n '10,80p' src/config.py`, `cat "docs/user guide.md"`, `head -n 20 src/server.go`, a regex-range `awk`, Read of `config.py` with `offset`/`limit`, Edit of `config.py`, Read of the whole `config.py`, and ``grep -rn "```" docs``. Shell paths are relative to `cwd` `/Users/dev/lab`. | Patterns: line range, whole file, line range, section, line range (a **re-read**), edit, whole file (not a re-read: it follows the edit), search. `config.py`: 4 calls, 3 reads, 1 re-read, 2 line-range reads. |

## Reads that led nowhere (`claude-code/nowhere/`)

Session 9 lives in its own root too. Only `WakeNowhereTests` indexes it.

| N | Project folder     | What it covers | Expected |
|---|--------------------|----------------|----------|
| 9 | `-Users-dev-notes` | Reads of `src/parser.c` (edited later), `README.md` (`cat`, named only in the answer), `src/util.h` (a later `grep` names only `util.hpp`), `src/lexer.c` twice, `docs/notes.md` (named in an `Agent` prompt) and `src/old.c` (named only after a compaction, in a second turn), a screenshot whose result is an image block, and `/tmp/agent/b0fixture9.txt`, outside the project, named only in an earlier tool result. | Led nowhere: `util.h`, both `lexer.c` reads and `old.c`, so 4 of 9 reads. The screenshot and the saved output are never flagged. |

## File changes (`claude-code/changes/`)

Session 10 lives in its own root too. Only `WakeFileChangesTests` indexes it.

| N  | Project folder    | What it covers | Expected |
|----|-------------------|----------------|----------|
| 10 | `-Users-dev-shop` | Turn 1 (10:00 UTC): Read of `src/app/price.py`, Write creating `src/app/format.py`, Edit of `price.py` with `structuredPatch`, and an `Agent` call whose subagent (`agent-a0fixture000010`) edits `README.md`. Turn 2 (11:00 UTC): Write replacing `format.py` (`type: update`), a failed Edit of `price.py`, `sed -i` on `price.py`, and a Write creating `/Users/dev/notes/shop.md`, outside the project. | 4 changed files, 5 changes: `format.py` 2 (+4 −1), `price.py` 1 (+2 −1, 1 read), `README.md` 1 (+2, subagent, turn 1's prompt), `shop.md` 1 (+1, outside). The failed edit and `sed -i` don't count. From 10:30 on: `format.py` (1) and `shop.md`. |
