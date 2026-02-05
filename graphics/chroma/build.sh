#!/bin/bash
# Build script for Chroma
# Uses system clang for proper macOS framework linking

set -e

cd "$(dirname "$0")"

# Must use system clang for framework linking
export LEAN_CC=/usr/bin/clang

lake build "$@"
