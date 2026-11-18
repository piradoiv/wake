# Cutting token use with Wake: a loop for coding agents

Hand this file to a coding agent (or point it here from its instruction
file) and run it every week or so. The agent reads what Wake measured about
its own sessions, changes one thing, and checks later whether that helped.

Wake only reads transcripts. Everything below changes the project, never
Wake or the transcripts.

## Each run

1. **See where the tokens went.** In the project folder:

   ```
   wake report --project . --since 14d
   ```

   The report lists the kinds of tool calls that cost most (reading line
   ranges or whole files, searching, re-reading files already read, running
   commands…), the files each one cost most on, the reads that led nowhere
   and the sessions that carried most. `wake usage --project . --by intent`
   is the same as a short table.

2. **Look at the calls behind the biggest one.** For example:

   ```
   wake calls --project . --key "Re-read" --snippets
   wake calls --project . --by file --key src/some/file --snippets
   ```

   `--snippets` shows what each call asked for. Within the agent's own
   project that's fine; leave it off when the output may end up elsewhere.

3. **Find the cause, and change one thing.** Look for a cause that a
   developer would recognize, not a number to push down. Typical ones:

   - The same file is read again and again, or always read whole: a short
     note in the instruction file (`CLAUDE.md`, `AGENTS.md`…) on the
     project's layout, what that file holds and where to look, so the agent
     reads less or only the part it needs.
   - Searches or listings return far more than was used: a note on where
     things live, or a narrower search the project's tools allow.
   - Command output is long (builds, tests, logs): a small script that runs
     the command and prints only failures and a summary, and a note in the
     instruction file to use it.
   - The same multi-step action is done by hand in many sessions: a script
     or command that does it in one call.
   - Long sessions carry a lot: a note to start a new session, or compact,
     between unrelated tasks.

   Make **one** change per run, so the next comparison can tell what it did.

4. **Write it down.** Keep a short log in the project, such as
   `docs/token-log.md`: the date, what changed and why, and the figures it
   was meant to move. Commit the change and the log together.

5. **Next run, check the last change first:**

   ```
   wake compare --project . --at 2026-11-18
   ```

   with the date from the log. It compares rates (tokens per session and per
   prompt, tool calls per prompt, tokens per call, and the share of tokens
   that went to each kind of call), so a busier week doesn't look worse.
   Keep the change if the rates it aimed at went down, rework or revert it
   if they didn't, and note the result in the log. Then go back to step 1.

## Cautions

- **Cut waste, not work.** A read the task needed is not waste. Aim at the
  signals that mean waste: reads that led nowhere, files read again in the
  same context, output nobody used, long sessions carrying old turns. Never
  tell the agent to read less in general: it saves tokens by doing worse
  work.
- **Small samples are noise.** When `wake compare` says a side has too few
  sessions, wait for more work before deciding.
- **Keep the changes general.** Instruction-file notes and scripts should
  help any task in the project, not the one session that showed the
  problem.
- **Mind what you copy.** Snippets and session titles come from the
  transcripts. Don't paste them into files that leave the computer unless
  they're fine to share.
