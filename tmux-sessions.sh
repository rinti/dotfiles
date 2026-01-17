#!/bin/bash

# Define sessions: "path:session-name"
SESSIONS=(
    "~/dotfiles:dotfiles"
    "~/dev/delight:lådan"
    "~/dev/ladan-delight-iac:lådan-iac"
    "~/dev/amex:amex"
    "~/dev/amex/backend:amex-backend"
    "~/dev/amex/frontend:amex-frontend"
    "~/dev/amex/SBR-Base:visitstockholm"
    "~/dev/amex/SBR-stockholmbusinessregion.com:sbr-com"
    "~/dev/amex/SBR-stockholmbusinessregion.se:sbr-se"
)

WINDOWS=("vim" "be" "fe" "cc")

EXEMPT=()

# Get list of allowed session names
allowed_sessions=()
for entry in "${SESSIONS[@]}"; do
    name="${entry#*:}"
    allowed_sessions+=("$name")
done

# Kill sessions not in allowed or exempt list
current_sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
for session in $current_sessions; do
    if [[ " ${EXEMPT[*]} " =~ " ${session} " ]]; then
        continue
    fi
    if [[ ! " ${allowed_sessions[*]} " =~ " ${session} " ]]; then
        tmux kill-session -t "=$session"
        echo "Killed session: $session"
    fi
done

# Create sessions
for entry in "${SESSIONS[@]}"; do
    path="${entry%:*}"
    path="${path/#\~/$HOME}"
    name="${entry#*:}"

    if tmux has-session -t "=$name" 2>/dev/null; then
        echo "Session exists: $name"
        continue
    fi

    # Create session with first window
    tmux new-session -d -s "$name" -n "${WINDOWS[0]}" -c "$path"

    # Create remaining windows
    for ((i=1; i<${#WINDOWS[@]}; i++)); do
        tmux new-window -t "=$name" -n "${WINDOWS[$i]}" -c "$path"
    done

    # Select first window
    tmux select-window -t "=$name:${WINDOWS[0]}"

    echo "Created session: $name"
done
