#!/bin/bash
#
# Setup tmux workspace with multiple windows
# Can be run outside tmux - will create session and attach
#

SESSION="dotfiles"

# If not inside tmux, create session and attach
if [ -z "$TMUX" ]; then
  tmux has-session -t "$SESSION" 2>/dev/null
  if [ $? != 0 ]; then
    tmux new-session -d -s "$SESSION"
  fi
  # Run this script inside the session, then attach
  tmux send-keys -t "$SESSION" "$0 --inside" Enter
  exec tmux attach -t "$SESSION"
fi

# Skip setup if called with --inside (already running via send-keys)
[ "$1" = "--inside" ] && sleep 0.1

# Only rename/create windows if they don't already exist
tmux rename-window py 2>/dev/null || true

# Get current window name
current_window=$(tmux display-message -p '#W')
echo "Current window: $current_window"

# Check if all required windows exist
required_windows=("py" "fe" "sh:1" "sh:2")

# Create any missing windows
for window in "${required_windows[@]}"; do
  if ! tmux list-windows | grep -q "$window"; then
    case "$window" in
      "py")
        [[ "$current_window" != "py" ]] && tmux new-window -n py
        ;;
      "fe") 
        [[ "$current_window" != "fe" ]] && tmux new-window -n fe
        ;;
      "sh:1"|"sh:2")
        [[ "$current_window" != "sh"* ]] && tmux new-window -n sh
        ;;
    esac
  fi
done
