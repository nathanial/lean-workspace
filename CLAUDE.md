# CLAUDE.md

Lean 4 workspace with 66 interconnected projects.

## Project Categories

| Category | Projects |
|----------|----------|
| **Graphics** | terminus (TUI), afferent (Metal GPU, includes Arbor/Canopy), afferent-demos (demo runner), trellis (CSS layout), tincture (color), chroma (color picker), assimptor (3D models), worldmap (maps), vane (terminal emulator), raster (images), grove (file browser) |
| **Web** | loom (framework), citadel (HTTP server), herald (HTTP parser), scribe (HTML builder), markup (HTML parser), chronicle (logging), stencil (templates) |
| **Network** | wisp (HTTP client), legate (gRPC), protolean (protobuf), oracle (OpenRouter), jack (sockets), exchange (P2P chat) |
| **Data** | ledger (fact DB), quarry (SQLite), chisel (SQL DSL), cellar (disk cache), collimator (optics), convergent (CRDTs), reactive (FRP), tabular (CSV), entity (ECS), totem (TOML), tileset (map tiles), galaxy-gen (planned) |
| **Apps** | homebase-app, todo-app, enchiridion, lighthouse, blockfall, twenty48, ask, cairn, minefield, solitaire, tracker (issue tracking), timekeeper (time tracking TUI), eschaton (grand strategy), chatline (chat app), astrometry (planned) |
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

**Note:** `lake build` only builds the default lakefile target, which may not include specific executables. To run an executable, either use the `./run.sh` script in a project folder or call `lake exe <appname>` directly.

**Projects requiring ./build.sh** (sets LEAN_CC or downloads dependencies):
- afferent, afferent-demos, chroma, assimptor, worldmap, vane, grove, cairn, eschaton (Metal/macOS)
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
terminus apps (blockfall, twenty48, minefield, lighthouse, enchiridion, tracker, timekeeper) → terminus
eschaton → afferent
exchange → jack
tileset → cellar, wisp, reactive
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

## Workspace Repository

**Never modify the workspace-level git repository.** This includes:
- Do not commit to the workspace root
- Do not add/modify files at the workspace level

All work should be done within individual project submodules (e.g., `util/parlance/`, `graphics/terminus/`). Commit, push, and tag within those project directories only.

## Versioning

All dependencies use GitHub URLs with semantic version tags:

```lean
require crucible from git "https://github.com/nathanial/crucible" @ "v0.0.1"
```

**Never use local path imports.** All deps must use GitHub URLs.

### Dependency Tiers (release in order)

| Tier | Projects |
|------|----------|
| 0 | crucible, staple, cellar, assimptor, raster, jack |
| 1 | herald, trellis, collimator, protolean, scribe, chronicle, terminus, fugue, linalg, chronos, measures, rune, sift, tincture, wisp, chisel, ledger, quarry, convergent, reactive, tabular, entity, totem, conduit, tracer, smalltalk, exchange |
| 2 | citadel, legate, oracle, parlance, blockfall, twenty48, minefield, solitaire, stencil, tileset |
| 3 | loom, afferent, ask, lighthouse, enchiridion, docgen, tracker, chatline |
| 4 | todo-app, homebase-app, chroma, vane, worldmap, grove, cairn, afferent-demos, timekeeper, eschaton |

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


<!-- br-agent-instructions-v1 -->

---

## Beads Workflow Integration

This project uses [beads_rust](https://github.com/Dicklesworthstone/beads_rust) (`br`/`bd`) for issue tracking. Issues are stored in `.beads/` and tracked in git.

### Essential Commands

```bash
# View ready issues (unblocked, not deferred)
br ready              # or: bd ready

# List and search
br list --status=open # All open issues
br show <id>          # Full issue details with dependencies
br search "keyword"   # Full-text search

# Create and update
br create --title="..." --description="..." --type=task --priority=2
br update <id> --status=in_progress
br close <id> --reason="Completed"
br close <id1> <id2>  # Close multiple issues at once

# Sync with git
br sync --flush-only  # Export DB to JSONL
br sync --status      # Check sync status
```

### Workflow Pattern

1. **Start**: Run `br ready` to find actionable work
2. **Claim**: Use `br update <id> --status=in_progress`
3. **Work**: Implement the task
4. **Complete**: Use `br close <id>`
5. **Sync**: Always run `br sync --flush-only` at session end

### Key Concepts

- **Dependencies**: Issues can block other issues. `br ready` shows only unblocked work.
- **Priority**: P0=critical, P1=high, P2=medium, P3=low, P4=backlog (use numbers 0-4, not words)
- **Types**: task, bug, feature, epic, chore, docs, question
- **Blocking**: `br dep add <issue> <depends-on>` to add dependencies

### Session Protocol

**Before ending any session, run this checklist:**

```bash
git status              # Check what changed
git add <files>         # Stage code changes
br sync --flush-only    # Export beads changes to JSONL
git commit -m "..."     # Commit everything
git push                # Push to remote
```

### Best Practices

- Check `br ready` at session start to find available work
- Update status as you work (in_progress → closed)
- Create new issues with `br create` when you discover tasks
- Use descriptive titles and set appropriate priority/type
- Always sync before ending session