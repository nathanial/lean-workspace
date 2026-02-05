# Repository Guidelines

Lean 4 monorepo workspace.

## Monorepo Status

- Former project submodules were removed.
- All projects are normal directories tracked by this root repo.
- Do not use `git submodule` commands.

## Layout

Projects are grouped by category folders:

- `graphics/`
- `web/`
- `network/`
- `data/`
- `apps/`
- `util/`
- `math/`
- `audio/`
- `testing/`

Each project keeps its Lean sources in-place (for example `graphics/terminus/Terminus/...`).

## Lake Configuration

- Single root Lake file: `/Users/Shared/Projects/lean-workspace/lakefile.lean`
- Single root toolchain file: `/Users/Shared/Projects/lean-workspace/lean-toolchain`
- Nested `lakefile.lean` files were removed.

## Build & Test

Run from repository root unless noted:

- `lake build`
- `lake build workspace_smoke`
- `lake exe workspace_smoke`

Project-specific note:

- `graphics/afferent-demos`: run `graphics/afferent-demos/build.sh afferent_demos`
  - This rebuilds required native static libs in `.native-libs/` and then builds `afferent_demos`.

## Coding Style

- PascalCase modules matching namespace (`Legate/Stream.lean`, `Terminus/Widgets/Button.lean`)
- 2-space indentation
- Keep FFI wrappers minimal in `ffi/` or `native/`

## Commits

Short, lowercase, imperative style:

- `fix tile rendering`
- `add streaming support`

## Issue Tracking (tracker)

Use `tracker` CLI at workspace root. Outputs text by default (use `-j` for JSON).

- `tracker list`
- `tracker show <id>`
- `tracker add "Title" --priority=high`
- `tracker progress <id> "Found root cause"`
- `tracker close <id> "Fixed in commit X"`

Issues are stored in `.issues/`. Do not commit `.issues/` changes.

## Important

Commit and push from workspace root.
