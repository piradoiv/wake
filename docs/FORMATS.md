# Agent transcript formats

This document records what Wake knows about each agent's on-disk transcript
format. None of these formats are officially documented and all of them change
between agent versions, so everything here comes from inspecting real files.
Each section says which versions it was checked against.

When a parser learns something new, update this file.

---

## Claude Code

**Checked against:** Claude Code CLI 2.1.119 – 2.1.292 (macOS, October 2026).
That sample was 77 sessions in 23 projects, about 124 MB, with the largest
file around 10 MB.

### Location

| OS      | Default root                          |
|---------|---------------------------------------|
| macOS   | `~/.claude/projects/`                 |
| Linux   | `~/.claude/projects/`                 |
| Windows | `%USERPROFILE%\.claude\projects\`     |

If the `CLAUDE_CONFIG_DIR` environment variable is set, the root is
`$CLAUDE_CONFIG_DIR/projects/` instead. Only the macOS path has been checked
against real files. The Linux and Windows paths follow the same convention but
have not been verified yet.

### Layout

```
~/.claude/projects/
  <encoded-cwd>/                      one folder per working directory
    <sessionId>.jsonl                 one file per session (main transcript)
    <sessionId>/                      optional, per-session side files
      subagents/
        agent-<agentId>.jsonl         subagent transcript
        agent-<agentId>.meta.json     subagent metadata
      tool-results/
        <id>.txt                      large tool output stored outside the JSONL
    memory/                           agent memory notes (*.md); ignored by Wake
