# lean-workspace justfile
# Run `just` to see available recipes

# List available recipes
default:
    @just --list

# ─────────────────────────────────────────────────────────────────────────────
# Git / Submodule Operations
# ─────────────────────────────────────────────────────────────────────────────

# Show status of all submodules
status:
    @git submodule foreach --quiet 'echo "=== $name ===" && git status -s || true'

# Show detailed status (using existing script)
status-verbose:
    @./scripts/git-status.sh -v

# Fetch latest from all submodule remotes
fetch:
    git submodule foreach 'git fetch'

# Update all submodules to latest remote commits
update-submodules:
    git submodule update --remote --merge

# Pull latest in all submodules (stays on current branch)
pull:
    git submodule foreach 'git pull'

# Push all submodules that have unpushed commits
push:
    @./scripts/git-push-all.sh

# Show which submodules have unpushed commits
unpushed:
    @git submodule foreach --quiet 'ahead=$(git rev-list @{u}..HEAD 2>/dev/null | wc -l | tr -d " "); if [ "$ahead" -gt 0 ]; then echo "$name: $ahead commit(s) ahead"; fi'

# Show the latest tag for each project
tags:
    #!/usr/bin/env bash
    for category in graphics math web network audio data apps util testing; do
        for dir in "$category"/*; do
            if [[ -d "$dir" && -f "$dir/lakefile.lean" ]]; then
                cd "$dir"
                latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "(none)")
                printf "%-30s %s\n" "$dir:" "$latest_tag"
                cd ../..
            fi
        done
    done

# Show which projects have commits ahead of their latest tag
release-status:
    #!/usr/bin/env bash
    for category in graphics math web network audio data apps util testing; do
        for dir in "$category"/*; do
            if [[ -d "$dir" && -f "$dir/lakefile.lean" ]]; then
                cd "$dir"
                latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
                if [[ -n "$latest_tag" ]]; then
                    ahead=$(git rev-list "$latest_tag"..HEAD 2>/dev/null | wc -l | tr -d " ")
                    if [[ "$ahead" -gt 0 ]]; then
                        printf "%-30s %s → master (%d commits ahead)\n" "$dir:" "$latest_tag" "$ahead"
                    fi
                else
                    # No tags yet
                    commit_count=$(git rev-list HEAD 2>/dev/null | wc -l | tr -d " ")
                    if [[ "$commit_count" -gt 0 ]]; then
                        printf "%-30s no tags (has %d commits)\n" "$dir:" "$commit_count"
                    fi
                fi
                cd ../..
            fi
        done
    done

# Release all projects with unreleased commits (tag and push)
release-all *args:
    @./scripts/release-all.sh {{args}}

# Show projects with outdated dependencies in their lakefile
outdated-deps:
    #!/usr/bin/env bash
    # Create temp file to store project -> latest tag mappings
    tags_file=$(mktemp)
    trap "rm -f $tags_file" EXIT

    # Build mapping of project name -> latest tag
    for category in graphics math web network audio data apps util testing; do
        for dir in "$category"/*; do
            if [[ -d "$dir" && -f "$dir/lakefile.lean" ]]; then
                name=$(basename "$dir")
                cd "$dir"
                tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
                if [[ -n "$tag" ]]; then
                    echo "$name=$tag" >> "$tags_file"
                fi
                cd ../..
            fi
        done
    done

    # Function to look up latest tag for a dep
    get_latest_tag() {
        grep "^$1=" "$tags_file" 2>/dev/null | cut -d= -f2
    }

    # Check each project's dependencies
    found_outdated=false
    for category in graphics math web network audio data apps util testing; do
        for dir in "$category"/*; do
            if [[ -d "$dir" && -f "$dir/lakefile.lean" ]]; then
                outdated_lines=""
                # Parse require lines: require foo from git "..." @ "v0.0.1"
                while IFS= read -r line; do
                    # Extract dep name and version (use -E for extended regex on macOS)
                    dep_name=$(echo "$line" | sed -E 's/.*require[[:space:]]+([a-zA-Z0-9_-]+)[[:space:]]+from.*/\1/')
                    declared_ver=$(echo "$line" | sed -E 's/.*@[[:space:]]*"([^"]*)".*/\1/')
                    if [[ -n "$dep_name" && -n "$declared_ver" ]]; then
                        latest_ver=$(get_latest_tag "$dep_name")
                        # Only check our own deps (those with latest_tags entry)
                        if [[ -n "$latest_ver" && "$declared_ver" != "$latest_ver" ]]; then
                            outdated_lines="$outdated_lines  $dep_name: $declared_ver → $latest_ver\n"
                        fi
                    fi
                done < <(grep "require.*from git.*nathanial" "$dir/lakefile.lean" 2>/dev/null || true)

                if [[ -n "$outdated_lines" ]]; then
                    found_outdated=true
                    echo "$dir:"
                    printf "$outdated_lines"
                fi
            fi
        done
    done

    if [[ "$found_outdated" == false ]]; then
        echo "All dependencies are up to date."
    fi

