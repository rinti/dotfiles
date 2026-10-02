#!/usr/bin/env bash

input=$(cat)
total=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
transcript=$(echo "$input" | jq -r '.transcript_path // empty')

used=''
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  used=$(grep '"type":"assistant"' "$transcript" 2>/dev/null \
    | jq -r 'select(.message.usage.input_tokens != null) | (.message.usage.input_tokens // 0) + (.message.usage.cache_read_input_tokens // 0) + (.message.usage.cache_creation_input_tokens // 0)' 2>/dev/null \
    | tail -1)
fi

if [ -z "$used" ] || [ "$used" = "null" ]; then
  pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
  if [ -n "$pct" ] && [ "$total" != "0" ]; then
    used=$(awk "BEGIN{printf \"%.0f\", ($pct/100)*$total}")
  fi
fi

total_k=$(printf '%.0fk' "$(echo "$total / 1000" | bc -l)")

# ANSI codes
RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
WHITE='\033[37m'

if [ -n "$used" ] && [ -n "$total" ] && [ "$total" != "0" ]; then
  cur_k=$(awk "BEGIN{printf \"%.1fk\", $used/1000}")
  pct_exact=$(awk "BEGIN{printf \"%.0f\", ($used/$total)*100}")

  # Pick color based on raw token count
  if [ "$used" -le 200000 ]; then
    used_color="$GREEN"
  elif [ "$used" -le 400000 ]; then
    used_color="$YELLOW"
  else
    used_color="$RED"
  fi

  printf "${BOLD}${used_color}${cur_k}${RESET}/${BOLD}${WHITE}${total_k}${RESET} (${pct_exact}%%)"
elif [ -n "$total" ] && [ "$total" != "0" ]; then
  printf "${BOLD}${GREEN}0k${RESET}/${BOLD}${WHITE}${total_k}${RESET}"
fi

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null \
    || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  cwd="${cwd/#$HOME/~}"
  printf " %s" "$cwd"
  if [ -n "$branch" ]; then
    printf " ${BOLD}${YELLOW}(%s)${RESET}" "$branch"
  fi
fi
