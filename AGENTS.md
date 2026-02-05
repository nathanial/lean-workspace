# Repository Guidelines

Lean 4 monorepo workspace.

## Layout

Projects remain grouped by category folders:

- `graphics/`
- `web/`
- `network/`
- `data/`
- `apps/`
- `util/`
- `math/`
- `audio/`
- `testing/`

Each project still keeps its Lean sources in-place (for example `graphics/terminus/Terminus/...`).

## Lake Configuration

- Single root Lake configuration: `/Users/Shared/Projects/lean-workspace/lakefile.lean`
- Single root toolchain file: `/Users/Shared/Projects/lean-workspace/lean-toolchain`
- Nested `lakefile.lean` files were removed as part of monorepo consolidation.

## Build & Test

Primary workflow is now from repository root:

- `lake build`
- `lake build workspace_smoke`
- `lake exe workspace_smoke`

Custom project scripts (`build.sh`, `test.sh`) still exist in some project folders, but they are now legacy wrappers and may need updates during migration cleanup.

## Coding Style

- PascalCase modules matching namespace (`Legate/Stream.lean`, `Terminus/Widgets/Button.lean`)
- 2-space indentation
- Keep FFI wrappers minimal in `ffi/` or `native/`

## Commits

Short, lowercase, imperative style:

- `fix tile rendering`
- `add streaming support`

## Issue Tracking (tracker)

Use `tracker` CLI to manage issues. Outputs text by default (use `-j` for JSON).

- `tracker list`
- `tracker show <id>`
- `tracker add "Title" --priority=high`
- `tracker progress <id> "Found root cause"`
- `tracker close <id> "Fixed in commit X"`

Issues are stored in `.issues/` at workspace root.
Do not commit `.issues/` changes.

## Important

This repository is now a single monorepo. Commit and push from the workspace root.
