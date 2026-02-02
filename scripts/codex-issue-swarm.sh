#!/bin/bash
# Spawn one Codex agent per tracker issue with isolated worktrees.

set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ISSUES_DIR="$WORKSPACE_DIR/.issues"
LOG_DIR="${CODEX_LOG_DIR:-$WORKSPACE_DIR/.codex-logs}"
CODEX_BIN="${CODEX_BIN:-codex}"
CODEX_FLAGS="${CODEX_FLAGS:---full-auto --sandbox workspace-write}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--wait] <issue-id> [issue-id...]

Environment:
  CODEX_BIN           Codex executable (default: codex)
  CODEX_FLAGS         Extra flags for "codex exec" (default: "--full-auto --sandbox workspace-write")
  CODEX_LOG_DIR       Log output dir (default: ./.codex-logs)
EOF
}

if [ ! -d "$ISSUES_DIR" ]; then
  echo "error: $ISSUES_DIR not found (run tracker init?)" >&2
  exit 1
fi

if ! command -v "$CODEX_BIN" >/dev/null 2>&1; then
  echo "error: codex executable not found (set CODEX_BIN?)" >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "error: rg (ripgrep) is required" >&2
  exit 1
fi

WAIT="false"
ISSUE_IDS=()
for arg in "$@"; do
  case "$arg" in
    --wait) WAIT="true" ;;
    -h|--help) usage; exit 0 ;;
    *)
      cleaned="${arg#\#}"
      if [[ "$cleaned" =~ ^[0-9]+-[0-9]+$ ]]; then
        start="${cleaned%-*}"
        end="${cleaned#*-}"
        if [ "$start" -le "$end" ]; then
          for ((i=start; i<=end; i++)); do
            ISSUE_IDS+=("$i")
          done
        else
          for ((i=start; i>=end; i--)); do
            ISSUE_IDS+=("$i")
          done
        fi
      elif [ -n "$cleaned" ]; then
        ISSUE_IDS+=("$cleaned")
      fi
      ;;
  esac
done

if [ "${#ISSUE_IDS[@]}" -eq 0 ]; then
  usage
  exit 1
fi

mkdir -p "$LOG_DIR"

find_issue_file() {
  local id="$1"
  rg -l "^id: $id$" "$ISSUES_DIR" | head -n 1
}

find_project_dir() {
  local project="$1"
  local categories=(graphics web network data apps util math audio testing)
  local candidate
  for category in "${categories[@]}"; do
    candidate="$WORKSPACE_DIR/$category/$project"
    if [ -f "$candidate/lakefile.lean" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

spawn_agent() {
  local id="$1"
  local issue_file
  local title
  local priority
  local project
  local project_dir
  local description
  local prompt_file
  local log_file

  issue_file="$(find_issue_file "$id")"
  if [ -z "$issue_file" ]; then
    echo "error: could not find issue file for id $id" >&2
    return 1
  fi

  title="$(rg -m1 "^title:" "$issue_file" | sed 's/^title:[[:space:]]*//')"
  priority="$(rg -m1 "^priority:" "$issue_file" | sed 's/^priority:[[:space:]]*//')"
  project="$(rg -m1 "^project:" "$issue_file" | sed 's/^project:[[:space:]]*//')"
  description="$(awk '
    /^## Description/ {desc=1; next}
    /^## / {if (desc) exit}
    {if (desc) print}
  ' "$issue_file" | sed 's/[[:space:]]*$//')"

  if [ -z "$project" ]; then
    echo "error: issue $id has no project field" >&2
    return 1
  fi

  project_dir="$(find_project_dir "$project" || true)"
  if [ -z "$project_dir" ]; then
    echo "error: project '$project' not found in workspace" >&2
    return 1
  fi

  prompt_file="$LOG_DIR/issue-$id.prompt.txt"
  log_file="$LOG_DIR/issue-$id.log"

  cat >"$prompt_file" <<EOF
You are assigned issue #$id: $title
Priority: $priority
Project: $project
Workdir: $project_dir

Constraints:
- Do NOT run build/test commands (e.g. lake build, lake test, ./build.sh, ./test.sh).
- Do NOT modify files outside $project_dir.
- Do NOT edit .issues files.
- Multiple agents may be working in this repo. Avoid overlapping changes: only touch files needed for this issue and do not edit files that another agent is likely to be working on.
- Do NOT commit or push changes.

Task:
$description

When done, summarize changes and list modified files.
EOF

  IFS=' ' read -r -a codex_flags_arr <<< "$CODEX_FLAGS"
  "$CODEX_BIN" exec "${codex_flags_arr[@]}" --cd "$project_dir" - <"$prompt_file" >"$log_file" 2>&1 &
  echo "issue $id -> pid $! (log: $log_file)"
}

PIDS=()
for id in "${ISSUE_IDS[@]}"; do
  spawn_agent "$id"
done

if [ "$WAIT" = "true" ]; then
  wait
fi
