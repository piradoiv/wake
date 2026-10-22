<p align="center">
  <img src="https://github.com/user-attachments/assets/9df06c02-c129-4bc4-8a52-9eb041ecb032" width="128" height="128" alt="Wake app icon">
</p>

<h1 align="center">Wake</h1>

<p align="center">
  <b>See what your coding agent really did, and where your tokens went.</b>
</p>

<p align="center">
  <a href="https://github.com/piradoiv/wake/releases/latest/download/Wake-macOS.zip">
    <img src="https://img.shields.io/badge/Download_for_macOS-Free-2f6fde?style=for-the-badge&logo=apple" alt="Download Wake for macOS">
  </a>
  <br>
  <sub>Free and open source · Signed and notarized · Never goes online</sub>
</p>

<img width="1412" height="792" alt="Wake's main window listing Claude Code sessions by project with their duration, tokens and cost, in front of the Usage window with cost per day" src="https://github.com/user-attachments/assets/ec7936c9-c0e4-4f44-8da6-bf98df0d54ea" />

Claude Code keeps a full transcript of every session on your Mac, and almost
nobody reads them. Wake opens them up. Replay any session step by step, find
the command your agent ran last Tuesday, and see exactly which reads, searches
and commands filled your context.

## Why you'll like it

- **Replay any session.** Prompts, answers, commands and diffs in one
  timeline, with subagents nested where they ran.
- **Find anything.** Search every prompt, answer and command output across
  all your projects at once.
- **Learn why a session got expensive.** Every reply re-sends the whole
  conversation, so a long session pays for its first turns again and again.
  Wake shows you where that started, and which calls cost you the most.
- **Hand the fix back to your agent.** Export a Markdown checklist of what
  would have sent less, ready to paste into an issue or a prompt.
- **Watch sessions live** while your agent is still working.

**Your transcripts never leave your Mac.** Wake only reads them. It doesn't
change them, doesn't connect to the internet and doesn't collect anything.

## Install

1. [Download Wake](https://github.com/piradoiv/wake/releases/latest/download/Wake-macOS.zip)
   and unzip it. Release notes and older versions are on the
   [Releases page](https://github.com/piradoiv/wake/releases).
2. Drag **Wake** to your Applications folder and open it.
3. That's it. Wake finds your Claude Code sessions on its own and indexes them
   in a few seconds.

Wake runs on macOS. Windows and Linux versions are planned.

## Feature tour

### Every session, at a glance

Sessions are grouped by agent and project, with when they started, how long
they took, their title, tokens and estimated cost. Sessions that hold only a
slash command such as `/clear` are hidden unless you ask for them.

### A timeline for each session

Double-click a session (or press Cmd+O) to read it as a timeline: prompts and
answers, tool calls with their output, file edits as coloured diffs, and
subagents nested under the call that started them. Each response shows its
time and tokens, each tool call how long it took and how much it added to the
context, and each prompt the totals for its turn.

<img width="995" height="501" alt="A session timeline with its cost, tokens, duration and prompts, and a shell command expanded to show its output and what it added to the context" src="https://github.com/user-attachments/assets/7563b0e5-12c0-4f63-a1bc-8cdb0128a53a" />

### Search across everything

Press Cmd+F to search prompts, answers, commands and output across all your
sessions, filtered by kind of event and by period. Opening a match scrolls the
timeline right to it.

### Where the tokens went

The Usage window (Cmd+U) shows your usage per day, project or model, and
breaks it down by what the agent was doing: reading a line range or a whole
file, searching, listing, editing, browsing the web or running commands. Each
group comes with a tip on what would send less. Files read again in the same
session are counted apart. Pick a row to see its most expensive calls, and
double-click one to jump to it in its timeline.

<img width="992" height="870" alt="The Usage window grouping a week of tool calls by intent, with the most expensive shell commands listed below and a tip on how to send less" src="https://github.com/user-attachments/assets/ad4fbe65-bd7e-473c-87ab-bd2f0295370a" />

### Why long sessions cost more

Every response sends the whole context again, so a long session keeps paying
for its early turns. Wake estimates that cost for each turn (shown as
**≈ carried**) in the sessions list, the Usage window and on each prompt. A
timeline opens with a curve of the context size per response, with compactions
marked. Click a point to jump to that turn.

### Reports you can act on

- **Export a report** from the Usage window (File → Export Report): a Markdown
  task list with what cost most, the advice for each kind of call and the
  sessions that carried most, ready to paste into an issue or hand to an agent.
- **Export a session** as Markdown (File → Export as Markdown, Cmd+E): a
  summary, token totals, the prompts, every shell command and every file change
  as a diff.

### Your own prices

Wake ships no prices, because they change. Enter them per million tokens from
your provider's price list (Window → Prices), and Wake estimates every cost
from them. When the agent reports a cost itself, Wake shows it next to its own
estimate. Tokens are counted with or without prices.

### Live sessions

Wake checks for new and growing sessions every few seconds and marks the ones
an agent is writing to with a "Live" badge. An open timeline offers to reload
when its session changes, so it never moves under you. Turn this off with
View → Watch for Changes.

## Principles

- **Read-only.** Wake never modifies, moves or deletes transcript files.
- **Local and private.** No network access and no telemetry. Your data stays
  on your machine, and exports are written only where you choose.
- **Robust.** Transcript formats are undocumented and change between agent
  versions. Wake skips and counts anything it doesn't understand, and shows
  partially parsed sessions with a note.

Wake keeps a search index, your prices and its settings in its own folder (the
app data folder, under `Wake`). The index is a cache: deleting it only makes
the next launch rebuild it.

## Supported agents

| Agent       | Status        | Versions tested     |
|-------------|---------------|---------------------|
| Claude Code | Supported     | 2.1.119 – 2.1.292   |
| Codex CLI   | Planned       | —                   |
| Gemini CLI  | Planned       | —                   |

See [docs/FORMATS.md](docs/FORMATS.md) for what Wake knows about each format.

## Why "Wake"?

A boat leaves a wake behind it: a trail across the water that shows where it
has been. Coding agents leave one too, in the transcripts they write as they
work. Wake lets you look back along that trail to see what the agent was
asked, what it read, what it ran and what it changed, without ever disturbing
it.

## Building

Wake is built with [Xojo](https://www.xojo.com).

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
