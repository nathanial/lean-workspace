# Repository Guidelines

Lean 4 workspace with 57 projects. See `CLAUDE.md` for full project list and dependency graph.

## Directory Layout

```
<category>/<project>/
  ├── <Project>/        # Lean sources (PascalCase)
  ├── <Project>.lean    # Entry point
  ├── Tests/            # Tests (or Tests.lean, *Tests/)
  ├── ffi/ or native/   # C/C++ FFI code
  └── lakefile.lean
```

Categories: `graphics/`, `web/`, `network/`, `data/`, `apps/`, `util/`, `math/`, `audio/`, `testing/`

## Build & Test

**Default:** `lake build && lake test`

**Requires ./build.sh:** afferent, cairn, chroma, grove, vane, worldmap (Metal), quarry, raster (vendored deps), fugue (AudioToolbox), assimptor (Assimp)

**legate:** Run `lake run buildFfi` first (builds gRPC)

**Web apps:** `.lake/build/bin/homebaseApp` or `todoApp` (port 3000)

## Coding Style

- PascalCase modules matching namespace (e.g., `Legate/Stream.lean`)
- 2-space indent
- Keep FFI wrappers minimal in `ffi/` or `native/`

## Commits

Short, lowercase, imperative: "fix tile rendering", "add streaming support"

## Important

All work should be done within individual project submodules (e.g., `util/parlance/`, `graphics/terminus/`). Commit, push, and tag within those project directories only.

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

<!-- end-br-agent-instructions -->
