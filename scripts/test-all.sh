#!/bin/bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENTRYPOINTS_FILE="$SCRIPT_DIR/test-entrypoints.txt"
INCLUDE_INTEGRATION="${INCLUDE_INTEGRATION:-0}"
MAX_SUITES="${MAX_SUITES:-0}"
MATCH="${MATCH:-}"

if [ ! -f "$ENTRYPOINTS_FILE" ]; then
  echo "Missing entrypoints file: $ENTRYPOINTS_FILE" >&2
  exit 1
fi

cd "$WORKSPACE_ROOT"

failures=()
ran=0

run_suite() {
  local lib_target="$1"
  local main_file="$2"

  echo ""
  echo "==> lake build $lib_target"
  if ! lake build "$lib_target"; then
    failures+=("lake build $lib_target")
    return
  fi

  echo "==> lake env lean --run $main_file"
  if ! lake env lean --run "$main_file"; then
    failures+=("lean --run $main_file")
  fi
}

while IFS= read -r line; do
  [ -z "$line" ] && continue
  case "$line" in
    \#*) continue ;;
  esac

  IFS='|' read -r lib_target main_file kind <<< "$line"

  if [ -n "$MATCH" ]; then
    case "$main_file" in
      *"$MATCH"*) ;;
      *) continue ;;
    esac
  fi

  if [ "$kind" = "integration" ] && [ "$INCLUDE_INTEGRATION" != "1" ]; then
    echo ""
    echo "==> skipping integration suite $main_file (set INCLUDE_INTEGRATION=1 to run)"
    continue
  fi

  run_suite "$lib_target" "$main_file"
  ran=$((ran + 1))

  if [ "$MAX_SUITES" -gt 0 ] && [ "$ran" -ge "$MAX_SUITES" ]; then
    echo ""
    echo "Reached MAX_SUITES=$MAX_SUITES; stopping early."
    break
  fi
done < "$ENTRYPOINTS_FILE"

if [ ${#failures[@]} -gt 0 ]; then
  echo ""
  echo "Test failures (${#failures[@]}):"
  for item in "${failures[@]}"; do
    echo "- $item"
  done
  exit 1
fi

echo ""
echo "All configured test suites passed."
