#!/bin/bash
# Run Chroma

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

./build.sh chroma

# Afferent needs to find its Metal shaders (absolute path)
export AFFERENT_SHADER_DIR="$SCRIPT_DIR/../afferent/native/src/metal/shaders"

.lake/build/bin/chroma
