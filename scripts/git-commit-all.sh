#!/bin/bash
# git-commit-all.sh - Commit staged changes across all projects
#
# Usage: ./git-commit-all.sh "commit message"
#
# Only commits in repos that have staged changes.
# Projects are auto-discovered: any subdirectory with a .git folder is included.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Auto-discover projects: find all subdirectories in category folders that are git repos
discover_projects() {
    for category in graphics math web network audio data apps util testing; do
        for dir in "$WORKSPACE_DIR/$category"/*/; do
            if [[ -d "${dir}.git" ]]; then
                echo "$category/$(basename "$dir")"
            fi
        done
    done | sort
}

if [[ -z "$1" ]]; then
    echo -e "${RED}Error:${NC} Commit message required"
    echo "Usage: $0 \"commit message\""
    exit 1
fi

COMMIT_MSG="$1"

echo -e "${BLUE}Committing staged changes across all projects...${NC}"
echo -e "Message: ${YELLOW}$COMMIT_MSG${NC}"
echo ""

committed_count=0
skipped_count=0
failed_count=0

for project in $(discover_projects); do
    project_dir="$WORKSPACE_DIR/$project"

    cd "$project_dir"

    # Check if there are staged changes
    if ! git diff --cached --quiet 2>/dev/null; then
        if git commit -m "$COMMIT_MSG" >/dev/null 2>&1; then
            echo -e "${GREEN}$project${NC}: committed"
            ((committed_count++))
        else
            echo -e "${RED}$project${NC}: commit failed"
            ((failed_count++))
        fi
    else
        echo -e "${YELLOW}$project${NC}: no staged changes"
        ((skipped_count++))
    fi
done

echo ""
echo -e "Summary: ${GREEN}$committed_count committed${NC}, ${YELLOW}$skipped_count skipped${NC}, ${RED}$failed_count failed${NC}"

if [[ $failed_count -gt 0 ]]; then
    exit 1
else
    exit 0
fi
