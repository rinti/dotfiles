# Launch Agents

This directory contains macOS launch agents for automating background tasks.

## Available Launch Agents

### com.user.weekly-recap.plist

Runs a weekly recap of Claude Code and Codex sessions every Friday at 14:00 local.

- **Script**: `~/dotfiles/weekly-recap/run.sh`
- **Task prompt**: `~/dotfiles/weekly-recap/task.md`
- **Schedule**: Friday 14:00 (missed runs catch up on next wake)
- **Output**: `~/Library/Mobile Documents/com~apple~CloudDocs/Obsidian/Obsidian iCloud/Weekly Recaps/YYYY-MM-DD.md`
- **Logs**:
  - Output: `/tmp/weekly-recap.log`
  - Errors: `/tmp/weekly-recap.err`

#### Management Commands

```bash
ln -sf ~/dotfiles/launchd/com.user.weekly-recap.plist ~/Library/LaunchAgents/com.user.weekly-recap.plist
launchctl load ~/Library/LaunchAgents/com.user.weekly-recap.plist

# Dry-run on demand (without waiting for Friday):
~/dotfiles/weekly-recap/run.sh

# Or trigger via launchd:
launchctl start com.user.weekly-recap
```

#### What it does

Reads `~/.claude/projects/*/*.jsonl` for the current work week (Mon 00:00 → Fri 14:00), filters real user prompts, groups by day and project, and asks Claude (Opus) to summarize themes into a markdown file in the Obsidian vault.

## Notes

- Launch agents are user-specific and run when the user is logged in
- The `RunAtLoad` key ensures the script runs immediately on login
- Logs are stored in `/tmp/` and will be cleared on system restart
