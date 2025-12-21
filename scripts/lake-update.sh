#!/bin/bash
# lake-update.sh - Run lake update across all Lean projects in the workspace
#
# Usage: ./lake-update.sh [project...]
#   With no arguments, updates all projects
#   With arguments, updates only the specified projects
#
# Projects are auto-discovered: any subdirectory with a lakefile.lean is included.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Auto-discover Lean projects: find all immediate subdirectories with lakefile.lean
discover_projects() {
    for dir in "$WORKSPACE_DIR"/*/; do
        if [[ -f "${dir}lakefile.lean" ]]; then
            basename "$dir"
        fi
    done | sort
}

# Get list of projects to update
if [[ $# -gt 0 ]]; then
    PROJECTS="$@"
else
    PROJECTS=$(discover_projects)
fi

echo -e "${BLUE}Running lake update for Lean projects...${NC}"
echo ""

success_count=0
fail_count=0

for project in $PROJECTS; do
    project_dir="$WORKSPACE_DIR/$project"

    if [[ ! -d "$project_dir" ]]; then
        echo -e "${RED}$project${NC}: directory not found"
        ((fail_count++))
        continue
    fi

    if [[ ! -f "$project_dir/lakefile.lean" ]]; then
        echo -e "${YELLOW}$project${NC}: no lakefile.lean, skipping"
        continue
    fi

    echo -e "${BLUE}$project${NC}: updating..."

    cd "$project_dir"

    if lake update 2>&1 | grep -v "^info: "; then
        echo -e "${GREEN}$project${NC}: updated"
        ((success_count++))
    else
        # lake update succeeded but had no output
        echo -e "${GREEN}$project${NC}: updated"
        ((success_count++))
    fi
    echo ""
done

echo -e "Summary: ${GREEN}$success_count updated${NC}, ${RED}$fail_count failed${NC}"

if [[ $fail_count -gt 0 ]]; then
    exit 1
else
    exit 0
fi
