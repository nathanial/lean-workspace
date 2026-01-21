#!/usr/bin/env bash
# Find Lean files with more than 1000 lines (excludes .lake directories)

find . -name "*.lean" -not -path "*/.lake/*" -exec wc -l {} + 2>/dev/null \
    | awk '$1 > 1000 && $2 != "total" {printf "%6d  %s\n", $1, $2}' \
    | sort -rn
