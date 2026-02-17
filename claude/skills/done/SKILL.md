---
name: done
description: "Create an end-of-session markdown handoff note from the current conversation and save it to ~/.claude-sessions/<project-name>. Use when the user runs /done or asks for a final recap with decisions, questions, follow-ups, and next steps."
---

# Done Skill

Create a concise but complete session note and save it locally.

## Workflow

1. Collect context from the current session: what was done, why it was done, and what changed.
2. Capture these sections in the note:
- Summary
- Key decisions
- Questions discussed
- Open questions
- Follow-ups
- Files changed
- Important commands
3. Resolve metadata:
- `session_id`: use `CLAUDE_SESSION_ID`; if missing, use `unknown-session`
- `branch`: run `git rev-parse --abbrev-ref HEAD 2>/dev/null || echo no-git`
- `timestamp`: run `date +"%Y-%m-%d_%H-%M-%S"`
- `project_name`: run `basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"`
4. Save the note to `~/.claude-sessions/<project-name>/<timestamp>__<branch>__<session_id>.md`.
- Sanitize project and branch names by replacing non `[A-Za-z0-9._-]` chars with `-`.

Use this shell pattern:

```bash
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo no-git)"
safe_branch="$(printf '%s' "$branch" | tr -cs '[:alnum:]._-' '-')"
project_name="$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")"
safe_project="$(printf '%s' "$project_name" | tr -cs '[:alnum:]._-' '-')"
session_id="${CLAUDE_SESSION_ID:-unknown-session}"
ts="$(date +%Y-%m-%d_%H-%M-%S)"
out_dir="$HOME/.claude-sessions/${safe_project}"
mkdir -p "$out_dir"
out="$out_dir/${ts}__${safe_branch}__${session_id}.md"
cat > "$out" <<'MD'
# Session Notes
Date: <YYYY-MM-DD HH:MM:SS>
Session: <session_id>
Branch: <branch>
Project: <project_name>

## Summary
- ...

## Key Decisions
- ...

## Questions Discussed
- ...

## Open Questions
- ...

## Follow-ups
- ...

## Files Changed
- ...

## Important Commands
- ...
MD
echo "$out"
```

## Output Rules

- Always create the file.
- Prefer bullet points over long paragraphs.
- If a section has no items, write `- None`.
- After saving, report the final file path.
