# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Lean 4 workspace containing 25 interconnected projects organized into several stacks:

### Graphics & UI Stack
| Project | Description |
|---------|-------------|
| **terminus** | Terminal UI library (ratatui-style) with widgets, layouts, and styling |
| **afferent** | 2D/3D graphics and UI framework with Metal GPU rendering (macOS) |
| **arbor** | Renderer-agnostic widget library that emits render commands |
| **canopy** | Desktop widget framework built on top of Arbor |
| **trellis** | Pure CSS layout computation (Flexbox and Grid) |
| **tincture** | Color library with RGBA/HSV support and color utilities |
| **chroma** | Color picker application built on afferent/arbor |
| **assimptor** | 3D model loading via Assimp FFI (FBX, OBJ, COLLADA) |

### Web Framework Stack
| Project | Description |
|---------|-------------|
| **loom** | Rails-like web framework integrating Citadel, Scribe, and Ledger |
| **citadel** | HTTP/1.1 server with routing, middleware, and SSE support |
| **herald** | HTTP/1.1 message parser (requests, responses, chunked encoding) |
| **scribe** | Type-safe monadic HTML builder with HTMX integration |
| **chronicle** | File-based logging library with text/JSON formats and Loom integration |

### Networking & Protocols
| Project | Description |
|---------|-------------|
| **wisp** | HTTP client library with libcurl FFI bindings |
| **legate** | Generic gRPC library with all streaming modes |
| **protolean** | Protocol Buffers implementation with compile-time `proto_import` |

### Data & Storage
| Project | Description |
|---------|-------------|
| **ledger** | Datomic-like fact-based database with time-travel queries |
| **quarry** | SQLite library with vendored amalgamation (no system dependencies) |
| **cellar** | Generic disk cache library with LRU eviction |
| **collimator** | Profunctor optics library (lenses, prisms, traversals) |

### Applications
| Project | Description |
|---------|-------------|
| **homebase-app** | Personal dashboard with Kanban, auth, and multiple sections |
| **todo-app** | Demo todo list application built with Loom |
| **enchiridion** | Terminal novel writing assistant with AI integration |
| **lighthouse** | Terminal UI debugger/inspector for Ledger databases |

### Testing
| Project | Description |
|---------|-------------|
| **crucible** | Lightweight test framework with declarative test macros |

## Build Commands

Each project is built independently from its directory:

### terminus (Terminal UI)
```bash
cd terminus
lake build           # Build library and examples
lake exe hello       # Run hello world example
lake exe counter     # Interactive counter demo
lake exe dashboard   # Multi-widget demo
lake test            # Run tests
```

### afferent (Graphics Framework)
**Important:** Use `./build.sh` instead of `lake build` directly (sets `LEAN_CC=/usr/bin/clang` for macOS framework linking).
```bash
cd afferent
./build.sh           # Build the project
./run.sh             # Build and run demos
./test.sh            # Run tests
```

### arbor (Widget Library)
```bash
cd arbor
lake build
lake test
lake build ascii_demo
```

### canopy (Widget Framework)
```bash
cd canopy
lake build
```

### trellis (Layout Library)
```bash
cd trellis
lake build
lake test
```

### tincture (Color Library)
```bash
cd tincture
lake build
lake test
```

### chroma (Color Picker App)
**Important:** Use `./build.sh` instead of `lake build` directly.
```bash
cd chroma
./build.sh           # Build the project
./run.sh             # Build and run the app
./build.sh chroma_tests && .lake/build/bin/chroma_tests
```

### assimptor (3D Model Loading)
**Important:** Use `./build.sh` (builds vendored Assimp from source on first run).
```bash
cd assimptor
./build.sh           # Build the project (first run builds Assimp)
```

### loom (Web Framework)
```bash
cd loom
lake build
lake test
```

### citadel (HTTP Server)
```bash
cd citadel
lake build
lake test
lake exe static_site  # Run example server
```

### herald (HTTP Parser)
```bash
cd herald
lake build
lake test
```

### scribe (HTML Builder)
```bash
cd scribe
lake build
lake test
```

### homebase-app (Dashboard App)
```bash
cd homebase-app
lake build
.lake/build/bin/homebaseApp  # Run on port 3000
lake test
```

### todo-app (Todo Demo)
```bash
cd todo-app
lake build
.lake/build/bin/todoApp  # Run on port 3000
lake test
```

### collimator (Optics Library)
```bash
cd collimator
lake build
lake build collimator_tests && .lake/build/bin/collimator_tests
```

### legate (gRPC Library)
```bash
cd legate
lake run buildFfi    # First time: builds gRPC from source (slow)
lake build
lake test            # Unit tests
./run-tests.sh       # Full test suite including Go integration tests
```

### protolean (Protocol Buffers)
```bash
cd protolean
lake build
lake test
```

