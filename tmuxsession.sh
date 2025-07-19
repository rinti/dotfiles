#!/bin/sh
#
# Setup a work space called `work` with two windows
# first window has 3 panes. 
# The first pane set at 65%, split horizontally, set to api root and running vim
# pane 2 is split at 25% and running redis-server 
# pane 3 is set to api root and bash prompt.
# note: `api` aliased to `cd ~/path/to/work`
#

# create a new tmux session, starting vim from a saved session in the new window
# Select pane 1, set dir to api, run vim

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
