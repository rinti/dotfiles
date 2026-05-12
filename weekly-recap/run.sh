#!/bin/bash
set -u
cd /Users/andreas/dotfiles/weekly-recap

echo "=== weekly-recap $(date '+%Y-%m-%d %H:%M:%S') ==="

digest=/tmp/weekly-recap-digest.txt
if ! /opt/homebrew/bin/python3 extract.py > "$digest"; then
    osascript -e 'display notification "extract.py failed — check /tmp/weekly-recap.err" with title "Weekly Recap"'
    exit 1
fi
echo "digest: $(wc -l < "$digest" | tr -d ' ') lines, $(wc -c < "$digest" | tr -d ' ') bytes"

/Users/andreas/.local/bin/claude \
    -p "Read task.md and execute it." \
    --model sonnet \
    --allowedTools 'Bash(*)' 'Read' 'Write' 'Edit' 'Glob' 'Grep' 'mcp__claude_ai_Google_Calendar__list_events'
status=$?

if [ $status -ne 0 ]; then
    osascript -e 'display notification "weekly-recap.sh failed — check /tmp/weekly-recap.err" with title "Weekly Recap"'
    exit $status
fi

friday=$(date '+%Y-%m-%d')
out="/Users/andreas/Library/Mobile Documents/com~apple~CloudDocs/Obsidian/Obsidian iCloud/Weekly Recaps/${friday}.md"
if [ ! -s "$out" ]; then
    osascript -e "display notification \"Expected output missing: ${friday}.md\" with title \"Weekly Recap\""
    exit 1
fi

echo "OK: $out"
