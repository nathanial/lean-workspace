#!/bin/bash
# release-all.sh - Tag and push new versions for projects ahead of their latest tag
#
# Usage: ./release-all.sh [--dry-run]
#
# Projects are processed in tier order (0 → 4) to respect dependencies.
# Only projects with unreleased commits are tagged.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse arguments
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${CYAN}DRY RUN MODE - no changes will be made${NC}"
    echo ""
fi

# Tier ordering (must release in order due to dependencies)
TIER_0="testing/crucible util/staple data/cellar graphics/assimptor graphics/raster"
TIER_1="web/herald web/markup graphics/trellis data/collimator network/protolean web/scribe web/chronicle graphics/terminus audio/fugue math/linalg util/chronos math/measures util/rune graphics/tincture network/wisp data/chisel data/ledger data/quarry data/convergent data/reactive data/tabular data/entity data/totem util/conduit util/tracer"
TIER_2="web/citadel network/legate network/oracle util/parlance graphics/arbor apps/blockfall apps/twenty48 apps/minefield"
TIER_3="web/loom graphics/afferent graphics/canopy apps/ask apps/lighthouse apps/enchiridion util/docgen"
TIER_4="apps/todo-app apps/homebase-app graphics/chroma graphics/vane graphics/worldmap graphics/grove apps/cairn"

ALL_TIERS="$TIER_0 $TIER_1 $TIER_2 $TIER_3 $TIER_4"

# Increment patch version: v0.0.1 -> v0.0.2
increment_version() {
    local version="$1"
    # Remove 'v' prefix
    local nums="${version#v}"
    # Split by dots
    local major=$(echo "$nums" | cut -d. -f1)
    local minor=$(echo "$nums" | cut -d. -f2)
    local patch=$(echo "$nums" | cut -d. -f3)
    # Increment patch
    patch=$((patch + 1))
    echo "v${major}.${minor}.${patch}"
}

released_count=0
skipped_count=0
failed_count=0
new_count=0

echo -e "${BLUE}Releasing projects with unreleased commits...${NC}"
echo ""

current_tier=-1
for project in $ALL_TIERS; do
    # Determine tier for display
    if [[ " $TIER_0 " == *" $project "* ]]; then
        tier=0
    elif [[ " $TIER_1 " == *" $project "* ]]; then
        tier=1
    elif [[ " $TIER_2 " == *" $project "* ]]; then
        tier=2
    elif [[ " $TIER_3 " == *" $project "* ]]; then
        tier=3
    else
        tier=4
    fi

    # Print tier header when tier changes
    if [[ $tier -ne $current_tier ]]; then
        echo -e "${CYAN}=== Tier $tier ===${NC}"
        current_tier=$tier
    fi

    project_dir="$WORKSPACE_DIR/$project"

    # Skip if directory doesn't exist
    if [[ ! -d "$project_dir" ]]; then
        continue
    fi

    cd "$project_dir"

    # Get latest tag
    latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

    if [[ -n "$latest_tag" ]]; then
        # Check if ahead of tag
        ahead=$(git rev-list "$latest_tag"..HEAD 2>/dev/null | wc -l | tr -d " ")

        if [[ "$ahead" -gt 0 ]]; then
            new_tag=$(increment_version "$latest_tag")
            if [[ "$DRY_RUN" == true ]]; then
                echo -e "${GREEN}$project${NC}: would release $latest_tag → $new_tag ($ahead commits)"
            else
                # Create and push tag
                if git tag "$new_tag" && git push origin "$new_tag" 2>/dev/null; then
                    echo -e "${GREEN}$project${NC}: released $latest_tag → $new_tag ($ahead commits)"
                    ((released_count++))
                else
                    echo -e "${RED}$project${NC}: failed to tag/push $new_tag"
                    ((failed_count++))
                fi
            fi
        else
            ((skipped_count++))
        fi
    else
        # No tags yet - create v0.0.1
        commit_count=$(git rev-list HEAD 2>/dev/null | wc -l | tr -d " ")
        if [[ "$commit_count" -gt 0 ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                echo -e "${GREEN}$project${NC}: would create first release v0.0.1 ($commit_count commits)"
            else
                if git tag "v0.0.1" && git push origin "v0.0.1" 2>/dev/null; then
                    echo -e "${GREEN}$project${NC}: created first release v0.0.1 ($commit_count commits)"
                    ((new_count++))
                else
                    echo -e "${RED}$project${NC}: failed to create v0.0.1"
                    ((failed_count++))
                fi
            fi
        fi
    fi
done

echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${CYAN}Dry run complete. Run without --dry-run to execute.${NC}"
else
    echo -e "Summary: ${GREEN}$released_count released${NC}, ${GREEN}$new_count new${NC}, ${YELLOW}$skipped_count up-to-date${NC}, ${RED}$failed_count failed${NC}"
fi

if [[ $failed_count -gt 0 ]]; then
    exit 1
else
    exit 0
fi
