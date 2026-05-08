#!/bin/bash
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

# Rebuild if source is newer than the binary (or binary doesn't exist).
if [ ! -f cow ] || [ cow.swift -nt cow ]; then
    echo "Building cow..."
    swiftc -O -o cow cow.swift
fi

exec ./cow "$@"
