#!/bin/bash

if [ ! -f "extensions.txt" ]; then
    echo "Error: extensions.txt not found!"
    exit 1
fi

while IFS= read -r extension || [[ -n "$extension" ]]; do
    if [[ ! -z "$extension" ]]; then
        echo "Installing $extension..."
        code --install-extension "$extension"
    fi
done < extensions.txt

echo "All extensions installed!"
