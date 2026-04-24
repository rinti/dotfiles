# Weekly Recap Task

Read `/tmp/weekly-recap-digest.txt`. It contains my Claude Code user prompts for the current work week (Monday 00:00 → Friday 14:00 local time), already filtered and grouped by day and project. Each prompt line has the form `[HH:MM] <text>`.

Summarize the digest into a weekly recap markdown file in my Obsidian vault.

## Summarization rules

For each `(day, project)` block in the digest:

- Produce 1–5 bullet points describing the **themes** of what I was trying to accomplish — not verbatim prompts. Focus on intent and outcome.
- End the block with a single-line `**TL;DR:**` — one sentence, ≤15 words, summarizing the project-day (don't restate the bullets).
- Skip any `(day, project)` where all prompts are trivial (e.g., `yes`, `ok`, `continue`) or slash-command invocations with no real content.

## Output

- Path: `/Users/andreas/Library/Mobile Documents/com~apple~CloudDocs/Obsidian/Obsidian iCloud/Weekly Recaps/YYYY-MM-DD.md`
- `YYYY-MM-DD` = **this Friday's date** (today, local). You can read it from the digest header.
- Create the `Weekly Recaps` folder if it doesn't exist.
- Overwrite if the file already exists.
- Write first to `/tmp/weekly-recap-YYYY-MM-DD.md`, then `mv` to the final path. Verify the final file exists and is non-empty.

## Format

```markdown
# Week of YYYY-MM-DD → YYYY-MM-DD

## Monday YYYY-MM-DD

### project-name
- theme 1
- theme 2

**TL;DR:** one short sentence.

### other-project
- theme 1

**TL;DR:** one short sentence.

## Tuesday YYYY-MM-DD

_No sessions._

## Wednesday YYYY-MM-DD
...
```

- Render `_No sessions._` under the H2 day heading for any weekday marked `(no prompts)` in the digest.
- Every `### project` block ends with a single-line **TL;DR:**.

## Steps

1. Read `/tmp/weekly-recap-digest.txt`.
2. Parse the week range from the header line.
3. For each day block: either render `_No sessions._`, or summarize each project (bullets + TL;DR).
4. Write to `/tmp/weekly-recap-YYYY-MM-DD.md`, then `mv` to the Obsidian path.
5. Print `OK: <final path>`.
