# Lean Workspace

A collection of Lean 4 libraries for building applications with terminal UIs, graphics, networking, and data management.

## Projects

| Project | Description | Links |
|---------|-------------|-------|
| [afferent](afferent/) | 2D/3D graphics and UI framework with Metal GPU rendering (macOS) | |
| [arbor](arbor/) | Renderer-agnostic widget library that emits render commands | |
| [canopy](canopy/) | Desktop widget framework built on top of Arbor | |
| [cellar](cellar/) | Generic disk cache library with LRU eviction | |
| [chroma](chroma/) | Color picker application built on afferent/arbor | |
| [collimator](collimator/) | Profunctor optics library (lenses, prisms, traversals) | |
| [crucible](crucible/) | Lightweight test framework with declarative test macros | |
| [enchiridion](enchiridion/) | Terminal novel writing assistant with AI integration | |
| [ledger](ledger/) | Datomic-like fact-based database with time-travel queries | |
| [legate](legate/) | Generic gRPC library with all streaming modes | |
| [protolean](protolean/) | Protocol Buffers implementation with compile-time `proto_import` | |
| [terminus](terminus/) | Terminal UI library (ratatui-style) with widgets, layouts, and styling | |
| [tincture](tincture/) | Color library with RGBA/HSV support and color operations | |
| [trellis](trellis/) | Pure CSS layout computation (Flexbox and Grid) | |
| [wisp](wisp/) | HTTP client library with libcurl FFI bindings | |

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
            └──► wisp           (HTTP client)
collimator ─────► crucible      (test framework)
trellis ─────────► crucible     (test framework)
tincture ────────► crucible     (test framework)
wisp ───────────► crucible      (test framework)
```

## Quick Start

Each project is built independently from its directory:

```bash
cd <project>
lake build
lake test  # if available
```

Some projects require custom scripts (notably `afferent` and `chroma` use `./build.sh` to set the macOS toolchain). See individual project READMEs for specific build instructions.

## Workspace Scripts

Helper scripts for managing multiple git repositories:

```bash
# Check which projects have uncommitted changes
./scripts/git-status.sh
./scripts/git-status.sh -v  # verbose

# Commit and push all projects at once
./scripts/git-add-commit-push.sh "Your commit message"

# Or step by step:
./scripts/git-commit-all.sh "message"  # commit staged changes
./scripts/git-push-all.sh              # push all
```

## Requirements

- Lean 4.25.x or 4.26.x (check individual `lean-toolchain` files)
- Platform-specific dependencies vary by project (see individual READMEs)

## License

All projects are MIT licensed. See individual LICENSE files.
