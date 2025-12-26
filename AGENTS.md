# Repository Guidelines

## Overview

This workspace contains 30 independent Lean 4 projects organized into several stacks:

**Graphics & UI:** `afferent`, `arbor`, `canopy`, `terminus`, `trellis`, `tincture`, `chroma`, `assimptor`, `worldmap`

**Web Framework:** `loom`, `citadel`, `herald`, `scribe`, `chronicle`

**Networking:** `wisp`, `legate`, `protolean`, `oracle`

**Data & Storage:** `ledger`, `quarry`, `chisel`, `cellar`, `collimator`

**Applications:** `homebase-app`, `todo-app`, `enchiridion`, `lighthouse`

**CLI & Utilities:** `parlance`, `staple`

**Testing:** `crucible`

Each project is built and tested from its own directory. Architectural details live in the per-project `README.md` plus the top-level `CLAUDE.md`.

## Project Descriptions

| Project | Description |
|---------|-------------|
| **afferent** | 2D/3D graphics and UI framework with Metal GPU rendering (macOS) |
| **arbor** | Renderer-agnostic widget library that emits render commands |
| **assimptor** | 3D model loading via Assimp FFI (FBX, OBJ, COLLADA) |
| **canopy** | Desktop widget framework built on top of Arbor |
| **cellar** | Generic disk cache library with LRU eviction |
| **chisel** | Type-safe SQL DSL with compile-time validation |
| **chroma** | Color picker application built on afferent/arbor |
| **chronicle** | File-based logging library with text/JSON formats and Loom integration |
| **citadel** | HTTP/1.1 server with routing, middleware, and SSE support |
| **collimator** | Profunctor optics library (lenses, prisms, traversals) |
| **crucible** | Lightweight test framework with declarative test macros |
| **enchiridion** | Terminal novel writing assistant with AI integration |
| **herald** | HTTP/1.1 message parser (requests, responses, chunked encoding) |
| **homebase-app** | Personal dashboard with Kanban, auth, and multiple sections |
| **ledger** | Datomic-like fact-based database with time-travel queries |
| **legate** | Generic gRPC library with all streaming modes |
| **lighthouse** | Terminal UI debugger/inspector for Ledger databases |
| **loom** | Rails-like web framework integrating Citadel, Scribe, and Ledger |
| **oracle** | OpenRouter API client with streaming and tool calling |
| **parlance** | CLI library with argument parsing, styled output, and progress indicators |
| **protolean** | Protocol Buffers implementation with compile-time `proto_import` |
| **quarry** | SQLite library with vendored amalgamation (no system dependencies) |
| **scribe** | Type-safe monadic HTML builder with HTMX integration |
| **staple** | Essential utilities and macros (include_str% for compile-time file embedding) |
| **terminus** | Terminal UI library (ratatui-style) with widgets, layouts, and styling |
| **tincture** | Color library with RGBA/HSV support and color operations |
| **todo-app** | Demo todo list application built with Loom |
| **trellis** | Pure CSS layout computation (Flexbox and Grid) |
| **wisp** | HTTP client library with libcurl FFI bindings |
| **worldmap** | Tile-based map viewer with Web Mercator projection |

## Project Structure & Module Organization

- Project roots: Each project lives in its own directory (e.g., `afferent/`, `loom/`, `terminus/`).
- Lean sources live in project-named folders (e.g., `Terminus/`, `Afferent/`, `Loom/`) with entry points in `*.lean` at the repo root (e.g., `Terminus.lean`).
- Tests are project-local (`Tests/`, `Tests.lean`, or project-specific like `CollimatorTests/`).
- FFI and native code: `ffi/` or `native/` (keep wrappers small and focused).
- Assets and demos: `assets/`, `examples/`, `Demos/`, `testapp/`.
- Vendored dependencies: `third_party/` or git submodules (e.g., `assimptor/assimp`).

## Build, Test, and Development Commands

Run commands from the project directory:

### Standard Lake Projects
```bash
lake build           # Build the project
lake test            # Run tests (if available)
```

### Projects with Custom Build Scripts
These projects require `./build.sh` instead of `lake build` directly:
- **afferent**: `./build.sh`, `./run.sh`, `./test.sh`
- **chroma**: `./build.sh`, `./run.sh`
- **assimptor**: `./build.sh` (builds vendored Assimp on first run)
- **quarry**: `./build.sh` (downloads SQLite amalgamation on first run)
- **worldmap**: `./build.sh`, `./run.sh` (depends on afferent for Metal rendering)

