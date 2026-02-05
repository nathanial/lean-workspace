#!/bin/bash
#
# Install the timeout command to /usr/local/bin
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/timeout"
DEST="/usr/local/bin/timeout"

if [[ ! -f "$SOURCE" ]]; then
    echo "Error: timeout script not found at $SOURCE" >&2
    exit 1
fi

echo "Installing timeout to $DEST..."

# Check if we need sudo
if [[ -w /usr/local/bin ]]; then
    cp "$SOURCE" "$DEST"
    chmod +x "$DEST"
else
    echo "Requires sudo to install to /usr/local/bin"
    sudo cp "$SOURCE" "$DEST"
    sudo chmod +x "$DEST"
fi

# Verify installation
if [[ -x "$DEST" ]]; then
    echo "Successfully installed timeout to $DEST"
    echo "Run 'timeout --help' or 'timeout' for usage information."
else
    echo "Error: Installation failed" >&2
    exit 1
fi
