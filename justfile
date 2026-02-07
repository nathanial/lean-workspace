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

# Run a specific Lake executable target from monorepo root
# On macOS, force system clang for framework linking used by graphics targets.
run-project project:
    @if [[ "$(uname -s)" == "Darwin" ]]; then \
      /bin/zsh -lc 'SDKROOT="$(xcrun --show-sdk-path)"; LEAN_CC=/usr/bin/clang LEAN_SYSROOT="$SDKROOT" LIBRARY_PATH=/opt/homebrew/lib:${LIBRARY_PATH:-} lake exe "{{project}}"'; \
    else \
      lake exe "{{project}}"; \
    fi

# Run tracker storage benchmarks (pass-through args, e.g. --issues=500 --iterations=30)
tracker-bench *args:
    lake exe tracker_bench -- {{args}}

# Build and install tracker using apps/tracker/install.sh
tracker-install:
    ./apps/tracker/install.sh

# Launch tracker GUI shell (`tracker -gui`) from monorepo root.
# On macOS, force system clang + SDK path for afferent framework linking.
tracker-gui:
    @if [[ "$(uname -s)" == "Darwin" ]]; then \
      /bin/zsh -lc 'SDKROOT="$(xcrun --show-sdk-path)"; LEAN_CC=/usr/bin/clang LEAN_SYSROOT="$SDKROOT" LIBRARY_PATH=/opt/homebrew/lib:${LIBRARY_PATH:-} lake exe tracker -- -gui'; \
    else \
      lake exe tracker -- -gui; \
    fi

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

# Count lines of code (excludes .lake and references/)
loc:
    ./scripts/loc.sh

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
