#!/bin/bash
# git-add-commit-push.sh - Stage all, commit, and push across all projects
#
# Usage: ./git-add-commit-push.sh "commit message"
#
# For each project with changes:
#   1. Stage all changes (git add -A)
#   2. Commit with the provided message
#   3. Push to origin
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

if [[ -z "$1" ]]; then
    echo -e "${RED}Error:${NC} Commit message required"
    echo "Usage: $0 \"commit message\""
    exit 1
fi

COMMIT_MSG="$1"

echo -e "${BLUE}Add, commit, and push across all projects...${NC}"
echo -e "Message: ${YELLOW}$COMMIT_MSG${NC}"
echo ""

success_count=0
skipped_count=0
failed_count=0

for project in $(discover_projects); do
    project_dir="$WORKSPACE_DIR/$project"

    cd "$project_dir"

    # Check for any changes (staged, unstaged, or untracked)
    has_staged=false
    has_unstaged=false
    has_untracked=false

    if ! git diff --cached --quiet 2>/dev/null; then
        has_staged=true
    fi
    if ! git diff --quiet HEAD 2>/dev/null; then
        has_unstaged=true
    fi
    if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
        has_untracked=true
    fi

    if ! $has_staged && ! $has_unstaged && ! $has_untracked; then
        echo -e "${YELLOW}$project${NC}: no changes"
        ((skipped_count++))
        continue
    fi

    # Stage all changes
    git add -A

    # Commit
    if ! git commit -m "$COMMIT_MSG" >/dev/null 2>&1; then
        echo -e "${RED}$project${NC}: commit failed"
        ((failed_count++))
        continue
    fi

    # Push
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    if ! git remote get-url origin >/dev/null 2>&1; then
        echo -e "${YELLOW}$project${NC}: committed (no remote to push)"
        ((success_count++))
        continue
    fi

    if git push origin "$branch" 2>/dev/null; then
        echo -e "${GREEN}$project${NC}: committed and pushed"
        ((success_count++))
    elif git push -u origin "$branch" 2>/dev/null; then
        echo -e "${GREEN}$project${NC}: committed and pushed (set upstream)"
        ((success_count++))
    else
        echo -e "${YELLOW}$project${NC}: committed but push failed"
        ((success_count++))  # Commit succeeded, count as partial success
    fi
done

echo ""
echo -e "Summary: ${GREEN}$success_count succeeded${NC}, ${YELLOW}$skipped_count skipped${NC}, ${RED}$failed_count failed${NC}"

if [[ $failed_count -gt 0 ]]; then
    exit 1
else
    exit 0
fi
