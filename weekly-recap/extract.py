#!/usr/bin/env python3
"""Extract real user prompts from Claude Code and Codex JSONL transcripts for the current work week.

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
    "<local-command-stdout>",
    "<local-command-stderr>",
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
SOURCE_NOTES = (
    "Claude JSONL: records use top-level type=user with message.role=user, "
    "timestamp/cwd on the same object, and tool or wrapper events can appear as "
    "synthetic user messages.",
    "Codex JSONL: records are rollout events; real user prompts are event_msg "
    "payloads with payload.type=user_message, while response_item user messages "
    "can include injected context such as AGENTS.md instructions.",
)


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


def parse_timestamp(ts: str):
    try:
        return datetime.fromisoformat(ts.replace("Z", "+00:00"))
    except ValueError:
        return None


def clean_prompt(content: str) -> str | None:
    stripped = content.lstrip()
    codex_request_marker = "## My request for Codex:"
    if codex_request_marker in stripped:
        stripped = stripped.split(codex_request_marker, 1)[1].lstrip()
    if stripped.startswith(WRAPPERS):
        return None
    if len(stripped) > MAX_PROMPT_CHARS:
        stripped = stripped[:MAX_PROMPT_CHARS] + "…"
    return stripped.replace("\n", " ⏎ ")


def add_prompt(
    buckets: dict[tuple[date, str], list[tuple[str, str, str]]],
    start_utc: datetime,
    end_utc: datetime,
    *,
    source: str,
    cwd: str,
    timestamp: str,
    content: str,
) -> None:
    text = clean_prompt(content)
    if not text:
        return
    ts_utc = parse_timestamp(timestamp)
    if ts_utc is None or ts_utc < start_utc or ts_utc >= end_utc:
        return
    local_ts = ts_utc.astimezone()
    buckets[(local_ts.date(), project_label(cwd))].append(
        (local_ts.strftime("%H:%M"), source, text)
    )


def collect_claude_prompts(
    buckets: dict[tuple[date, str], list[tuple[str, str, str]]],
    start_utc: datetime,
    end_utc: datetime,
) -> None:
    projects_dir = Path.home() / ".claude" / "projects"
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
                if m.get("isSidechain") or m.get("agentId"):
                    continue
                if m.get("type") != "user" or m.get("isMeta"):
                    continue
                msg = m.get("message") or {}
                if msg.get("role") != "user":
                    continue
                content = msg.get("content")
                if not isinstance(content, str):
                    continue
                ts = m.get("timestamp")
                if not ts:
                    continue
                add_prompt(
                    buckets,
                    start_utc,
                    end_utc,
                    source="Claude",
                    cwd=m.get("cwd", ""),
                    timestamp=ts,
                    content=content,
                )


def collect_codex_prompts(
    buckets: dict[tuple[date, str], list[tuple[str, str, str]]],
    start_utc: datetime,
    end_utc: datetime,
) -> None:
    sessions_dir = Path.home() / ".codex" / "sessions"
    for jsonl in sessions_dir.glob("*/*/*/*.jsonl"):
        cwd = ""
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
                payload = m.get("payload") or {}
                if m.get("type") == "session_meta":
                    cwd = payload.get("cwd") or cwd
                    continue
                if m.get("type") != "event_msg" or payload.get("type") != "user_message":
                    continue
                content = payload.get("message")
                if not isinstance(content, str):
                    continue
                ts = m.get("timestamp")
                if not ts:
                    continue
                add_prompt(
                    buckets,
                    start_utc,
                    end_utc,
                    source="Codex",
                    cwd=cwd,
                    timestamp=ts,
                    content=content,
                )


def main() -> int:
    start_utc, end_utc, monday_date, friday_date = week_window()
    buckets: dict[tuple[date, str], list[tuple[str, str, str]]] = defaultdict(list)

    collect_claude_prompts(buckets, start_utc, end_utc)
    collect_codex_prompts(buckets, start_utc, end_utc)

    out = [
        f"# Digest: week of {monday_date} → {friday_date} "
        f"(Mon 00:00 → Fri 14:00 local)\n",
        "\n## Source notes\n",
    ]
    for note in SOURCE_NOTES:
        out.append(f"- {note}\n")

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
            for time_str, source, content in sorted(buckets[(day, project)]):
                out.append(f"[{time_str}] [{source}] {content}\n")

    sys.stdout.write("".join(out))
    return 0


if __name__ == "__main__":
    sys.exit(main())
