#!/bin/bash
# Build script for Afferent Math

set -e

cd "$(dirname "$0")"

lake build
