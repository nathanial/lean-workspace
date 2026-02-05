# Lean Workspace

A Lean 4 monorepo for building terminal UIs, graphics, networking, web frameworks, and data tooling.

This repository was consolidated from many former submodules into a single root repo with a single root Lake configuration.
All projects are now tracked directly in this repository. Do not use `git submodule` commands.

## Folder Structure

```
lean-workspace/
├── graphics/    # Graphics & UI (12 projects)
├── math/        # Scientific & Math (2 projects)
├── web/         # Web Framework Stack (8 projects)
├── network/     # Networking & Protocols (6 projects)
├── audio/       # Audio (1 project)
├── data/        # Data & Storage (12 projects)
├── apps/        # Applications (17 projects)
├── util/        # CLI & Utilities (12 projects)
└── testing/     # Testing (1 project)
```

## Projects

### Graphics & UI

| Project | Description |
|---------|-------------|
| [afferent](graphics/afferent) | 2D/3D graphics and UI framework with Metal GPU rendering (macOS); includes Afferent.Arbor/Afferent.Canopy |
| [afferent-demos](graphics/afferent-demos) | Standalone demo runner for the Afferent graphics framework |
| [terminus](graphics/terminus) | Terminal UI library (ratatui-style) with widgets, layouts, and styling |
| [trellis](graphics/trellis) | Pure CSS layout computation (Flexbox and Grid) |
| [tincture](graphics/tincture) | Color library with RGBA/HSV support and color operations |
| [chroma](graphics/chroma) | Color picker application built on afferent (Afferent.Arbor widgets) |
| [grove](graphics/grove) | Desktop file browser using afferent (Afferent.Arbor/Canopy) |
| [assimptor](graphics/assimptor) | 3D model loading via Assimp FFI (FBX, OBJ, COLLADA) |
| [worldmap](graphics/worldmap) | Tile-based map viewer with Web Mercator projection |
| [vane](graphics/vane) | Hardware-accelerated terminal emulator using Metal (WIP) |
| [raster](graphics/raster) | Image loading, saving, and manipulation via stb_image |
| [shader](graphics/shader) | GPU shader DSL for writing Metal shaders in pure Lean |

### Scientific & Math

| Project | Description |
|---------|-------------|
| [linalg](math/linalg) | Linear algebra library for game math (vectors, matrices, quaternions) |
| [measures](math/measures) | Type-safe units of measure with compile-time dimension checking |

### Web Framework Stack

| Project | Description |
|---------|-------------|
| [loom](web/loom) | Rails-like web framework integrating Citadel, Scribe, and Ledger |
| [citadel](web/citadel) | HTTP/1.1 server with routing, middleware, and SSE support |
| [herald](web/herald) | HTTP/1.1 message parser (requests, responses, chunked encoding) |
| [scribe](web/scribe) | Type-safe monadic HTML builder with HTMX integration |
| [markup](web/markup) | Strict HTML parser producing Scribe `Html` values |
| [chronicle](web/chronicle) | File-based logging library with text/JSON formats and Loom integration |
| [stencil](web/stencil) | Mustache/Handlebars-style template engine outputting Scribe Html |
| [docsite](web/docsite) | Documentation website for the Lean workspace |

### Networking & Protocols

| Project | Description |
|---------|-------------|
| [wisp](network/wisp) | HTTP client library with libcurl FFI bindings |
| [legate](network/legate) | Generic gRPC library with all streaming modes |
| [protolean](network/protolean) | Protocol Buffers implementation with compile-time `proto_import` |
| [oracle](network/oracle) | OpenRouter API client with streaming and tool calling |
| [jack](network/jack) | BSD socket bindings (TCP/UDP, IPv4/IPv6) |
| [exchange](network/exchange) | Peer-to-peer local network chat with mDNS discovery |

### Audio

| Project | Description |
|---------|-------------|
| [fugue](audio/fugue) | Functional sound synthesis library with macOS AudioToolbox FFI |

### Data & Storage

