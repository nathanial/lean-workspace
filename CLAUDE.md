# CLAUDE.md

Lean 4 workspace with 53 interconnected projects.

## Project Categories

| Category | Projects |
|----------|----------|
| **Graphics** | terminus (TUI), afferent (Metal GPU), arbor (widgets), canopy (desktop), trellis (CSS layout), tincture (color), chroma (color picker), assimptor (3D models), worldmap (maps), vane (terminal emulator), raster (images), grove (file browser) |
| **Web** | loom (framework), citadel (HTTP server), herald (HTTP parser), scribe (HTML builder), markup (HTML parser), chronicle (logging) |
| **Network** | wisp (HTTP client), legate (gRPC), protolean (protobuf), oracle (OpenRouter) |
| **Data** | ledger (fact DB), quarry (SQLite), chisel (SQL DSL), cellar (disk cache), collimator (optics), convergent (CRDTs), reactive (FRP), tabular (CSV), entity (ECS), totem (TOML) |
| **Apps** | homebase-app, todo-app, enchiridion, lighthouse, blockfall, twenty48, ask, cairn, minefield |
| **Util** | parlance (CLI), staple (macros), chronos (time), rune (regex), conduit (channels), docgen, tracer |
| **Math** | linalg (vectors/matrices), measures (units) |
| **Audio** | fugue (synthesis) |
| **Testing** | crucible (test framework) |

## Directory Structure

```
graphics/   math/   web/   network/   audio/   data/   apps/   util/   testing/
```

## Build Commands

**Default:** `cd <category>/<project> && lake build && lake test`

**Projects requiring ./build.sh** (sets LEAN_CC or downloads dependencies):
- afferent, chroma, assimptor, worldmap, vane, grove, cairn (Metal/macOS)
- quarry, raster (downloads vendored deps)
- fugue (AudioToolbox FFI)
- legate (builds gRPC: `lake run buildFfi` first)

## Key Dependencies

```
loom → citadel → herald, scribe, ledger
afferent → collimator, wisp, cellar, trellis, arbor, tincture, assimptor
arbor → trellis, tincture
legate → protolean
oracle → wisp
terminus apps (blockfall, twenty48, minefield, lighthouse, enchiridion) → terminus
```

External: collimator → mathlib, ledger → batteries, chroma/tincture → plausible

## FFI Patterns

```lean
-- Opaque handle
opaque WindowPointed : NonemptyType
def Window : Type := WindowPointed.type
@[extern "lean_window_create"]
opaque Window.create : UInt32 → UInt32 → String → IO Window
```

```c
// External class registration
static lean_external_class* g_class = NULL;
g_class = lean_register_external_class(finalizer, NULL);
lean_alloc_external(g_class, native_ptr);

// Returning tuples (Float × Float)
lean_object* pair = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(pair, 0, lean_box_float(v1));
lean_ctor_set(pair, 1, lean_box_float(v2));
```

## Workspace Commands

```bash
just status          # Git status across submodules
just build <proj>    # Build one project
just build-all       # Build all
just test <proj>     # Test one project
just test-all        # Test all
just lines           # Count Lean LOC
```

## Versioning

All dependencies use GitHub URLs with semantic version tags:

```lean
require crucible from git "https://github.com/nathanial/crucible" @ "v0.0.1"
```

**Never use local path imports.** All deps must use GitHub URLs.

### Dependency Tiers (release in order)

| Tier | Projects |
|------|----------|
| 0 | crucible, staple, cellar, assimptor, raster |
| 1 | herald, trellis, collimator, protolean, scribe, chronicle, terminus, fugue, linalg, chronos, measures, rune, tincture, wisp, chisel, ledger, quarry, convergent, reactive, tabular, entity, totem, conduit, tracer |
| 2 | citadel, legate, oracle, parlance, arbor, blockfall, twenty48, minefield |
| 3 | loom, afferent, canopy, ask, lighthouse, enchiridion, docgen |
| 4 | todo-app, homebase-app, chroma, vane, worldmap, grove, cairn |

### Release Process

```bash
cd <project>
lake build && lake test
git add -A && git commit -m "Description"
git push origin master
git tag v0.0.2 && git push origin v0.0.2
# Then update downstream lakefiles and repeat
```

### Local Development

```bash
./scripts/generate-local-overrides.sh  # Use local deps
./scripts/remove-local-overrides.sh    # Back to GitHub refs
```

Note: `chronos` → `nathanial/chronos-lean` on GitHub (all others match directory name).