### wisp (HTTP Client)
```bash
cd wisp
lake build
lake test
```

### crucible (Test Framework)
```bash
cd crucible
lake build
```

### enchiridion (Novel Writing TUI)
```bash
cd enchiridion
lake build
lake exe enchiridion
lake test
```

### ledger (Fact-based Database)
```bash
cd ledger
lake build
lake test
```

### cellar (Disk Cache Library)
```bash
cd cellar
lake build
```

### chronicle (Logging Library)
```bash
cd chronicle
lake build
lake test
```

### lighthouse (Database Debugger)
```bash
cd lighthouse
lake build
.lake/build/bin/lighthouse <database.jsonl>  # Inspect a Ledger database
lake test
```

### quarry (SQLite Library)
**Important:** Use `./build.sh` to download SQLite amalgamation on first run.
```bash
cd quarry
./build.sh           # Downloads SQLite and builds
lake build           # Build library (after SQLite is downloaded)
lake test            # Run tests
```

## Dependency Graph

### Web Stack Dependencies
```
loom ───────────► citadel       (HTTP server)
     ├──────────► scribe        (HTML builder)
     ├──────────► ledger        (database)
     └──────────► herald        (HTTP parser, via citadel)
citadel ────────► herald        (HTTP parser)
homebase-app ───► loom          (web framework)
todo-app ───────► loom          (web framework)
```

### Graphics Stack Dependencies
```
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
```

### Other Dependencies
```
legate ─────────► protolean     (protobuf serialization)
enchiridion ───► terminus       (terminal UI)
            └──► wisp           (HTTP client)
lighthouse ────► terminus       (terminal UI)
           └───► ledger         (database)
```

### Test Framework Dependencies
Almost all projects depend on **crucible** for testing.

### External Dependencies
```
collimator ─────► mathlib       (Lean mathematical library)
ledger ─────────► batteries     (leanprover-community/batteries)
chroma ─────────► plausible     (property-based testing)
tincture ───────► plausible     (property-based testing)
```

## Architecture by Project

### terminus
Immediate-mode terminal rendering with buffer diffing:
- `Terminus/Core/` - Cell, Buffer, Rect, Style, Base64
- `Terminus/Widgets/` - Block, Paragraph, List, Table, Gauge, Charts, Tree, Calendar, Menu, Popup, TextArea, TextInput, Form, Spinner, and more
- `Terminus/Layout/` - Constraint-based layout (fixed, percent, ratio, fill)
- `Terminus/Input/` - Key events, polling
- `Terminus/Backend/` - Terminal backend abstraction
- `ffi/terminus.c` - termios bindings for raw terminal mode

### afferent
Metal-based graphics with Canvas API and widget system:
- `Afferent/Core/` - Point, Color, Rect, Path, Transform, Paint
- `Afferent/Canvas/` - HTML5 Canvas-style 2D drawing monad
- `Afferent/Widget/` - Elm-style declarative UI with events
- `Afferent/Layout/` - CSS Flexbox and Grid
- `Afferent/Render/` - Matrix4, FPSCamera, tessellation, 3D meshes
- `Afferent/FFI/` - Window, Renderer, Texture, Asset (Assimp)
- `native/src/metal/` - Metal shaders and pipeline

### arbor
Renderer-agnostic widget system with render command output:
- `Arbor/Core/` - Geometry types and TextMeasurer typeclass
- `Arbor/Widget/` - Widget DSL, layout measurement, text layout
- `Arbor/Render/` - RenderCommand definitions and command collection
- `Arbor/Event/` - Input events, hit testing, scroll state
- `Arbor/Text/` - ASCII canvas and debug renderer

### canopy
Desktop widget framework built on Arbor (scaffold for stateful widgets, focus management, themes).

### trellis
Pure CSS layout engine:
- `Trellis/Types.lean` - Constraints, sizes, and layout primitives
- `Trellis/Flex.lean` - Flexbox algorithm
- `Trellis/Grid.lean` - Grid layout algorithm
- `Trellis/Node.lean` / `Result.lean` - Layout tree and results

### tincture
Color representation and utilities:
- `Tincture/Color.lean` - RGBA/HSV color model
- `Tincture/Convert.lean` - Color space conversion
- `Tincture/Named.lean` - Named colors
- `Tincture/Gradient.lean` / `Palette.lean` - Gradients and palettes
- `Tincture/Blend.lean` - Color blending operations

### chroma
Color picker application using afferent, arbor, trellis, and tincture.

### assimptor
3D model loading via Assimp FFI:
- `Assimptor/Asset.lean` - LoadedAsset, SubMesh structures, loadAsset function
- `native/src/common/assimp_loader.cpp` - C++ Assimp integration
- `native/src/lean_bridge.c` - Lean FFI bridge
- Supports FBX, OBJ, COLLADA, and other formats

