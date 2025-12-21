#!/usr/bin/env bash
# Remove package-overrides.json files to use git dependencies (production mode)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

echo "Removing package-overrides.json files..."
echo ""

count=0
for override_file in "$WORKSPACE_DIR"/*/.lake/package-overrides.json; do
    if [ -f "$override_file" ]; then
        rm "$override_file"
        echo "Removed: $override_file"
        ((count++))
    fi
done

if [ $count -eq 0 ]; then
    echo "No override files found."
else
    echo ""
    echo "Removed $count override file(s). Projects will now use git dependencies."
    echo "Run 'lake update' in each project to apply changes."
fi
