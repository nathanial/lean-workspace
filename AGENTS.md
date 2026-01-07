# Repository Guidelines

Lean 4 workspace with 56 projects. See `CLAUDE.md` for full project list and dependency graph.

## Directory Layout

```
<category>/<project>/
  ├── <Project>/        # Lean sources (PascalCase)
  ├── <Project>.lean    # Entry point
  ├── Tests/            # Tests (or Tests.lean, *Tests/)
  ├── ffi/ or native/   # C/C++ FFI code
  └── lakefile.lean
```

Categories: `graphics/`, `web/`, `network/`, `data/`, `apps/`, `util/`, `math/`, `audio/`, `testing/`

## Build & Test

**Default:** `lake build && lake test`

**Requires ./build.sh:** afferent, cairn, chroma, grove, vane, worldmap (Metal), quarry, raster (vendored deps), fugue (AudioToolbox), assimptor (Assimp)

**legate:** Run `lake run buildFfi` first (builds gRPC)

**Web apps:** `.lake/build/bin/homebaseApp` or `todoApp` (port 3000)

## Coding Style

- PascalCase modules matching namespace (e.g., `Legate/Stream.lean`)
- 2-space indent
- Keep FFI wrappers minimal in `ffi/` or `native/`

## Commits

Short, lowercase, imperative: "fix tile rendering", "add streaming support"

## Important

**ALWAYS VERIFY THAT THE CODE COMPILES**
