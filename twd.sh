#!/bin/bash

# Script Name: delete_numeric_tmux_sessions.sh
# Description: Deletes all tmux sessions with names consisting only of digits.

# Function to delete numeric-named sessions
delete_numeric_sessions() {
    # List all tmux sessions with their names
    tmux list-sessions -F "#{session_name}" 2>/dev/null | while read -r session; do
        # Check if the session name contains only digits
        if [[ "$session" =~ ^[0-9]+$ ]]; then
            echo "Deleting session '$session'"
            tmux kill-session -t "$session"
            if [[ $? -eq 0 ]]; then
                echo "Successfully deleted session '$session'"
            else
                echo "Failed to delete session '$session'"
            fi
        fi
    done
}

# Check if tmux is running
if ! tmux has-session 2>/dev/null; then
    echo "No tmux sessions are currently running."
    exit 0
fi

# Execute the deletion function
delete_numeric_sessions
