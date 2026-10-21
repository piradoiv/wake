# Wake

Wake is a free, open-source desktop app for exploring the sessions you've had
with AI coding agents. It runs natively on macOS (Windows and Linux are planned) and is
built with [Xojo](https://www.xojo.com).

<img width="128" height="128" alt="wake-128" src="https://github.com/user-attachments/assets/9df06c02-c129-4bc4-8a52-9eb041ecb032" />

Coding agents such as Claude Code keep a full transcript of every session on
your machine, but those files are rarely read. Wake turns them into something
you can navigate: what the agent was asked, what it read, which commands it
ran, which files it changed and how many tokens it used.

<img width="1412" height="792" alt="Captura de pantalla 2026-10-21 a las 9 05 12" src="https://github.com/user-attachments/assets/ec7936c9-c0e4-4f44-8da6-bf98df0d54ea" />

> **Status:** Claude Code sessions are fully supported. Other coding agents are planned.

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
- **Watch sessions as they happen.** Wake checks for new and growing
  sessions every few seconds, and marks the ones an agent is writing to with
  a "Live" badge. An open timeline offers to reload when its session changes,
  so it never moves under you. Turn it off with View → Watch for Changes.
- **Export a session as Markdown** (File → Export as Markdown, Cmd+E): a
  summary, token totals, the prompts, every shell command and every file
  change as a fenced diff.

Wake keeps a search index, your prices and its settings in its own folder (the app data
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

<img width="1412" height="792" alt="Captura de pantalla 2026-10-21 a las 9 05 12" src="https://github.com/user-attachments/assets/e9a7456a-6013-43b2-9427-8b38ef9acffc" />

<img width="992" height="870" alt="Captura de pantalla 2026-10-21 a las 9 22 35" src="https://github.com/user-attachments/assets/ad4fbe65-bd7e-473c-87ab-bd2f0295370a" />

<img width="995" height="501" alt="Captura de pantalla 2026-10-21 a las 9 23 00" src="https://github.com/user-attachments/assets/7563b0e5-12c0-4f63-a1bc-8cdb0128a53a" />


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
