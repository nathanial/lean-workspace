#!/bin/bash
# Integration test runner for docgen
#
# This script sets up LEAN_PATH to include external projects (Chronos)
# before running the test suite.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Building docgen..."
lake build

echo ""
echo "Building Staple (test target)..."
(cd "$WORKSPACE/util/staple" && lake build) || {
  echo "Warning: Could not build Staple. Staple tests will be skipped."
}

echo ""
echo "Building Chronos (test target)..."
(cd "$WORKSPACE/util/chronos" && lake build) || {
  echo "Warning: Could not build Chronos. Chronos tests will be skipped."
}

echo ""
echo "Building test executable..."
lake build docgen_tests

echo ""
echo "Running tests..."
# Set LEAN_PATH to include dependency build outputs
# Note: The "lean" subdirectory contains the .olean files
export LEAN_PATH="$WORKSPACE/util/chronos/.lake/build/lib/lean:$WORKSPACE/util/staple/.lake/build/lib/lean:${LEAN_PATH:-}"

.lake/build/bin/docgen_tests
