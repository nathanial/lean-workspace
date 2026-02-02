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

**Always run:** `lake test`

**afferent-demos tests:** use `./test.sh` (do not use `lake test`).

**Always verify compile after code changes:** run the project-appropriate build (e.g., `./build.sh` for listed Metal/FFI projects).

**Requires ./build.sh:** afferent, cairn, chroma, grove, vane, worldmap (Metal), quarry, raster (vendored deps), fugue (AudioToolbox), assimptor (Assimp)

**legate:** Run `lake run buildFfi` first (builds gRPC)

**Web apps:** `.lake/build/bin/homebaseApp` or `todoApp` (port 3000)

## Coding Style

- PascalCase modules matching namespace (e.g., `Legate/Stream.lean`)
- 2-space indent
- Keep FFI wrappers minimal in `ffi/` or `native/`

## Commits

Short, lowercase, imperative: "fix tile rendering", "add streaming support"

## Issue Tracking (tracker)

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

Issues are stored as markdown files in `.issues/` at the workspace root. **Do not commit .issues/ changes** - the workspace-level repo is managed separately.

## Important

All work should be done within individual project submodules (e.g., `util/parlance/`, `graphics/terminus/`). Commit, push, and tag within those project directories only.
