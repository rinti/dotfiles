#!/bin/bash

# Send Ctrl+C to the first pane (pane 0)
tmux send-keys -t 0 C-c

# Send Ctrl+C to the second pane (pane 1)
tmux send-keys -t 1 C-c