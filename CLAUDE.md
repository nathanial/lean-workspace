# CLAUDE.md

Lean 4 workspace with 57 interconnected projects.

## Project Categories

| Category | Projects |
|----------|----------|
| **Graphics** | terminus (TUI), afferent (Metal GPU, includes Arbor/Canopy), afferent-demos (demo runner), trellis (CSS layout), tincture (color), chroma (color picker), assimptor (3D models), worldmap (maps), vane (terminal emulator), raster (images), grove (file browser) |
| **Web** | loom (framework), citadel (HTTP server), herald (HTTP parser), scribe (HTML builder), markup (HTML parser), chronicle (logging), stencil (templates) |
| **Network** | wisp (HTTP client), legate (gRPC), protolean (protobuf), oracle (OpenRouter) |
| **Data** | ledger (fact DB), quarry (SQLite), chisel (SQL DSL), cellar (disk cache), collimator (optics), convergent (CRDTs), reactive (FRP), tabular (CSV), entity (ECS), totem (TOML) |
| **Apps** | homebase-app, todo-app, enchiridion, lighthouse, blockfall, twenty48, ask, cairn, minefield, solitaire, tracker (issue tracking) |
| **Util** | parlance (CLI), staple (macros), chronos (time), rune (regex), sift (parser combinators), conduit (channels), docgen, tracer, crypt (crypto), timeout, smalltalk (interpreter) |
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
- afferent, afferent-demos, chroma, assimptor, worldmap, vane, grove, cairn (Metal/macOS)
- quarry, raster (downloads vendored deps)
- fugue (AudioToolbox FFI)
- legate (builds gRPC: `lake run buildFfi` first)

## Key Dependencies

```
loom → citadel → herald, scribe, ledger
afferent → collimator, wisp, cellar, trellis, tincture, assimptor (bundles Afferent.Arbor/Canopy)
afferent-demos → afferent
afferent.Arbor → trellis, tincture
legate → protolean
oracle → wisp
terminus apps (blockfall, twenty48, minefield, lighthouse, enchiridion, tracker) → terminus
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

## Issue Tracking with Tracker

Use `tracker` CLI to manage issues. Outputs text by default (use `-j` for JSON).

**Setup:** Run `tracker init` in any project to create `.issues/` directory.

**Commands for Claude Code:**
```bash
tracker list                              # List open issues
tracker list --project=parlance           # List issues for a specific project
tracker list -p tracker --all             # Include closed issues
tracker show <id>                         # Get issue details
tracker add "Title" --priority=high       # Create issue
tracker add "Title" --project=tracker     # Create issue with project
tracker progress <id> "Found root cause"  # Log progress
tracker close <id> "Fixed in commit X"    # Close issue
tracker update <id> --status=in-progress  # Update status
```

**Issue Fields:**
- `--priority` / `-p`: low, medium, high, critical (default: medium)
- `--project` / `-P`: Project name this issue belongs to (optional)
- `--label` / `-l`: Add a label
- `--assignee` / `-a`: Assign to someone
- `--description` / `-d`: Issue description

**Workflow:**
1. Check `tracker list` to see current issues
2. Use `tracker update <id> --status=in-progress` when starting work
3. Log progress with `tracker progress <id> "message"` as you work
4. Close with `tracker close <id> "summary"` when done

**Status values:** open, in-progress, closed

Issues are stored as markdown files in `.issues/` - commit them with your code changes.

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
| 1 | herald, trellis, collimator, protolean, scribe, chronicle, terminus, fugue, linalg, chronos, measures, rune, sift, tincture, wisp, chisel, ledger, quarry, convergent, reactive, tabular, entity, totem, conduit, tracer, smalltalk |
| 2 | citadel, legate, oracle, parlance, blockfall, twenty48, minefield, solitaire, stencil |
| 3 | loom, afferent, ask, lighthouse, enchiridion, docgen, tracker |
| 4 | todo-app, homebase-app, chroma, vane, worldmap, grove, cairn, afferent-demos |

### Release Process

```bash
cd <project>
lake build && lake test
git add -A && git commit -m "Description"
git push origin master
git tag v0.0.2 && git push origin v0.0.2
# Then update downstream lakefiles and repeat
```

Note: `chronos` → `nathanial/chronos-lean` on GitHub (all others match directory name).