### loom
Rails-like web framework:
- `Loom/App.lean` - Application container, route registration, server lifecycle
- `Loom/Controller.lean` - Context, Action types, response builders
- `Loom/ActionM.lean` - Monadic action interface with StateT
- `Loom/Router.lean` - Named routes, URL generation
- `Loom/Session.lean` - Cookie-based sessions with signing
- `Loom/Flash.lean` - One-time flash messages
- `Loom/Form.lean` - Form parsing, CSRF protection
- `Loom/Middleware.lean` - Logging, security headers, CORS
- `Loom/Static.lean` - Static file serving
- `Loom/Htmx.lean` - HTMX integration helpers
- `Loom/SSE.lean` - Server-Sent Events support

### citadel
HTTP/1.1 server:
- `Citadel/Core.lean` - ServerConfig, Router, Route, Middleware, Handler types
- `Citadel/Server.lean` - Main server loop, connection handling
- `Citadel/Socket.lean` - POSIX socket FFI bindings
- `Citadel/SSE.lean` - Server-Sent Events with ConnectionManager
- `ffi/socket.c` - C socket implementation

### herald
HTTP/1.1 parser:
- `Herald/Core.lean` - Method, StatusCode, Headers, Request, Response types
- `Herald/Parser/Decoder.lean` - Parsing monad (ExceptT + StateM)
- `Herald/Parser/RequestLine.lean` - Request line parsing
- `Herald/Parser/StatusLine.lean` - Status line parsing
- `Herald/Parser/Headers.lean` - Header parsing with RFC 7230 compliance
- `Herald/Parser/Body.lean` - Body strategy determination
- `Herald/Parser/Chunked.lean` - Chunked transfer encoding
- `Herald/Parser/Message.lean` - Complete message parsing

### scribe
Type-safe HTML builder:
- `Scribe/Html.lean` - Html type, escaping, rendering
- `Scribe/Builder.lean` - HtmlM monad, element/text emission
- `Scribe/Elements.lean` - 60+ HTML element builders
- `Scribe/Attr.lean` - 50+ attribute helpers including HTMX
- `Scribe/RouteAttrs.lean` - Type-safe route-based attributes

### homebase-app
Personal dashboard application:
- `HomebaseApp/Main.lean` - App setup, routes, database config
- `HomebaseApp/Models.lean` - Ledger attribute definitions
- `HomebaseApp/Actions/` - Auth, Kanban, and section handlers
- `HomebaseApp/Views/` - Layout, forms, Kanban board rendering
- Features: auth, Kanban board, 8 dashboard sections

### todo-app
Demo todo application:
- `TodoApp/Main.lean` - App setup, routes
- `TodoApp/Models.lean` - User and Todo attributes
- `TodoApp/Actions/` - Auth and Todo CRUD handlers
- `TodoApp/Views/` - Layout, forms, todo list

### collimator
Profunctor optics encoded as polymorphic functions:
- `Collimator/Core/` - Profunctor, Strong, Choice, Wandering typeclasses
- `Collimator/Concrete/` - Forget, Star, Tagged, FunArrow profunctors
- `Collimator/Optics/` - Iso, Lens, Prism, Traversal, AffineTraversal

### legate
gRPC transport layer:
- `Legate/Channel.lean` - Client connections (insecure, TLS, mTLS)
- `Legate/Call.lean` - Unary RPC
- `Legate/Stream.lean` - Client/server/bidi streaming
- `Legate/Server.lean` - Server-side API
- `ffi/src/legate_ffi.cpp` - C++ gRPC wrapper

### protolean
Protocol Buffers with compile-time code generation:
- `Protolean/WireFormat.lean` - Wire types, field tags
- `Protolean/Encoder.lean` / `Decoder.lean` - Encode/decode monads
- `Protolean/Codec.lean` - ProtoEncodable, ProtoDecodable, ProtoMessage
- `Protolean/Parser/` - Proto3 file parser
- `Protolean/Codegen/` - Lean type generation from .proto files
- `proto_import` command - Compile-time .proto import

### wisp
HTTP client with libcurl FFI:
- `Wisp/Core/` - Request, Response, Error, Headers, Streaming
- `Wisp/FFI/` - Easy handle, Multi handle, curl bindings
- `Wisp/HTTP/` - Client, SSE (Server-Sent Events)
- `native/src/wisp_ffi.c` - C bindings for libcurl

### crucible
Lightweight test framework:
- `Crucible/Core.lean` - TestCase, assertions (shouldBe, shouldSatisfy, etc.)
- `Crucible/Macros.lean` - `test "name" := do` macro, `#generate_tests`
- `Crucible/SuiteRegistry.lean` - `testSuite` command, suite collection

