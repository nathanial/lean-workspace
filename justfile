# lean-workspace monorepo justfile

set shell := ["/bin/bash", "-cu"]

# List recipes
default:
    @just --list

# Git status (single repo)
status:
    git status -s

# Build root package (may include many targets)
build:
    lake build

# Minimal smoke build target
smoke:
    lake build workspace_smoke

# Run smoke executable
run-smoke:
    lake exe workspace_smoke

# Run package test driver (currently linalg suite)
test:
    lake test

# Run linalg test suite from monorepo root
test-linalg:
    lake exe linalg_tests

# Run all configured project test suites (non-integration by default)
test-all:
    ./scripts/test-all.sh

# Include integration suites in the full run
test-all-integration:
    INCLUDE_INTEGRATION=1 ./scripts/test-all.sh

# Run tests for a specific project path or substring (e.g. math/linalg, agent-mail, network/wisp)
test-project project:
    MATCH="{{project}}" ./scripts/test-all.sh

# Run tests for a specific project and include integration suites
test-project-integration project:
    INCLUDE_INTEGRATION=1 MATCH="{{project}}" ./scripts/test-all.sh

# Clean root lake artifacts
clean:
    lake clean

# Show project directories present in the monorepo
projects:
    @for category in apps audio data graphics math network testing util web; do \
      for dir in $$category/*; do \
        if [[ -d "$$dir" ]]; then echo "$$dir"; fi; \
      done; \
    done
