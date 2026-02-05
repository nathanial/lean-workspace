# CLAUDE.md

Lean 4 monorepo workspace (consolidated from many former project submodules).

## Current Build Model

- Single root Lake file: `/Users/Shared/Projects/lean-workspace/lakefile.lean`
- Single root toolchain: `/Users/Shared/Projects/lean-workspace/lean-toolchain`
- Projects remain in category folders (`apps/`, `data/`, `graphics/`, etc.) with their source trees intact.
- Former submodule repos are now plain directories in this repo. Do not use `git submodule` commands.

## Commands

Run from repository root:

- `lake build`
- `lake build workspace_smoke`
- `lake exe workspace_smoke`
- `just status`
- `just smoke`

Project-specific:

- `graphics/afferent-demos/build.sh afferent_demos`
  - Rebuilds native static libraries in `.native-libs/`
  - Runs `lake build afferent_demos` from workspace root

## Migration Notes

- Nested `lakefile.lean` files were removed.
- Submodules were flattened into normal directories tracked by this root repo.
- Some per-project `build.sh` / `test.sh` scripts still exist; prefer root-driven commands unless explicitly required.

## Project Categories

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