### enchiridion
Terminal novel writing assistant:
- `Enchiridion/Core.lean` - Core types and utilities
- `Enchiridion/Model.lean` - Novel, Chapter, Scene data models
- `Enchiridion/State.lean` - Application state management
- `Enchiridion/Storage.lean` - Persistence layer
- `Enchiridion/AI.lean` - AI integration for writing assistance
- `Enchiridion/UI.lean` - Terminal UI components (uses terminus)

### ledger
Datomic-like fact-based database:
- `Ledger/Core/` - EntityId, Attribute, Value, Datom
- `Ledger/Index/` - EAVT, AEVT, AVET, VAET indexes
- `Ledger/Tx/` - Transaction types and processing
- `Ledger/Db/` - Database, TimeTravel, Connection
- `Ledger/Query/` - Datalog-style query engine
- `Ledger/Pull/` - Entity tree retrieval API
- `Ledger/DSL/` - Query, Pull, Tx builders

### cellar
Disk cache with LRU eviction:
- `Cellar/Config.lean` - Cache configuration
- `Cellar/LRU.lean` - LRU index logic
- `Cellar/IO.lean` - File IO helpers

### chronicle
File-based logging with Loom integration:
- `Chronicle/Level.lean` - Log levels (trace, debug, info, warn, error)
- `Chronicle/Config.lean` - Logger configuration (path, level, format, stderr)
- `Chronicle/Format.lean` - Text and JSON output formatters
- `Chronicle/Logger.lean` - Logger handle, logging methods, withLogger RAII pattern
- Loom integration via `Loom.Chronicle` module (in loom package)

### lighthouse
Terminal debugger for Ledger databases:
- `Lighthouse/Core/` - Database loading and data types
- `Lighthouse/State/` - Application state and navigation history
- `Lighthouse/UI/` - View rendering (Entity Browser, Transaction Log, Attribute Index, Query Interface)
- `Main.lean` - Entry point, key handling, view switching

### quarry
SQLite library with vendored amalgamation:
- `Quarry/Core/` - Value, Row, Column, Error types
- `Quarry/FFI/` - Low-level SQLite bindings
- `Quarry/Database.lean` - High-level database API (open, exec, query)
- `Quarry/Bind.lean` - Parameter binding (ToSql typeclass)
- `Quarry/Extract.lean` - Result extraction (FromSql typeclass)
- `Quarry/Transaction.lean` - Transaction and savepoint support
- `native/sqlite/` - SQLite amalgamation (downloaded by build.sh)
- `native/src/quarry_ffi.c` - C FFI bridge

## Lean Version

Most projects target Lean 4.26.0. Check individual `lean-toolchain` files for exact versions.

## FFI Patterns

### Opaque Handle Pattern (afferent, terminus)
```lean
opaque WindowPointed : NonemptyType
def Window : Type := WindowPointed.type

@[extern "lean_window_create"]
opaque Window.create : UInt32 → UInt32 → String → IO Window
```

### External Class Registration (afferent)
```c
static lean_external_class* g_font_class = NULL;
// Init: g_font_class = lean_register_external_class(finalizer, NULL);
// Use: lean_alloc_external(g_font_class, native_ptr);
```

### Returning Tuples from C (afferent)
```c
// Float × Float × Float = Prod Float (Prod Float Float)
lean_object* inner = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(inner, 0, lean_box_float(val2));
lean_ctor_set(inner, 1, lean_box_float(val3));
lean_object* outer = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(outer, 0, lean_box_float(val1));
lean_ctor_set(outer, 1, inner);
```

## Testing

Each project has its own test suite. Run from the project directory:
- `lake test` - Standard test driver
- `./test.sh` - Custom test script (afferent)
- Direct executable runs for some projects (chroma, collimator)

Projects using the **Crucible** test framework: afferent, arbor, chroma, chronicle, citadel, collimator, enchiridion, herald, homebase-app, ledger, legate, lighthouse, loom, protolean, quarry, scribe, terminus, tincture, todo-app, trellis, wisp

Projects without a test target: canopy, cellar, crucible (crucible is the test framework itself), assimptor

## Workspace Management

### Justfile (Recommended)

```bash
just status              # Show status of all submodules
just build <project>     # Build a specific project
just build-all           # Build all projects
just test <project>      # Test a specific project
just test-all            # Test all projects
just versions            # Show Lean versions
just lines               # Count lines of Lean code
just deps                # Show dependency graph
```

### Shell Scripts

```bash
./scripts/git-status.sh              # Check which projects have changes
./scripts/git-add-commit-push.sh "msg"  # Stage, commit, and push all
./scripts/count-lean-lines.sh        # Count Lean code lines
./scripts/generate-local-overrides.sh   # Enable local dev mode
./scripts/remove-local-overrides.sh     # Disable local dev mode
```
