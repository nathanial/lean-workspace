# Lean Workspace

A collection of Lean 4 libraries for building applications with terminal UIs, graphics, networking, web frameworks, and data management.

## Folder Structure

```
lean-workspace/
├── graphics/    # Graphics & UI (11 projects)
├── math/        # Scientific & Math (2 projects)
├── web/         # Web Framework Stack (7 projects)
├── network/     # Networking & Protocols (6 projects)
├── audio/       # Audio (1 project)
├── data/        # Data & Storage (12 projects)
├── apps/        # Applications (15 projects)
├── util/        # CLI & Utilities (11 projects)
└── testing/     # Testing (1 project)
```

## Projects

### Graphics & UI

| Project | Description |
|---------|-------------|
| [afferent](https://github.com/nathanial/afferent) | 2D/3D graphics and UI framework with Metal GPU rendering (macOS); includes Afferent.Arbor/Afferent.Canopy |
| [afferent-demos](https://github.com/nathanial/afferent-demos) | Standalone demo runner for the Afferent graphics framework |
| [terminus](https://github.com/nathanial/terminus) | Terminal UI library (ratatui-style) with widgets, layouts, and styling |
| [trellis](https://github.com/nathanial/trellis) | Pure CSS layout computation (Flexbox and Grid) |
| [tincture](https://github.com/nathanial/tincture) | Color library with RGBA/HSV support and color operations |
| [chroma](https://github.com/nathanial/chroma) | Color picker application built on afferent (Afferent.Arbor widgets) |
| [grove](https://github.com/nathanial/grove) | Desktop file browser using afferent (Afferent.Arbor/Canopy) |
| [assimptor](https://github.com/nathanial/assimptor) | 3D model loading via Assimp FFI (FBX, OBJ, COLLADA) |
| [worldmap](https://github.com/nathanial/worldmap) | Tile-based map viewer with Web Mercator projection |
| [vane](https://github.com/nathanial/vane) | Hardware-accelerated terminal emulator using Metal (WIP) |
| [raster](https://github.com/nathanial/raster) | Image loading, saving, and manipulation via stb_image |

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
| [stencil](https://github.com/nathanial/stencil) | Mustache/Handlebars-style template engine outputting Scribe Html |

### Networking & Protocols

| Project | Description |
|---------|-------------|
| [wisp](https://github.com/nathanial/wisp) | HTTP client library with libcurl FFI bindings |
| [legate](https://github.com/nathanial/legate) | Generic gRPC library with all streaming modes |
| [protolean](https://github.com/nathanial/protolean) | Protocol Buffers implementation with compile-time `proto_import` |
| [oracle](https://github.com/nathanial/oracle) | OpenRouter API client with streaming and tool calling |
| [jack](https://github.com/nathanial/jack) | BSD socket bindings (TCP/UDP, IPv4/IPv6) |
| [exchange](https://github.com/nathanial/exchange) | Peer-to-peer local network chat with mDNS discovery |

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
| [convergent](https://github.com/nathanial/convergent) | Operation-based CRDTs for distributed systems |
| [reactive](https://github.com/nathanial/reactive) | Reflex-style functional reactive programming (FRP) |
| [tabular](https://github.com/nathanial/tabular) | CSV/TSV parser with typed column extraction |
| [entity](https://github.com/nathanial/entity) | Archetypal Entity-Component-System (ECS) library |
| [totem](https://github.com/nathanial/totem) | TOML configuration parser with typed extraction |
| [tileset](https://github.com/nathanial/tileset) | GPU-agnostic map tile loading with caching and reactive updates |
| galaxy-gen | Procedural galaxy generation (planned) |

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
| [cairn](https://github.com/nathanial/cairn) | Minecraft-style voxel game with Metal rendering |
| [minefield](https://github.com/nathanial/minefield) | Terminal Minesweeper game with keyboard controls |
| [solitaire](https://github.com/nathanial/solitaire) | Terminal Klondike Solitaire card game |
| [tracker](https://github.com/nathanial/tracker) | Local git-friendly issue tracker with CLI and TUI modes |
| [timekeeper](https://github.com/nathanial/timekeeper) | Terminal time tracking app with categories and reports |
| [eschaton](https://github.com/nathanial/eschaton) | Stellaris-inspired grand strategy game with Metal rendering |
| [chatline](https://github.com/nathanial/chatline) | Chat application (early stage) |
| astrometry | Astronomy application (planned) |

### CLI & Utilities

| Project | Description |
|---------|-------------|
| [parlance](https://github.com/nathanial/parlance) | CLI library with argument parsing, styled output, and progress indicators |
| [staple](https://github.com/nathanial/staple) | Essential utilities and macros (include_str% for compile-time file embedding) |
| [chronos](https://github.com/nathanial/chronos-lean) | Wall clock time library with nanosecond precision (POSIX FFI) |
| [rune](https://github.com/nathanial/rune) | Regular expression library with Thompson NFA simulation |
| [sift](https://github.com/nathanial/sift) | Parsec-style parser combinator library |
| [conduit](https://github.com/nathanial/conduit) | Go-style typed channels for concurrency |
| [docgen](https://github.com/nathanial/docgen) | Documentation generator for Lean 4 projects |
| [tracer](https://github.com/nathanial/tracer) | Distributed tracing with W3C Trace Context support |
| [crypt](https://github.com/nathanial/crypt) | Cryptographic primitives with libsodium FFI (hashing, encryption, HMAC) |
| [timeout](https://github.com/nathanial/timeout) | Command timeout utility (shell script) |
| [smalltalk](https://github.com/nathanial/smalltalk) | Smalltalk interpreter (WIP) |

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
stencil ────────► scribe        (HTML output)
homebase-app ───► loom          (web framework)
todo-app ───────► loom          (web framework)

Graphics Stack:
afferent ───────► collimator    (profunctor optics)
         ├──────► wisp          (HTTP client)
         ├──────► cellar        (disk cache)
         ├──────► trellis       (layout)
         ├──────► tincture      (color)
         ├──────► Afferent.Arbor/Canopy (widgets)
         └──────► assimptor     (3D models)
afferent-demos ─► afferent      (rendering + demos)
chroma ─────────► afferent      (rendering + widgets)
worldmap ───────► afferent      (rendering)
         ├──────► wisp          (HTTP client)
         └──────► cellar        (disk cache)
vane ───────────► afferent      (rendering)
eschaton ───────► afferent      (rendering + Canopy UI)
tileset ────────► cellar        (disk cache)
         ├──────► wisp          (HTTP client)
         └──────► reactive      (FRP)

Other:
exchange ───────► jack          (sockets)
legate ─────────► protolean     (protobuf serialization)
oracle ─────────► wisp          (HTTP client)
enchiridion ───► terminus       (terminal UI)
            └──► wisp           (HTTP client)
lighthouse ────► terminus       (terminal UI)
           └───► ledger         (database)
blockfall ─────► terminus       (terminal UI)
twenty48 ──────► terminus       (terminal UI)
minefield ─────► terminus       (terminal UI)
solitaire ─────► terminus       (terminal UI)
tracker ───────► terminus       (terminal UI)
        ├──────► parlance       (CLI library)
        └──────► chronos        (timestamps)
timekeeper ────► terminus       (terminal UI)
           └───► chronos        (timestamps)
ask ───────────► parlance       (CLI library)
    └──────────► oracle         (OpenRouter client)
docgen ────────► parlance       (CLI library)
       ├───────► scribe         (HTML generation)
       └───────► staple         (file embedding)
```

## Quick Start

Each project is built independently from its directory:

```bash
cd <category>/<project>
lake build
lake test  # if available
```

Examples:
```bash
cd graphics/terminus && lake build   # Build terminus
cd web/loom && lake build            # Build loom
cd apps/blockfall && lake build      # Build blockfall
```

Some projects require custom scripts (notably `graphics/afferent`, `graphics/chroma`, `graphics/assimptor`, `graphics/raster`, `graphics/grove`, `data/quarry`, `audio/fugue`, `graphics/vane`, `apps/cairn`, and `apps/eschaton` use `./build.sh` for special build requirements). See individual project READMEs for specific build instructions.

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
just build <category>/<project>  # Build a specific project
just build-all                   # Build all projects
just test <category>/<project>   # Test a specific project
just test-all                    # Test all projects

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
