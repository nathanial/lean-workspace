# Lean Workspace

Lean 4 monorepo for graphics, web, networking, data, apps, utilities, math, audio, and testing.

## Monorepo Model

- Single root Lake config: `lakefile.lean`
- Single root toolchain: `lean-toolchain`
- Projects are normal folders in this repo (no git submodules)

## Repository Layout

Projects are grouped by category:

- `apps/` (16)
- `audio/` (1)
- `data/` (11)
- `graphics/` (21)
- `math/` (2)
- `network/` (6)
- `testing/` (1)
- `util/` (12)
- `web/` (8)

Use `just projects` to list all current project directories.

## Build

From repo root:

```bash
lake build
lake build workspace_smoke
lake exe workspace_smoke
```

Or via `just`:

```bash
just build
just smoke
just run-smoke
```

## Test

Recommended from repo root:

```bash
just test-all
```

Run a specific project (path or substring match):

```bash
just test-project math/linalg
just test-project agent-mail
just test-project network/wisp
```

Include integration suites:

```bash
just test-all-integration
just test-project-integration network/legate
```

Notes:

- `scripts/test-all.sh` stops on the first failure.
- If `lake env lean --run ...` cannot load native FFI, the script falls back to `lake exe ...`.
- `scripts/build-native-libs.sh` builds fallback static libs in `.native-libs/lib`.

## Native Build Notes

- `graphics/afferent-demos`: use `graphics/afferent-demos/build.sh afferent_demos`
- Run demos from root: `lake exe afferent_demos`
- Run eschaton from root: `lake exe eschaton`

## Workspace Commands

```bash
just --list
just status
just clean
```

## License

MIT. See project-level `LICENSE` files.
