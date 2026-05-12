# Weekly Recap Task

Read `/tmp/weekly-recap-digest.txt`. It contains my Claude Code and Codex user prompts for the current work week (Monday 00:00 → Friday 14:00 local time), already filtered and grouped by day and project. Each prompt line has the form `[HH:MM] [Source] <text>`, where `Source` is `Claude` or `Codex`.

The digest may include a `## Source notes` section before the day sections. Use it to understand differences between Claude and Codex JSONL formats; do not render it as a weekday. If those differences affected the recap, add a brief note near the top of the output under `> Source note: ...`.

Also fetch this week's meetings from Google Calendar via the `mcp__claude_ai_Google_Calendar__list_events` tool. Query my primary calendar for the same window as the digest (Monday 00:00 → Friday 14:00 local, parsed from the digest header). Only include events I actually attended or was a confirmed attendee of — skip declined events and all-day non-meeting blocks (focus time, OOO, personal reminders, holidays). If an event has no clear meeting purpose (e.g., a calendar block for solo work), skip it.

Always skip the recurring daily standup titled `Fröjd: Tech standup` — it's daily and not worth reporting.

Summarize the digest into a weekly recap markdown file in my Obsidian vault.

## Summarization rules

For each `(day, project)` block in the digest:

- Produce 1–5 bullet points describing the **themes** of what I was trying to accomplish — not verbatim prompts. Focus on intent and outcome.
- When useful, mention whether work came mainly from Claude, Codex, or both. Do not force a source mention into every bullet.
- End the block with a single-line `**TL;DR:**` — one sentence, ≤15 words, summarizing the project-day (don't restate the bullets).
- Skip any `(day, project)` where all prompts are trivial (e.g., `yes`, `ok`, `continue`) or slash-command invocations with no real content.
- If Codex and Claude JSONL source notes reveal any meaningful recap difference, such as injected Codex context being excluded or Claude synthetic wrapper messages being filtered, include it once in the optional source note.

## Output

- Path: `/Users/andreas/Library/Mobile Documents/com~apple~CloudDocs/Obsidian/Obsidian iCloud/Weekly Recaps/YYYY-MM-DD.md`
- `YYYY-MM-DD` = **this Friday's date** (today, local). You can read it from the digest header.
- Create the `Weekly Recaps` folder if it doesn't exist.
- Overwrite if the file already exists.
- Write first to `/tmp/weekly-recap-YYYY-MM-DD.md`, then `mv` to the final path. Verify the final file exists and is non-empty.

## Format

```markdown
# Week of YYYY-MM-DD → YYYY-MM-DD

## Time Report

**Monday YYYY-MM-DD**
- project-a — terse one-line summary suitable for a time report
- project-b — terse one-line summary
- Meetings: 30 min "Standup", 1 h "Client review"

**Tuesday YYYY-MM-DD**
_No sessions._

**Wednesday YYYY-MM-DD**
- project-c — terse one-line summary
- Meetings: (none)

...

---

> Source note: Codex and Claude sessions were parsed from different JSONL event shapes.

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

### Time Report rules

- Per day, list one bullet per project worked on that day: `- project-name — terse one-line summary`. Wording should be different from the TL;DR — written for a time-reporting tool, not a recap.
- If the day had no sessions, render `_No sessions._` under the bold day heading (still include a `Meetings:` line below if there were meetings that day).
- After project bullets, add a `- Meetings:` line:
  - If there were meetings: `- Meetings: 30 min "Standup", 1 h "Client review"`. Use `min` for under 60 minutes, `h` for whole hours, `h Xmin` for mixed (e.g. `1 h 30 min`). Quote the meeting title verbatim.
  - If there were no meetings that day: `- Meetings: (none)`.
- Separate the Time Report from the detail section with a `---` horizontal rule.

### Detail rules

- Render `_No sessions._` under the H2 day heading for any weekday marked `(no prompts)` in the digest.
- Every `### project` block ends with a single-line **TL;DR:**.

## Steps

1. Read `/tmp/weekly-recap-digest.txt`.
2. Parse the week range from the header line.
3. Read any `## Source notes`; decide whether a short output source note is warranted.
4. Call `mcp__claude_ai_Google_Calendar__list_events` for the same Mon 00:00 → Fri 14:00 local window. Filter to meetings I attended (skip declined / OOO / focus-time / all-day reminders). Group by local day.
5. Build the Time Report block: per day, one terse bullet per project (different wording from TL;DR) plus a `Meetings:` line.
6. Build the detail section: for each day block either render `_No sessions._`, or summarize each project (bullets + TL;DR).
7. Write to `/tmp/weekly-recap-YYYY-MM-DD.md`, then `mv` to the Obsidian path.
8. Print `OK: <final path>`.
