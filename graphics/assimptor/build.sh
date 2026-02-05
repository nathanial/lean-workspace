#!/bin/bash
# Build Assimptor with the correct compiler settings for macOS
# Requires: brew install assimp

set -e

export LEAN_CC=/usr/bin/clang
export LIBRARY_PATH=/opt/homebrew/lib:${LIBRARY_PATH:-}

lake build "$@"
