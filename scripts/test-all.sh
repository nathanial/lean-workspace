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

# Use system clang for native fallback executables (Metal/ObjC frameworks).
export LEAN_CC="${LEAN_CC:-/usr/bin/clang}"
if [ -d "/opt/homebrew/lib" ]; then
  export LIBRARY_PATH="/opt/homebrew/lib:${LIBRARY_PATH:-}"
fi

ran=0
native_libs_built=0

run_suite() {
  local lib_target="$1"
  local main_file="$2"

  echo ""
  echo "==> lake build $lib_target"
  if ! lake build "$lib_target"; then
    return 1
  fi

  echo "==> lake env lean --run $main_file"
  local lean_output
  lean_output="$(lake env lean --run "$main_file" 2>&1)"
  local lean_status=$?
  echo "$lean_output"

  if [ "$lean_status" -eq 0 ]; then
    return 0
  fi

  if [[ "$lean_output" != *"Could not find native implementation of external declaration"* ]]; then
    return "$lean_status"
  fi

  local exe_target
  if [[ "$lib_target" == *_lib ]]; then
    exe_target="${lib_target%_lib}_exe"
  else
    exe_target="${lib_target}_exe"
  fi
  if [[ "$main_file" == */integration/* ]]; then
    exe_target="${exe_target%_exe}_integration_exe"
  fi

  if [ "$native_libs_built" -eq 0 ] && [ -x "./scripts/build-native-libs.sh" ]; then
    echo "==> ./scripts/build-native-libs.sh"
    if ! ./scripts/build-native-libs.sh; then
      return 1
    fi
    native_libs_built=1
  fi

  echo "==> fallback: lake exe $exe_target"
  if ! lake exe "$exe_target"; then
    return 1
  fi

  return 0
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

  if ! run_suite "$lib_target" "$main_file"; then
    echo ""
    echo "Stopped on first failure at: $main_file"
    exit 1
  fi
  ran=$((ran + 1))

  if [ "$MAX_SUITES" -gt 0 ] && [ "$ran" -ge "$MAX_SUITES" ]; then
    echo ""
    echo "Reached MAX_SUITES=$MAX_SUITES; stopping early."
    break
  fi
done < "$ENTRYPOINTS_FILE"

echo ""
echo "All configured test suites passed."
