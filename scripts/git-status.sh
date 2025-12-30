#!/bin/bash
# git-status.sh - Check git status across all projects in the workspace
#
# Usage: ./git-status.sh [-v|--verbose]
#   -v, --verbose  Show detailed git status for each dirty repo
#
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

VERBOSE=false
if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    VERBOSE=true
fi

echo -e "${BLUE}Checking git status for all projects...${NC}"
echo ""

clean_count=0
dirty_count=0

for project in $(discover_projects); do
    project_dir="$WORKSPACE_DIR/$project"

    cd "$project_dir"

    # Check for any changes (staged, unstaged, or untracked)
    if git diff --quiet HEAD 2>/dev/null && git diff --cached --quiet 2>/dev/null && [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
        echo -e "${GREEN}$project${NC}: clean"
        ((clean_count++))
    else
        echo -e "${RED}$project${NC}: has changes"
        ((dirty_count++))

        if $VERBOSE; then
            # Show summary of changes
            staged=$(git diff --cached --stat 2>/dev/null | tail -1)
            unstaged=$(git diff --stat 2>/dev/null | tail -1)
            untracked=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

            if [[ -n "$staged" ]]; then
                echo -e "  ${GREEN}Staged:${NC} $staged"
            fi
            if [[ -n "$unstaged" ]]; then
                echo -e "  ${YELLOW}Unstaged:${NC} $unstaged"
            fi
            if [[ "$untracked" -gt 0 ]]; then
                echo -e "  ${RED}Untracked:${NC} $untracked files"
            fi
            echo ""
        fi
    fi
done

echo ""
echo -e "Summary: ${GREEN}$clean_count clean${NC}, ${RED}$dirty_count dirty${NC}"

if [[ $dirty_count -gt 0 ]]; then
    exit 1
else
    exit 0
fi
