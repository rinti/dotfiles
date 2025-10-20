# Launch Agents

This directory contains macOS launch agents for automating background tasks.

## Setup

To install the launch agents, create symlinks to `~/Library/LaunchAgents/`:

```bash
ln -sf ~/dotfiles/launchd/com.user.twd.plist ~/Library/LaunchAgents/com.user.twd.plist
launchctl load ~/Library/LaunchAgents/com.user.twd.plist
```

## Available Launch Agents

### com.user.twd.plist

Automatically cleans up numeric-named tmux sessions every 15 minutes.

- **Script**: `~/dotfiles/twd.sh`
- **Interval**: 900 seconds (15 minutes)
- **Auto-start**: Runs on login
- **Logs**:
  - Output: `/tmp/twd.log`
  - Errors: `/tmp/twd.err`

#### Management Commands

```bash
# Load (start) the agent
launchctl load ~/Library/LaunchAgents/com.user.twd.plist

# Unload (stop) the agent
launchctl unload ~/Library/LaunchAgents/com.user.twd.plist

# Check if agent is running
launchctl list | grep com.user.twd

# View logs
tail -f /tmp/twd.log
tail -f /tmp/twd.err
```

#### What it does

The `twd.sh` script deletes all tmux sessions with names consisting only of digits (e.g., "123", "456"). This is useful for cleaning up automatically-created numeric session names that accumulate over time.

## Notes

- Launch agents are user-specific and run when the user is logged in
- The `RunAtLoad` key ensures the script runs immediately on login
- Logs are stored in `/tmp/` and will be cleared on system restart