| Project | Description |
|---------|-------------|
| [ledger](data/ledger) | Datomic-like fact-based database with time-travel queries |
| [quarry](data/quarry) | SQLite library with vendored amalgamation (no system dependencies) |
| [chisel](data/chisel) | Type-safe SQL DSL with compile-time validation |
| [cellar](data/cellar) | Generic disk cache library with LRU eviction |
| [collimator](data/collimator) | Profunctor optics library (lenses, prisms, traversals) |
| [convergent](data/convergent) | Operation-based CRDTs for distributed systems |
| [reactive](data/reactive) | Reflex-style functional reactive programming (FRP) |
| [tabular](data/tabular) | CSV/TSV parser with typed column extraction |
| [entity](data/entity) | Archetypal Entity-Component-System (ECS) library |
| [totem](data/totem) | TOML configuration parser with typed extraction |
| [tileset](data/tileset) | GPU-agnostic map tile loading with caching and reactive updates |
| galaxy-gen | Procedural galaxy generation (planned) |

### Applications

| Project | Description |
|---------|-------------|
| [homebase-app](apps/homebase-app) | Personal dashboard with Kanban, auth, and multiple sections |
| [todo-app](apps/todo-app) | Demo todo list application built with Loom |
| [enchiridion](apps/enchiridion) | Terminal novel writing assistant with AI integration |
| [lighthouse](apps/lighthouse) | Terminal UI debugger/inspector for Ledger databases |
| [blockfall](apps/blockfall) | Terminal Tetris-like falling block puzzle game |
| [twenty48](apps/twenty48) | Terminal 2048 sliding puzzle game |
| [ask](apps/ask) | Minimal CLI for talking to AI models on OpenRouter |
| [cairn](apps/cairn) | Minecraft-style voxel game with Metal rendering |
| [minefield](apps/minefield) | Terminal Minesweeper game with keyboard controls |
| [solitaire](apps/solitaire) | Terminal Klondike Solitaire card game |
| [tracker](apps/tracker) | Local git-friendly issue tracker with CLI and TUI modes |
| [timekeeper](apps/timekeeper) | Terminal time tracking app with categories and reports |
| [eschaton](apps/eschaton) | Stellaris-inspired grand strategy game with Metal rendering |
| [chatline](apps/chatline) | Chat application (early stage) |
| [agent-mail](apps/agent-mail) | Multi-agent coordination layer with messaging and file reservations |
| [image-gen](apps/image-gen) | AI-powered image generation CLI using OpenRouter |
| astrometry | Astronomy application (planned) |

### CLI & Utilities

| Project | Description |
|---------|-------------|
| [parlance](util/parlance) | CLI library with argument parsing, styled output, and progress indicators |
| [staple](util/staple) | Essential utilities and macros (include_str% for compile-time file embedding) |
| [chronos](util/chronos) | Wall clock time library with nanosecond precision (POSIX FFI) |
| [rune](util/rune) | Regular expression library with Thompson NFA simulation |
| [sift](util/sift) | Parsec-style parser combinator library |
| [conduit](util/conduit) | Go-style typed channels for concurrency |
| [docgen](util/docgen) | Documentation generator for Lean 4 projects |
| [tracer](util/tracer) | Distributed tracing with W3C Trace Context support |
| [crypt](util/crypt) | Cryptographic primitives with libsodium FFI (hashing, encryption, HMAC) |
| [timeout](util/timeout) | Command timeout utility (shell script) |
| [smalltalk](util/smalltalk) | Smalltalk interpreter (WIP) |
| [selene](util/selene) | Lua-Lean 4 integration library with FFI bindings |

### Testing

| Project | Description |
|---------|-------------|
| [crucible](testing/crucible) | Lightweight test framework with declarative test macros |

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

Build from the repository root:

```bash
lake build
lake build workspace_smoke
lake exe workspace_smoke
```

Projects still live under category folders (`apps/`, `graphics/`, etc.), but Lake configuration is now centralized at the root.

## Project-Specific Builds

Some projects still have platform-specific native build requirements.

- `graphics/afferent-demos`: use
  - `graphics/afferent-demos/build.sh afferent_demos`
  - This script rebuilds native static libraries in `.native-libs/` and then runs `lake build afferent_demos` from repo root.

## Workspace Management

### Justfile (Recommended)

Run `just` to see recipes. Common ones:

```bash
just status
just build
just smoke
just run-smoke
just clean
```

### Shell Scripts

Helper scripts remain in `scripts/`. Prefer root-driven commands unless a project script is explicitly documented as required.

## Requirements

- Lean 4.26.x (`/Users/Shared/Projects/lean-workspace/lean-toolchain`)
- Platform-specific dependencies vary by project (see project READMEs)

## License

All projects are MIT licensed. See individual LICENSE files.
