# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Lean 4 workspace containing fifteen interconnected projects:

| Project | Description |
|---------|-------------|
| **terminus** | Terminal UI library (ratatui-style) with widgets, layouts, and styling |
| **afferent** | 2D/3D graphics and UI framework with Metal GPU rendering (macOS) |
| **arbor** | Renderer-agnostic widget library that emits render commands |
| **canopy** | Desktop widget framework built on top of Arbor |
| **trellis** | Pure CSS layout computation (Flexbox and Grid) |
| **tincture** | Color library with RGBA/HSV support and color utilities |
| **chroma** | Color picker application built on afferent/arbor |
| **collimator** | Profunctor optics library (lenses, prisms, traversals) |
| **legate** | Generic gRPC library with all streaming modes |
| **protolean** | Protocol Buffers implementation with compile-time `proto_import` |
| **wisp** | HTTP client library with libcurl FFI bindings |
| **crucible** | Lightweight test framework with declarative test macros |
| **enchiridion** | Terminal novel writing assistant with AI integration |
| **ledger** | Datomic-like fact-based database with time-travel queries |
| **cellar** | Generic disk cache library with LRU eviction |

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
**Important:** Use `./build.sh` instead of `lake build` directly (sets `LEAN_CC=/usr/bin/clang` for macOS framework linking).
```bash
cd chroma
./build.sh           # Build the project
./run.sh             # Build and run the app
./build.sh chroma_tests && .lake/build/bin/chroma_tests
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

## Dependency Graph

```
afferent ───────► collimator    (profunctor optics)
         ├──────► wisp          (HTTP client)
         ├──────► cellar        (disk cache)
         ├──────► trellis       (layout)
         ├──────► arbor         (widgets)
         └──────► tincture      (color)
arbor ──────────► trellis       (layout)
      └────────► tincture      (color)
canopy ─────────► arbor         (widgets)
chroma ─────────► afferent      (rendering)
      ├────────► arbor          (widgets)
      ├────────► trellis        (layout)
      └────────► tincture       (color)
legate ─────────► protolean     (protobuf serialization)
enchiridion ───► terminus       (terminal UI)
            └──► wisp           (HTTP client for AI APIs)
collimator ─────► crucible      (test framework)
trellis ─────────► crucible     (test framework)
tincture ────────► crucible     (test framework)
wisp ───────────► crucible      (test framework)
```

## Architecture by Project

### terminus
Immediate-mode terminal rendering with buffer diffing:
- `Terminus/Core/` - Cell, Buffer, Rect, Style, Color
- `Terminus/Widgets/` - Block, Paragraph, List, Table, Gauge, Charts, Tree, etc.
- `Terminus/Layout/` - Constraint-based layout (fixed, percent, ratio, fill)
- `Terminus/Input/` - Key events, polling
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
Desktop widget framework built on Arbor:
- `Canopy/Core.lean` - Core namespace and re-exports (scaffold)
- Intended to host stateful widgets, focus management, and themes

### trellis
Pure CSS layout engine:
- `Trellis/Types.lean` - Constraints, sizes, and layout primitives
- `Trellis/Flex.lean` - Flexbox algorithm
- `Trellis/Grid.lean` - Grid layout algorithm
- `Trellis/Algorithm.lean` - Layout entry point
- `Trellis/Node.lean` / `Result.lean` - Layout tree and results

### tincture
Color representation and utilities:
- `Tincture/Color.lean` - RGBA/HSV color model
- `Tincture/Convert.lean` - Color space conversion
- `Tincture/Named.lean` - Named colors
- `Tincture/Gradient.lean` / `Palette.lean` - Gradients and palettes
- `Tincture/Space/` - Additional color spaces
- `Tincture/Adjust.lean` / `Blend.lean` - Color operations

### chroma
Color picker application:
- `Chroma/Main.lean` - App entry point and UI wiring
- Uses `afferent`, `arbor`, `trellis`, and `tincture`

### collimator
Profunctor optics encoded as polymorphic functions:
- `Collimator/Core/` - Profunctor, Strong, Choice, Wandering typeclasses
- `Collimator/Concrete/` - Forget, Star, Tagged, FunArrow profunctors
- `Collimator/Optics/` - Iso, Lens, Prism, Traversal, AffineTraversal
- `Collimator/Poly/` - HasView, HasOver, HasPreview unified API

### legate
gRPC transport layer (bring your own serialization):
- `Legate/Channel.lean` - Client connections (insecure, TLS, mTLS)
- `Legate/Call.lean` - Unary RPC
- `Legate/Stream.lean` - Client/server/bidi streaming
- `Legate/Server.lean` - Server-side API
- `ffi/src/legate_ffi.cpp` - C++ gRPC wrapper with C ABI

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

## Lean Version

All projects target Lean 4.25.x or 4.26.x (check individual `lean-toolchain` files).

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
- `lake test` - Standard test driver (terminus, protolean, legate, wisp, enchiridion, ledger, arbor, trellis, tincture)
- `./test.sh` - Custom test script (afferent)
- `./build.sh chroma_tests && .lake/build/bin/chroma_tests` - Direct executable (chroma)
- `.lake/build/bin/collimator_tests` - Direct executable (collimator)

Projects using the **Crucible** test framework: afferent, arbor, chroma, collimator, trellis, tincture, wisp
Projects without a test target: canopy, cellar

## Workspace Scripts

Helper scripts for managing multiple git repositories:

```bash
./scripts/git-status.sh         # Check which projects have changes
./scripts/git-status.sh -v      # Verbose mode with change details
./scripts/git-commit-all.sh "message"   # Commit staged changes in all repos
./scripts/git-push-all.sh       # Push all repos with unpushed commits
./scripts/git-add-commit-push.sh "message"  # Stage, commit, and push all
```
