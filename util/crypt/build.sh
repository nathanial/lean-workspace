#!/bin/bash
# Build crypt with libsodium
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check libsodium is installed
if ! pkg-config --exists libsodium 2>/dev/null; then
    if [ ! -f "/opt/homebrew/lib/libsodium.a" ] && [ ! -f "/opt/homebrew/lib/libsodium.dylib" ]; then
        echo "Error: libsodium not found. Install with: brew install libsodium"
        exit 1
    fi
fi

TARGET="${1:-Crypt}"
echo "Building $TARGET..."
lake build "$TARGET"
echo "Build complete!"
