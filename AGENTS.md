# Repository Guidelines

Lean 4 monorepo workspace.

## Monorepo Status

- Former per-project submodules were removed.
- All projects are regular directories tracked by this root repo.
- Do not use `git submodule` commands.

## Layout

Projects live under category folders:

- `apps/`
- `audio/`
- `data/`
- `graphics/`
- `math/`
- `network/`
- `testing/`
- `util/`
- `web/`

## Lake Configuration

- Single root Lake file: `/Users/Shared/Projects/lean-workspace/lakefile.lean`
- Single root toolchain file: `/Users/Shared/Projects/lean-workspace/lean-toolchain`

## Build & Test

Run from repository root unless noted.

Build:

- `lake build`
- `lake build workspace_smoke`
- `lake exe workspace_smoke`

Testing:

- `just test-all` (recommended)
- `just test-project <match>` for targeted runs
- `just test-all-integration` to include integration suites
- `just test-project-integration <match>` for targeted integration runs

`scripts/test-all.sh` behavior:

- stops on first failure
- uses `MATCH` substring filtering for project selection
- falls back to `lake exe` when interpreter-mode `lean --run` cannot load native FFI
- builds fallback native archives via `scripts/build-native-libs.sh` as needed

Project-specific note:

- `graphics/afferent-demos`: run `graphics/afferent-demos/build.sh afferent_demos`

## Coding Style

- PascalCase modules matching namespace
- 2-space indentation
- Keep FFI wrappers minimal in `ffi/` or `native/`

## Commits

Short, lowercase, imperative style:

- `fix tile rendering`
- `add streaming support`

## Issue Tracking (tracker)

Use `tracker` at workspace root:

- `tracker list`
- `tracker show <id>`
- `tracker add "Title" --priority=high`
- `tracker progress <id> "Found root cause"`
- `tracker close <id> "Fixed in commit X"`

Do not commit `.issues/` changes.

## Important

- Commit and push from workspace root.
- Keep documentation and root scripts in sync with monorepo behavior.