# Add and commit all changes in subprojects, then commit workspace
commit-all msg:
    #!/usr/bin/env bash
    set -e
    committed=()

    # Commit changes in each submodule that has modifications
    for category in graphics math web network audio data apps util testing; do
        for dir in "$category"/*; do
            if [[ -d "$dir" ]]; then
                cd "$dir"
                if [[ -n $(git status --porcelain) ]]; then
                    echo "=== Committing $dir ==="
                    git add -A
                    git commit -m "{{msg}}"
                    committed+=("$dir")
                fi
                cd ../..
            fi
        done
    done

    # Report what was committed
    if [[ ${#committed[@]} -eq 0 ]]; then
        echo "No changes in subprojects to commit"
    else
        echo ""
        echo "Committed in: ${committed[*]}"
    fi

    # Update workspace with new submodule refs
    git add -A
    if [[ -n $(git status --porcelain) ]]; then
        echo ""
        echo "=== Committing workspace ==="
        git commit -m "{{msg}}"
    else
        echo "No workspace changes to commit"
    fi

# ─────────────────────────────────────────────────────────────────────────────
# Building
# ─────────────────────────────────────────────────────────────────────────────

# Build a specific project
build project:
    #!/usr/bin/env bash
    cd {{project}}
    if [[ -f build.sh ]]; then
        ./build.sh
    else
        lake build
    fi

# Build all projects
build-all:
    #!/usr/bin/env bash
    set -e
    for category in graphics math web network audio data apps util testing; do
        for dir in "$category"/*; do
            if [[ -d "$dir" && -f "$dir/lakefile.lean" ]]; then
                echo "=== Building $dir ==="
                cd "$dir"
                if [[ -f build.sh ]]; then
                    ./build.sh
                else
                    lake build
                fi
                cd ../..
            fi
        done
    done

# Clean build artifacts in a specific project
clean project:
    cd {{project}} && lake clean

# Clean all build artifacts
clean-all:
    @git submodule foreach 'lake clean 2>/dev/null || true'

# ─────────────────────────────────────────────────────────────────────────────
# Testing
# ─────────────────────────────────────────────────────────────────────────────

# Test a specific project
test project:
    #!/usr/bin/env bash
    cd {{project}}
    if [[ -f test.sh ]]; then
        ./test.sh
    elif [[ -f lakefile.lean ]] && grep -q "test" lakefile.lean; then
        lake test
    else
        echo "No test target found for {{project}}"
    fi

# Test all projects that have tests
test-all:
    #!/usr/bin/env bash
    set -e
    # Projects with lake test
    for dir in graphics/terminus network/protolean network/legate network/wisp apps/enchiridion data/ledger graphics/arbor graphics/trellis graphics/tincture testing/crucible; do
        echo "=== Testing $dir ==="
        cd "$dir"
        lake test
        cd ../..
    done
    # Projects with custom test scripts
    echo "=== Testing graphics/afferent ==="
    cd graphics/afferent && ./test.sh && cd ../..
    echo "=== Testing graphics/chroma ==="
    cd graphics/chroma && ./build.sh chroma_tests && .lake/build/bin/chroma_tests && cd ../..
    echo "=== Testing data/collimator ==="
    cd data/collimator && lake build collimator_tests && .lake/build/bin/collimator_tests && cd ../..

# ─────────────────────────────────────────────────────────────────────────────
# Development Mode (Local vs Git Dependencies)
# ─────────────────────────────────────────────────────────────────────────────

# Switch to production mode (use git URLs for deps)
prod-mode:
    @./scripts/remove-local-overrides.sh

# Show current dependency mode for each project
dep-mode:
    #!/usr/bin/env bash
    for project in graphics/afferent graphics/canopy graphics/chroma apps/enchiridion; do
        if [ -f "$project/.lake/package-overrides.json" ]; then
            printf "%-25s local (dev mode)\n" "$project:"
        else
            printf "%-25s git (prod mode)\n" "$project:"
        fi
    done

# ─────────────────────────────────────────────────────────────────────────────
# Lake Operations
# ─────────────────────────────────────────────────────────────────────────────

# Run lake update in a specific project
lake-update project:
    cd {{project}} && lake update

# Run lake update in all projects
lake-update-all:
    @./scripts/lake-update.sh

# ─────────────────────────────────────────────────────────────────────────────
# Utilities
# ─────────────────────────────────────────────────────────────────────────────

# Show the dependency graph
deps:
    @echo "afferent ───► collimator, wisp, cellar, trellis, arbor, tincture"
    @echo "arbor ──────► trellis, tincture"
    @echo "canopy ─────► arbor"
    @echo "chroma ─────► afferent, arbor, trellis, tincture"
    @echo "legate ─────► protolean"
    @echo "enchiridion ► terminus, wisp"
    @echo "collimator, trellis, tincture, wisp ► crucible"

# Show Lean versions across all projects
versions:
    @git submodule foreach --quiet 'printf "%-15s %s\n" "$name:" "$(cat lean-toolchain 2>/dev/null || echo "no toolchain")"'

# Count lines of Lean code across all projects
lines:
    @./scripts/count-lean-lines.sh

# Run a command in all submodules
foreach cmd:
    git submodule foreach '{{cmd}}'

# Open a project in the current shell
cd project:
    @echo "Run: cd {{project}}"

# ─────────────────────────────────────────────────────────────────────────────
# Documentation
# ─────────────────────────────────────────────────────────────────────────────

# Generate PDF documentation from ROADMAP.md files
generate-docs:
    #!/usr/bin/env bash
    set -e
    for category in graphics math web network audio data apps util testing; do
        for dir in "$category"/*; do
            if [[ -d "$dir" && -f "$dir/ROADMAP.md" ]]; then
                mkdir -p "docs/$dir"
                echo "Converting $dir/ROADMAP.md → docs/$dir/ROADMAP.pdf"
                pandoc "$dir/ROADMAP.md" -o "docs/$dir/ROADMAP.pdf" \
                    --pdf-engine=xelatex \
                    -V geometry:margin=1in \
                    -V colorlinks=true
            fi
        done
    done
    echo "Done. PDFs generated in docs/"
