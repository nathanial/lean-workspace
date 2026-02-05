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

# Run all available tests from root package definition
# (currently minimal during migration)
test:
    @echo "No unified test target is wired yet; run project-specific tests as needed."

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
