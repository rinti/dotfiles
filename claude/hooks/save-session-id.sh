#!/bin/bash
# Saves current Claude session ID to a temp file keyed by process PID.
# Used by the /done skill to embed session ID in handoff notes.
session_id=$(jq -r '.session_id // empty')
[ -n "$session_id" ] && echo "$session_id" > "/tmp/claude-session-$PPID.id"
