# Wake

Wake is a free, open-source desktop app for exploring the sessions you've had
with AI coding agents. It runs natively on macOS, Windows and Linux and is
built with [Xojo](https://www.xojo.com).

Coding agents such as Claude Code keep a full transcript of every session on
your machine, but those files are rarely read. Wake turns them into something
you can navigate: what the agent was asked, what it read, which commands it
ran, which files it changed and how many tokens it used.

> **Status:** v0.1 in progress. Claude Code sessions are fully supported.

## What it does

- **Browse** every session by agent and project, with its start time,
  duration, title, tokens and estimated cost. Sessions that hold only a slash
  command such as `/clear` are hidden unless you ask for them.
- **Read a session as a timeline** (double-click it, or Cmd+O): prompts and
  answers, tool calls with their output, file edits as coloured diffs, and
  subagents nested under the call that started them. Each response shows its
  time and tokens, each tool call its duration and the tokens its result
  added to the context, and each prompt the totals for its turn, all with
  their estimated cost.
- **Search** prompts, answers, commands and output across all sessions
  (Cmd+F), filtered by kind of event and by period. Opening a match scrolls
  the timeline to it.
- **See usage** per day, project or model for a period (Window → Usage, Cmd+U).
- **See where the tokens went** by intent, tool, tool and file type, shell
  command or file, in the same window. The figures are estimates from how the
  context grows between responses. Intents group calls by what they were
  after (a line range, a section, a whole file, a search, a listing, an edit,
  the web, a command) and say what would send less. Files read again in the
  same session are counted apart. Select a row to list its calls, most
  expensive first, and double-click one to open it in its timeline.
- **Export the findings as a report** (File → Export Report in the Usage
  window): a Markdown task list with a section per intent, its advice, the
  files it cost most on and the most expensive calls, ready to paste into an
  issue or hand to an agent.
- **Estimate costs** from your own price table (Window → Prices). Wake ships no
  prices, because they change: enter them per million tokens from your
  provider's price list. The cost the agent itself reports is shown next to
  Wake's estimate, labelled "reported by agent".
- **Export a session as Markdown** (File → Export as Markdown, Cmd+E): a
  summary, token totals, the prompts, every shell command and every file
  change as a fenced diff.

Wake keeps a search index and your prices in its own folder (the app data
folder, under `Wake`). The index is a cache: deleting it only makes the next
launch rebuild it.

## Principles

- **Read-only.** Wake never modifies, moves or deletes transcript files.
- **Local and private.** No network access and no telemetry. Your data stays
  on your machine, and exports are written only where you choose.
- **Robust.** Transcript formats are undocumented and change between agent
  versions. Wake skips and counts anything it doesn't understand, and shows
  partially parsed sessions with a note.

## Why "Wake"?

A boat leaves a wake behind it: a trail across the water that shows where it
has been. Coding agents leave one too, in the transcripts they write as they
work. Wake lets you look back along that trail to see what the agent was
asked, what it read, what it ran and what it changed, without ever disturbing
it.

## Supported agents

| Agent       | Status        | Versions tested     |
|-------------|---------------|---------------------|
| Claude Code | Supported     | 2.1.119 – 2.1.292   |
| Codex CLI   | Planned       | —                   |
| Gemini CLI  | Planned       | —                   |

See [docs/FORMATS.md](docs/FORMATS.md) for what Wake knows about each format.

## Screenshots

Coming soon.

## Building

1. Install the [Xojo IDE](https://www.xojo.com/download/) (2026r3 or later).
2. Open `Wake/Wake.xojo_project`.
3. Click **Run**.

You can run and debug Wake in the Xojo IDE for free. A Xojo license is only
needed to build standalone binaries.

## Running the tests

The tests use a vendored copy of [XojoUnit](https://github.com/xojo/XojoUnit)
(in `Wake/Tests/XojoUnit`) and run against the synthetic transcripts in
`tests/fixtures`.

1. Create an empty file named `WakeRunTests` in the `Wake/` folder.
2. Run the project from the Xojo IDE.

In debug runs, when Wake finds that marker it runs every test group, writes
JUnit XML to `tests/results.xml`, deletes the marker and quits.

## Contributing

Contributions are welcome. Please never commit real agent transcripts, because
they can contain secrets or private code. Tests use small, hand-written
fixtures in `tests/fixtures`.

## License

[MIT](LICENSE)
