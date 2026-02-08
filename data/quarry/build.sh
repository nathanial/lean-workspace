#!/bin/bash
# Build Quarry with vendored SQLite amalgamation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SQLITE_VERSION="3470200"
SQLITE_YEAR="2024"
SQLITE_DIR="native/sqlite"

# Download SQLite amalgamation if not present
if [ ! -f "$SQLITE_DIR/sqlite3.c" ]; then
    echo "Downloading SQLite amalgamation..."
    mkdir -p "$SQLITE_DIR"
    SQLITE_URL="https://www.sqlite.org/${SQLITE_YEAR}/sqlite-amalgamation-${SQLITE_VERSION}.zip"

    curl -L -o /tmp/sqlite.zip "$SQLITE_URL"
    unzip -j /tmp/sqlite.zip -d "$SQLITE_DIR"
    rm /tmp/sqlite.zip

    echo "SQLite amalgamation downloaded!"
fi

# Build the specified target
TARGET="${1:-Quarry}"
NATIVE_TARGET="${2:-quarry-native}"

if [ -f "$WORKSPACE_ROOT/lakefile.lean" ]; then
    # Monorepo mode.
    cd "$WORKSPACE_ROOT"
    case "$TARGET" in
        Quarry) TARGET="data_quarry" ;;
        QuarryTests|QuarryTests.Main) TARGET="data_quarry_tests_lib" ;;
    esac
else
    # Standalone mode.
    cd "$SCRIPT_DIR"
fi

echo "Building $TARGET..."
lake build "$TARGET"

if [ -f "$WORKSPACE_ROOT/lakefile.lean" ]; then
    if [ "$NATIVE_TARGET" = "quarry-native" ]; then
        echo "Building quarry native archive via scripts/build-native-libs.sh..."
        ./scripts/build-native-libs.sh
    fi
else
    if [ "$TARGET" = "Quarry" ] && [ "$NATIVE_TARGET" = "quarry-native" ]; then
        echo "Building quarry_native..."
        lake build quarry_native
    fi
fi

echo "Build complete!"
