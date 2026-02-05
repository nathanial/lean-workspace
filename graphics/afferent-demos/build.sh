#!/bin/bash
# Build script for Afferent Demos
# Uses system clang for proper macOS framework linking

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$PROJECT_DIR/../.." && pwd)"

# Build native FFI static libraries required by the monorepo lakefile.
"$ROOT_DIR/scripts/build-native-libs.sh"

# Must use system clang for framework linking
export LEAN_CC=/usr/bin/clang

# Ensure Homebrew libraries are found (needed for shared libs)
export LIBRARY_PATH=/opt/homebrew/lib:${LIBRARY_PATH:-}

TARGET="${1:-afferent_demos}"

cd "$ROOT_DIR"
lake build "$TARGET"