### Web Applications
```bash
# homebase-app
lake build && .lake/build/bin/homebaseApp  # Runs on port 3000

# todo-app
lake build && .lake/build/bin/todoApp      # Runs on port 3000

# citadel example
lake exe static_site                        # Runs example server
```

### Special Test Commands
```bash
# collimator
lake build collimator_tests && .lake/build/bin/collimator_tests

# chroma
./build.sh chroma_tests && .lake/build/bin/chroma_tests

# legate (full suite with Go integration)
lake run buildFfi    # First time only
./run-tests.sh
```

After any change, build and run tests. Note that `lake build` only builds the default target; if you touched a non-default executable/library, run a specific build.

## Coding Style & Naming Conventions

- Lean: follow existing file layout and `namespace` naming (PascalCase modules under project directories). Indent with two spaces and keep definitions grouped by module.
- Prefer descriptive module/file names that mirror the namespace, e.g., `Legate/Stream.lean`, `Loom/Router.lean`.
- Keep C/C++ FFI files in `ffi/` or `native/`; use `lean_*` exports and minimal allocation glue consistent with nearby code.

## Testing Guidelines

- Keep tests alongside their project and name modules with `Tests`/`*Tests` conventions.
- Run targeted `lake test` before cross-project changes.
- Always run `lake test` when the project supports it.

**Projects with tests:** afferent, arbor, chisel, chroma, chronicle, citadel, collimator, enchiridion, herald, homebase-app, ledger, legate, lighthouse, loom, oracle, parlance, protolean, quarry, scribe, terminus, tincture, todo-app, trellis, wisp

**Projects without tests:** assimptor, canopy, cellar, crucible (crucible is the test framework itself), staple, worldmap

## Dependency Graph

### Web Stack
```
loom ───────────► citadel       (HTTP server)
     ├──────────► scribe        (HTML builder)
     ├──────────► ledger        (database)
     └──────────► herald        (via citadel)
citadel ────────► herald        (HTTP parser)
homebase-app ───► loom
todo-app ───────► loom
```

### Graphics Stack
```
afferent ───────► collimator, wisp, cellar, trellis, arbor, tincture, assimptor
arbor ──────────► trellis, tincture
canopy ─────────► arbor
chroma ─────────► afferent, arbor, trellis, tincture
worldmap ───────► afferent, wisp, cellar
```

### Other
```
legate ─────────► protolean
oracle ─────────► wisp
enchiridion ───► terminus, wisp
lighthouse ────► terminus, ledger
```

### External Dependencies
```
collimator ─────► mathlib
ledger ─────────► batteries
chroma, tincture ► plausible
```

## Commit & Pull Request Guidelines

- Commit messages are short, lowercase, and imperative (examples: "fix the tiles", "upgrade to v4.26.0"). No ticket prefixes observed.
- PRs should include: a clear summary, tests run, and screenshots or recordings for UI/graphics changes.
- Link related issues when applicable.

## Toolchain & Configuration Notes

- Each project pins its own `lean-toolchain` (mostly Lean 4.26.0). Run `lake` per project directory to avoid version mismatches.
- `afferent`, `chroma`, and `assimptor` require `./build.sh` to set the macOS toolchain correctly (`LEAN_CC=/usr/bin/clang`).

## Workspace Management

### Justfile Commands
```bash
just status          # Show status of all submodules
just build <project> # Build a specific project
just build-all       # Build all projects
just test <project>  # Test a specific project
just test-all        # Test all projects
just versions        # Show Lean versions
just lines           # Count lines of Lean code
just deps            # Show dependency graph
```

### Shell Scripts
```bash
./scripts/git-status.sh              # Check which projects have changes
./scripts/git-add-commit-push.sh "msg"  # Stage, commit, and push all
./scripts/count-lean-lines.sh        # Count Lean code lines
./scripts/generate-local-overrides.sh   # Enable local dev mode
./scripts/remove-local-overrides.sh     # Disable local dev mode
```

## Important Reminders

ALWAYS VERIFY THAT THE CODE COMPILES!!
