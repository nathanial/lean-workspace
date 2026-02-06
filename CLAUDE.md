# CLAUDE.md

Lean 4 monorepo workspace.

## Current Build Model

- Single root Lake file: `/Users/Shared/Projects/lean-workspace/lakefile.lean`
- Single root toolchain: `/Users/Shared/Projects/lean-workspace/lean-toolchain`
- Projects are category folders in this repo (no submodules)

## Core Commands

Run from repository root:

- `lake build`
- `lake build workspace_smoke`
- `lake exe workspace_smoke`
- `just --list`
- `just build`
- `just test-all`

Targeted tests:

- `just test-project <match>`
- `just test-project-integration <match>`

Integration toggle:

- `just test-all-integration`

## Test Harness Notes

`scripts/test-all.sh`:

- stops on first failure
- supports filtering via `MATCH`
- includes integration suites only when `INCLUDE_INTEGRATION=1`
- falls back from `lake env lean --run` to `lake exe` for FFI-heavy suites
- builds native fallback archives via `scripts/build-native-libs.sh`

## Native/Project Notes

- `graphics/afferent-demos`: `graphics/afferent-demos/build.sh afferent_demos`
- Run app executables from root (example: `lake exe eschaton`)

## Categories

- Graphics
- Web
- Network
- Data
- Apps
- Util
- Math
- Audio
- Testing

## Issue Tracking

Use `tracker` at workspace root. Do not commit `.issues/` changes.
