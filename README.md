# Wake

Wake is a free, open-source desktop app for exploring the sessions you've had
with AI coding agents. It runs natively on macOS, Windows and Linux and is
built with [Xojo](https://www.xojo.com).

Coding agents such as Claude Code keep a full transcript of every session on
your machine, but those files are rarely read. Wake turns them into something
you can navigate: what the agent was asked, what it read, which commands it
ran, which files it changed and how many tokens it used.

> **Status:** early development, working toward v0.1.

## Principles

- **Read-only.** Wake never modifies, moves or deletes transcript files.
- **Local and private.** No network access and no telemetry. Your data stays
  on your machine.
- **Robust.** Transcript formats are undocumented and change between agent
  versions. Wake skips and counts anything it doesn't understand, and shows
  partially parsed sessions with a note.

## Supported agents

| Agent       | Status        | Versions tested     |
|-------------|---------------|---------------------|
| Claude Code | In progress   | 2.1.119 – 2.1.292   |
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

## Contributing

Contributions are welcome. Please never commit real agent transcripts, because
they can contain secrets or private code. Tests use small, hand-written
fixtures in `tests/fixtures`.

## License

[MIT](LICENSE)
