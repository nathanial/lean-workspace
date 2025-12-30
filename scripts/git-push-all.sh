#!/bin/bash
# git-push-all.sh - Push all projects that have unpushed commits
#
# Usage: ./git-push-all.sh
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

echo -e "${BLUE}Pushing all projects with unpushed commits...${NC}"
echo ""

pushed_count=0
skipped_count=0
failed_count=0
no_remote_count=0

for project in $(discover_projects); do
    project_dir="$WORKSPACE_DIR/$project"

    cd "$project_dir"

    # Check if remote exists
    if ! git remote get-url origin >/dev/null 2>&1; then
        echo -e "${YELLOW}$project${NC}: no remote configured"
        ((no_remote_count++))
        continue
    fi

    # Fetch to check if we're ahead
    git fetch origin >/dev/null 2>&1 || true

    # Get current branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    # Check if branch has upstream and if we're ahead
    if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
        ahead=$(git rev-list --count "origin/$branch..HEAD" 2>/dev/null || echo "0")

        if [[ "$ahead" -gt 0 ]]; then
            if git push origin "$branch" 2>/dev/null; then
                echo -e "${GREEN}$project${NC}: pushed $ahead commit(s)"
                ((pushed_count++))
            else
                echo -e "${RED}$project${NC}: push failed"
                ((failed_count++))
            fi
        else
            echo -e "${YELLOW}$project${NC}: up to date"
            ((skipped_count++))
        fi
    else
        # No upstream branch, try to push and set upstream
        if git push -u origin "$branch" 2>/dev/null; then
            echo -e "${GREEN}$project${NC}: pushed (set upstream)"
            ((pushed_count++))
        else
            echo -e "${RED}$project${NC}: push failed (no upstream)"
            ((failed_count++))
        fi
    fi
done

echo ""
echo -e "Summary: ${GREEN}$pushed_count pushed${NC}, ${YELLOW}$skipped_count up-to-date${NC}, ${RED}$failed_count failed${NC}"
if [[ $no_remote_count -gt 0 ]]; then
    echo -e "         ${YELLOW}$no_remote_count without remote${NC}"
fi

if [[ $failed_count -gt 0 ]]; then
    exit 1
else
    exit 0
fi