```

- `<sessionId>` is a UUID.
- **`<encoded-cwd>` is lossy.** `/`, spaces and `.` all become `-`. For example
  `/Users/dev/Open Source/wake` becomes `-Users-dev-Open-Source-wake`, so the
  original path can't be decoded reliably. Read the project path from the
  `cwd` field of the records. Empty and command-only sessions have no `cwd`.
  Wake puts them in the project of the other sessions in the same folder, and
  uses the folder name only when there are none.
- Every file in the sample contained exactly one `sessionId`, and it matched
  the file name.

### Records

The file is JSON Lines: one JSON object per line, UTF-8. The sample had no
malformed lines, but a file still being written can end with a partial line.

Every record has a `type`. There are two families.

**Conversation records** carry a common envelope:

| Field         | Notes                                                      |
|---------------|------------------------------------------------------------|
| `uuid`        | Record id.                                                 |
| `parentUuid`  | Previous record in the chain, or `null` for the first one. |
| `timestamp`   | ISO 8601 UTC with milliseconds, e.g. `2026-10-01T09:20:11.123Z`. |
| `sessionId`   | Session UUID.                                              |
| `cwd`         | Working directory at the time of the record.               |
| `gitBranch`   | Current branch, or an empty string.                        |
| `version`     | Claude Code CLI version, e.g. `2.1.292`.                   |
| `isSidechain` | `true` in subagent transcripts.                            |
| `agentId`     | Present in subagent transcripts.                           |
| `entrypoint`, `userType`, `slug`, … | Not needed by Wake.                  |

| `type`       | Meaning                                                         |
|--------------|-----------------------------------------------------------------|
| `user`       | A user prompt, or the tool results being sent back to the model. |
| `assistant`  | Part of a model response (see "Assistant messages" below).      |
| `attachment` | Context injected by the CLI. `attachment.type` has about 40 values, such as `file`, `edited_text_file`, `todo_reminder`, `plan_mode`, `date_change` or `hook_system_message`. Mostly noise for Wake. |
| `system`     | CLI events. The `subtype` values seen are `turn_duration` (`durationMs`), `local_command`, `away_summary`, `stop_hook_summary` and `informational`. |

**Metadata records** have no `uuid` or `timestamp`:

| `type`                  | Useful fields                                         |
|-------------------------|-------------------------------------------------------|
| `ai-title`              | `aiTitle`: a generated session title, often repeated. Use the last one. |
| `last-prompt`           | `lastPrompt`, `leafUuid`.                             |
| `cost-state`            | `totalCostUSD`, `totalDuration`, `totalLinesAdded`, `totalLinesRemoved`, `modelUsage{model: {inputTokens, outputTokens, cacheReadInputTokens, cacheCreationInputTokens, costUSD}}`. The cost is the agent's own estimate. |
| `mode`, `permission-mode`, `agent-name` | Session settings.                     |
| `file-history-snapshot`, `file-history-delta` | Undo backups of edited files. Ignored. |
| `queue-operation`, `bridge-session`, `atis-latch` | Internal. Ignored.        |

Any other `type` must be counted as unknown and skipped.

### Message content

`message.content` is either:

- a **string**, which is a plain user prompt, or
- a **list of blocks**:

| Block         | Fields                                                        |
|---------------|---------------------------------------------------------------|
| `text`        | `text`                                                        |
| `thinking`    | `thinking`, `signature`. The text is often empty and only the signature is kept. |
| `tool_use`    | `id`, `name`, `input` (tool-specific object).                 |
| `tool_result` | `tool_use_id`, `content` (string, or a list of `text` / `image` / `tool_reference` blocks), `is_error` (`true`, `false` or absent). |
| `image`       | `source` (base64 data). Never index it.                      |

### Which `user` records are real prompts

A `user` record is a prompt the person typed when all of these are true:

- `message.content` is a string, or a list of `text`/`image` blocks with no
  `tool_result`.
- `isMeta` isn't `true`.
- The text doesn't start with a CLI wrapper: `<command-…>`,
  `<local-command-…>`, `<task-notification>`, `<bash-input>`, `<bash-stdout>`,
  `<bash-stderr>` or `[Request interrupted by user`. These are slash commands,
  `!` shell commands and their output, or background notifications. Wake shows
  them as system events.

In the sample, 342 user records were plain prompts, 59 were `isMeta` and 50
were command wrappers.

**Command-only sessions.** 9 of the 75 sessions in the sample contain nothing
but a slash command such as `/clear` (an `isMeta` caveat, the command wrapper
and its output). They have no prompt and no assistant response. Wake parses
them correctly with zero prompts. The browse UI should hide them by default.

### Assistant messages and token usage

**Important:** a single API response is written as **several** `assistant`
records, usually one per content block (thinking, text, tool_use). Each copy
has the same `message.id` and `requestId` and **repeats the same
`message.usage`**. In the sample, 3,259 of 4,473 responses were split this way.

So **count usage once per `message.id`**. Summing every record inflates the
totals by two to three times.

`message.usage` fields:

| Field                           | Meaning                               |
|---------------------------------|---------------------------------------|
| `input_tokens`                  | Uncached input.                       |
| `output_tokens`                 | Output, including thinking.           |
| `cache_creation_input_tokens`   | Cache writes.                         |
| `cache_read_input_tokens`       | Cache reads.                          |
| `cache_creation.ephemeral_5m_input_tokens` / `ephemeral_1h_input_tokens` | Cache writes split by TTL (priced differently). |
| `server_tool_use.web_search_requests` | Web searches.                   |

Other assistant fields: `message.model` (e.g. `claude-opus-5-5`) and
`message.stop_reason` (`tool_use`, `end_turn`, …).

When `message.model` is `<synthetic>`, the record is a locally generated
error, such as an API error, with `isApiErrorMessage: true`. Show it as an
Error event and don't count its usage.

### Linking tool calls and results

- The assistant `tool_use.id` matches the `tool_result.tool_use_id` in a later
  `user` record. In the sample every call had a matching result.
- The result is usually in the next record. With parallel tool calls it can be
  several records later, so pair results by id, not by position.
- The `user` record holding a result also has:
  - `sourceToolAssistantUUID`: the `uuid` of the assistant record that made
    the call.
  - `toolUseResult`: structured output that is richer than the text sent to
    the model. Its shape depends on the tool and it may be an object, a list
    or a string.

| Tool       | `toolUseResult` shape                                               |
|------------|---------------------------------------------------------------------|
| `Bash`     | `stdout`, `stderr`, `interrupted`, `isImage`, `noOutputExpected`. The command is in `tool_use.input.command`. |
| `Edit`     | `filePath`, `oldString`, `newString`, `replaceAll`, `originalFile`, `structuredPatch` (see below). |
| `Write`    | `type` (`create`/`update`), `filePath`, `content`, `structuredPatch` (empty on create), `originalFile` (`null` on create). |
| `Read`     | `type`, `file{filePath, content, numLines, startLine, totalLines}`. |
| `TodoWrite`| `oldTodos`, `newTodos`.                                             |
| `Agent`    | `agentId`, `description`, `prompt`, `status`, `resolvedModel`.      |
| `WebFetch` | `url`, `code`, `bytes`, `durationMs`, `result`.                     |
| MCP tools  | Usually a list of `{type, text}` blocks.                            |

`structuredPatch` is a list of unified-diff hunks:

```json
{"oldStart": 12, "oldLines": 3, "newStart": 12, "newLines": 4,
 "lines": [" context", "-removed", "+added", "+added", " context"]}
```

**Persisted output.** When a tool's output is very large, `toolUseResult`
holds `persistedOutputPath` (an absolute path into
`<sessionId>/tool-results/`) and `persistedOutputSize` (in bytes) instead of
the full text. Load the text from that file only on demand.

### Subagents

`<sessionId>/subagents/agent-<agentId>.jsonl` uses the same record format.

- Every record has `isSidechain: true` and an `agentId`.
- `sessionId` is the **parent** session's id.

`agent-<agentId>.meta.json` holds `agentType`, `description`, `toolUseId` (the
parent's `Agent` tool call) and `spawnDepth`. Wake treats a subagent as a
child of the parent session, attached to that tool call. Its tokens are
counted separately and also rolled up into the parent.

### Ordering

**Use file order, not timestamps.** In the sample, 1,517 consecutive
timestamped records went backwards in time. Most were under one second, but
some were up to an hour, for example an attachment written after the
assistant response it relates to. The `parentUuid` chain and the file order
agree.

Session start and end are the minimum and maximum timestamps in the file.
Duration is end minus start. It includes idle time. The `turn_duration` system
records hold active time.

### Ambiguities and open questions

- There is no schema version. `version` is the CLI version, which is the best
  proxy available.
- `thinking` text is usually empty (redacted), so Wake shows "thinking"
  without content in that case.
- The sample has no compaction (summary) records. If they show up, they'll be
  counted as unknown until they're documented here.
- `cost-state` gives the agent's own cost figure. Wake computes its own
  estimate from a user-editable price table and shows the agent's figure next
  to it, labelled as "reported by agent".
- The Windows and Linux locations haven't been verified against real files.

---

## Codex CLI

**Not yet checked.** On the reference machine `~/.codex` exists but contains
no session transcripts (only `memories/`, `skills/` and `tmp/`). Support is
planned after v0.1, once real sessions can be inspected.

## Gemini CLI

**Not yet checked.** Gemini CLI wasn't installed on the reference machine.
Support is planned after v0.1.
