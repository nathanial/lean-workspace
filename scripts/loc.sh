#!/usr/bin/env bash
# Count lines of code in the workspace, excluding .lake, references/, and vendored code.
set -eo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Vendored third-party directories to exclude
VENDORED=(
  "$ROOT/data/quarry/native/sqlite"
  "$ROOT/graphics/raster/native/stb"
  "$ROOT/util/selene/native/lua"
)

count() {
  local label="$1"
  shift
  local find_args=()
  local first=true
  for pat in "$@"; do
    if $first; then
      find_args+=( -name "$pat" )
      first=false
    else
      find_args+=( -o -name "$pat" )
    fi
  done

  # Build prune clauses for excluded directories
  local prune_args=(
    -path "$ROOT/.lake" -prune
    -o -path "$ROOT/references" -prune
    -o -path "$ROOT/.issues" -prune
  )
  for vdir in "${VENDORED[@]}"; do
    prune_args+=( -o -path "$vdir" -prune )
  done

  local files
  files=$(find "$ROOT" \
    "${prune_args[@]}" \
    -o \( "${find_args[@]}" \) -print 2>/dev/null) || true

  if [[ -z "$files" ]]; then
    return
  fi

  local nfiles nlines
  nfiles=$(printf '%s\n' "$files" | wc -l | tr -d ' ')
  if [[ "$nfiles" -eq 1 ]]; then
    nlines=$(wc -l < <(cat "$files") | tr -d ' ')
  else
    nlines=$(printf '%s\n' "$files" | xargs wc -l | tail -1 | awk '{print $1}')
  fi

  printf "%-14s %8d %8d\n" "$label" "$nfiles" "$nlines"
  TOTAL=$((TOTAL + nlines))
}

TOTAL=0

printf "%-14s %8s %8s\n" "Language" "Files" "Lines"
printf "%-14s %8s %8s\n" "----------" "------" "------"

count "Lean"       "*.lean"
count "C"          "*.c" "*.h"
count "Shell"      "*.sh"
count "Python"     "*.py"
count "JavaScript" "*.js"
count "TypeScript" "*.ts"
count "HTML"       "*.html"
count "CSS"        "*.css"
count "JSON"       "*.json"
count "TOML"       "*.toml"
count "Markdown"   "*.md"

printf "%-14s %8s %8s\n" "----------" "------" "------"
printf "%-14s %8s %8d\n" "Total" "" "$TOTAL"
echo ""
echo "Excluded: .lake/, references/, .issues/, and vendored third-party code"
echo "  (sqlite, stb, lua)"
