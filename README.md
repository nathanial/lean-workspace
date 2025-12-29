# Lean Workspace

A collection of Lean 4 libraries for building applications with terminal UIs, graphics, networking, web frameworks, and data management.

## Projects

### Graphics & UI

| Project | Description |
|---------|-------------|
| [afferent](https://github.com/nathanial/afferent) | 2D/3D graphics and UI framework with Metal GPU rendering (macOS) |
| [arbor](https://github.com/nathanial/arbor) | Renderer-agnostic widget library that emits render commands |
| [canopy](https://github.com/nathanial/canopy) | Desktop widget framework built on top of Arbor |
| [terminus](https://github.com/nathanial/terminus) | Terminal UI library (ratatui-style) with widgets, layouts, and styling |
| [trellis](https://github.com/nathanial/trellis) | Pure CSS layout computation (Flexbox and Grid) |
| [tincture](https://github.com/nathanial/tincture) | Color library with RGBA/HSV support and color operations |
| [chroma](https://github.com/nathanial/chroma) | Color picker application built on afferent/arbor |
| [assimptor](https://github.com/nathanial/assimptor) | 3D model loading via Assimp FFI (FBX, OBJ, COLLADA) |
| [worldmap](https://github.com/nathanial/worldmap) | Tile-based map viewer with Web Mercator projection |
| [vane](https://github.com/nathanial/vane) | Hardware-accelerated terminal emulator using Metal (WIP) |

### Scientific & Math

| Project | Description |
|---------|-------------|
| [linalg](https://github.com/nathanial/linalg) | Linear algebra library for game math (vectors, matrices, quaternions) |
| [measures](https://github.com/nathanial/measures) | Type-safe units of measure with compile-time dimension checking |

### Web Framework Stack

| Project | Description |
|---------|-------------|
| [loom](https://github.com/nathanial/loom) | Rails-like web framework integrating Citadel, Scribe, and Ledger |
| [citadel](https://github.com/nathanial/citadel) | HTTP/1.1 server with routing, middleware, and SSE support |
| [herald](https://github.com/nathanial/herald) | HTTP/1.1 message parser (requests, responses, chunked encoding) |
| [scribe](https://github.com/nathanial/scribe) | Type-safe monadic HTML builder with HTMX integration |
| [markup](https://github.com/nathanial/markup) | Strict HTML parser producing Scribe `Html` values |
| [chronicle](https://github.com/nathanial/chronicle) | File-based logging library with text/JSON formats and Loom integration |

### Networking & Protocols

| Project | Description |
|---------|-------------|
| [wisp](https://github.com/nathanial/wisp) | HTTP client library with libcurl FFI bindings |
| [legate](https://github.com/nathanial/legate) | Generic gRPC library with all streaming modes |
| [protolean](https://github.com/nathanial/protolean) | Protocol Buffers implementation with compile-time `proto_import` |
| [oracle](https://github.com/nathanial/oracle) | OpenRouter API client with streaming and tool calling |

### Audio

| Project | Description |
|---------|-------------|
| [fugue](https://github.com/nathanial/fugue) | Functional sound synthesis library with macOS AudioToolbox FFI |

### Data & Storage

| Project | Description |
|---------|-------------|
| [ledger](https://github.com/nathanial/ledger) | Datomic-like fact-based database with time-travel queries |
| [quarry](https://github.com/nathanial/quarry) | SQLite library with vendored amalgamation (no system dependencies) |
| [chisel](https://github.com/nathanial/chisel) | Type-safe SQL DSL with compile-time validation |
| [cellar](https://github.com/nathanial/cellar) | Generic disk cache library with LRU eviction |
| [collimator](https://github.com/nathanial/collimator) | Profunctor optics library (lenses, prisms, traversals) |

### Applications

| Project | Description |
|---------|-------------|
| [homebase-app](https://github.com/nathanial/homebase-app) | Personal dashboard with Kanban, auth, and multiple sections |
| [todo-app](https://github.com/nathanial/todo-app) | Demo todo list application built with Loom |
| [enchiridion](https://github.com/nathanial/enchiridion) | Terminal novel writing assistant with AI integration |
| [lighthouse](https://github.com/nathanial/lighthouse) | Terminal UI debugger/inspector for Ledger databases |
| [blockfall](https://github.com/nathanial/blockfall) | Terminal Tetris-like falling block puzzle game |
| [twenty48](https://github.com/nathanial/twenty48) | Terminal 2048 sliding puzzle game |
| [ask](https://github.com/nathanial/ask) | Minimal CLI for talking to AI models on OpenRouter |

### CLI & Utilities

| Project | Description |
|---------|-------------|
| [parlance](https://github.com/nathanial/parlance) | CLI library with argument parsing, styled output, and progress indicators |
| [staple](https://github.com/nathanial/staple) | Essential utilities and macros (include_str% for compile-time file embedding) |
| [chronos](https://github.com/nathanial/chronos-lean) | Wall clock time library with nanosecond precision (POSIX FFI) |

### Testing

| Project | Description |
|---------|-------------|
| [crucible](https://github.com/nathanial/crucible) | Lightweight test framework with declarative test macros |

## Dependency Graph

```
Web Stack:
loom ───────────► citadel       (HTTP server)
     ├──────────► scribe        (HTML builder)
     ├──────────► ledger        (database)
     └──────────► herald        (HTTP parser, via citadel)
citadel ────────► herald        (HTTP parser)
markup ─────────► scribe        (HTML types)
homebase-app ───► loom          (web framework)
todo-app ───────► loom          (web framework)

Graphics Stack:
afferent ───────► collimator    (profunctor optics)
         ├──────► wisp          (HTTP client)
         ├──────► cellar        (disk cache)
         ├──────► trellis       (layout)
         ├──────► arbor         (widgets)
         ├──────► tincture      (color)
         └──────► assimptor     (3D models)
arbor ──────────► trellis       (layout)
      └─────────► tincture      (color)
canopy ─────────► arbor         (widgets)
chroma ─────────► afferent      (rendering)
       ├────────► arbor         (widgets)
       ├────────► trellis       (layout)
       └────────► tincture      (color)
worldmap ───────► afferent      (rendering)
         ├──────► wisp          (HTTP client)
         └──────► cellar        (disk cache)
vane ───────────► afferent      (rendering)

Other:
legate ─────────► protolean     (protobuf serialization)
oracle ─────────► wisp          (HTTP client)
enchiridion ───► terminus       (terminal UI)
            └──► wisp           (HTTP client)
lighthouse ────► terminus       (terminal UI)
           └───► ledger         (database)
blockfall ─────► terminus       (terminal UI)
twenty48 ──────► terminus       (terminal UI)
ask ───────────► parlance       (CLI library)
    └──────────► oracle         (OpenRouter client)
```

## Quick Start

Each project is built independently from its directory:

```bash
cd <project>
lake build
lake test  # if available
```

Some projects require custom scripts (notably `afferent`, `chroma`, `assimptor`, `quarry`, `fugue`, and `vane` use `./build.sh` for special build requirements). See individual project READMEs for specific build instructions.

## Workspace Management

### Justfile (Recommended)

The workspace includes a `justfile` for common operations. Run `just` to see all recipes:

```bash
# Git/submodule operations
just status              # Show status of all submodules
just fetch               # Fetch from all remotes
just pull                # Pull latest in all submodules
just push                # Push submodules with unpushed commits

# Building and testing
just build <project>     # Build a specific project
just build-all           # Build all projects
just test <project>      # Test a specific project
just test-all            # Test all projects

# Utilities
just versions            # Show Lean versions across all projects
just lines               # Count lines of Lean code
just deps                # Show dependency graph
```

### Shell Scripts

Helper scripts in `scripts/` for advanced operations:

```bash
./scripts/git-status.sh              # Check which projects have changes
./scripts/git-add-commit-push.sh "msg"  # Stage, commit, and push all
./scripts/count-lean-lines.sh        # Count Lean code lines
```

## Requirements

- Lean 4.26.x (check individual `lean-toolchain` files)
- Platform-specific dependencies vary by project (see individual READMEs)

## License

All projects are MIT licensed. See individual LICENSE files.
