#!/usr/bin/env python3
"""Extract real user prompts from Claude Code JSONL transcripts for the current work week.

Prints a digest to stdout, grouped by local-time day and project.
Window: Monday 00:00 local → Friday 14:00 local of the current week.
"""

import json
import os
import sys
from collections import defaultdict
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

WRAPPERS = (
    "<local-command-caveat>",
    "<command-name>",
    "<command-message>",
    "<command-args>",
    "<command-stdout>",
    "<command-stderr>",
    "<system-reminder>",
    "<bash-input>",
    "<bash-stdout>",
    "<bash-stderr>",
    "<user-prompt-submit-hook>",
)

MAX_PROMPT_CHARS = 500
HOME_LABEL = "home/shell"


def week_window():
    now = datetime.now().astimezone()
    monday_00 = (now - timedelta(days=now.weekday())).replace(
        hour=0, minute=0, second=0, microsecond=0
    )
    friday_14 = monday_00 + timedelta(days=4, hours=14)
    return (
        monday_00.astimezone(timezone.utc),
        friday_14.astimezone(timezone.utc),
        monday_00.date(),
        friday_14.date(),
    )


def project_label(cwd: str) -> str:
    if cwd == str(Path.home()):
        return HOME_LABEL
    return os.path.basename(cwd.rstrip("/")) or "unknown"


def main() -> int:
    start_utc, end_utc, monday_date, friday_date = week_window()
    projects_dir = Path.home() / ".claude" / "projects"

    buckets: dict[tuple[date, str], list[tuple[str, str]]] = defaultdict(list)

    for jsonl in projects_dir.glob("*/*.jsonl"):
        try:
            fh = jsonl.open(errors="replace")
        except OSError:
            continue
        with fh:
            for line in fh:
                try:
                    m = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if m.get("type") != "user" or m.get("isMeta"):
                    continue
                msg = m.get("message") or {}
                if msg.get("role") != "user":
                    continue
                content = msg.get("content")
                if not isinstance(content, str):
                    continue
                stripped = content.lstrip()
                if stripped.startswith(WRAPPERS):
                    continue
                ts = m.get("timestamp")
                if not ts:
                    continue
                try:
                    ts_utc = datetime.fromisoformat(ts.replace("Z", "+00:00"))
                except ValueError:
                    continue
                if ts_utc < start_utc or ts_utc >= end_utc:
                    continue
                local_ts = ts_utc.astimezone()
                project = project_label(m.get("cwd", ""))
                text = stripped
                if len(text) > MAX_PROMPT_CHARS:
                    text = text[:MAX_PROMPT_CHARS] + "…"
                text = text.replace("\n", " ⏎ ")
                buckets[(local_ts.date(), project)].append(
                    (local_ts.strftime("%H:%M"), text)
                )

    out = [
        f"# Digest: week of {monday_date} → {friday_date} "
        f"(Mon 00:00 → Fri 14:00 local)\n"
    ]
    day_names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    for i, name in enumerate(day_names):
        day = monday_date + timedelta(days=i)
        out.append(f"\n## {name} {day}\n")
        projects = sorted({p for (d, p) in buckets if d == day})
        if not projects:
            out.append("(no prompts)\n")
            continue
        for project in projects:
            out.append(f"\n### {project}\n")
            for time_str, content in sorted(buckets[(day, project)]):
                out.append(f"[{time_str}] {content}\n")

    sys.stdout.write("".join(out))
    return 0


if __name__ == "__main__":
    sys.exit(main())
