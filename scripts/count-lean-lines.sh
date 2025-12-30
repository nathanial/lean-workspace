#!/bin/bash
# Count lines of Lean code across the workspace, excluding .lake directories

set -e

WORKSPACE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Auto-detect projects by finding directories with lakefile.lean in category folders
PROJECTS=()
for category in graphics math web network audio data apps util testing; do
    for dir in "$WORKSPACE_DIR/$category"/*/; do
        if [ -f "$dir/lakefile.lean" ]; then
            PROJECTS+=("$category/$(basename "$dir")")
        fi
    done
done

# Sort projects alphabetically
IFS=$'\n' PROJECTS=($(sort <<<"${PROJECTS[*]}")); unset IFS

total_lines=0
total_files=0

printf "%-25s %10s %10s\n" "Project" "Files" "Lines"
printf "%-25s %10s %10s\n" "-------" "-----" "-----"

for project in "${PROJECTS[@]}"; do
    project_dir="$WORKSPACE_DIR/$project"
    # Find all .lean files, excluding .lake directories
    files=$(find "$project_dir" -name "*.lean" -not -path "*/.lake/*" 2>/dev/null)
    if [ -n "$files" ]; then
        file_count=$(echo "$files" | wc -l | tr -d ' ')
        line_count=$(echo "$files" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
        # Handle case where there's only one file (no "total" line from wc)
        if [ "$file_count" -eq 1 ]; then
            line_count=$(wc -l < "$(echo "$files" | head -1)" | tr -d ' ')
        fi
        printf "%-25s %10d %10d\n" "$project" "$file_count" "$line_count"
        total_lines=$((total_lines + line_count))
        total_files=$((total_files + file_count))
    else
        printf "%-25s %10d %10d\n" "$project" 0 0
    fi
done

printf "%-25s %10s %10s\n" "-------" "-----" "-----"
printf "%-25s %10d %10d\n" "TOTAL" "$total_files" "$total_lines"
