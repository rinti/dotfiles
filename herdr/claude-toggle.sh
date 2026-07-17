#!/bin/sh
# Toggle between the "claude" tab and the previously focused tab
# in the active workspace. Bound to cmd+l via [[keys.command]].
set -eu

herdr=${HERDR_BIN_PATH:-herdr}
ws=$HERDR_ACTIVE_WORKSPACE_ID
active=$HERDR_ACTIVE_TAB_ID
state_dir=${TMPDIR:-/tmp}/herdr-claude-toggle
state_file=$state_dir/$ws
mkdir -p "$state_dir"

claude=$("$herdr" tab list --workspace "$ws" |
  jq -r '.result.tabs[] | select(.label == "claude") | .tab_id' | head -1)
[ -n "$claude" ] || exit 0

if [ "$active" = "$claude" ]; then
  prev=$(cat "$state_file" 2>/dev/null || true)
  [ -n "$prev" ] && "$herdr" tab focus "$prev"
else
  printf '%s' "$active" > "$state_file"
  "$herdr" tab focus "$claude"
fi
