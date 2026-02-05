#!/bin/bash
# Build Raster library

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Build the specified target
TARGET="${1:-Raster}"

echo "Building $TARGET..."
lake build "$TARGET"

if [ "$TARGET" = "Raster" ]; then
    echo "Building raster_native..."
    lake build raster_native
fi

echo "Build complete!"
