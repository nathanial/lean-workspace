#!/bin/bash
# Run Afferent Chat tests with the correct compiler settings for macOS.

set -e

# Use system clang for proper macOS framework linking.
export LEAN_CC=/usr/bin/clang

# Add Homebrew lib path for gmp/curl (required by wisp's shared library build).
export LIBRARY_PATH=/opt/homebrew/lib:${LIBRARY_PATH:-}

cd "$(dirname "$0")"

echo "Building and running tests..."

lake build afferent-chat_tests && .lake/build/bin/afferent-chat_tests
