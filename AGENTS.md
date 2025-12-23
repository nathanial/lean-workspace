# Repository Guidelines

## Overview
This workspace contains fifteen independent Lean 4 projects: `afferent`, `arbor`, `canopy`, `cellar`, `chroma`, `collimator`, `crucible`, `enchiridion`, `ledger`, `legate`, `protolean`, `terminus`, `tincture`, `trellis`, and `wisp`. Each project is built and tested from its own directory, and most architectural details live in the per-project `README.md` plus the top-level `CLAUDE.md`.

## Project Structure & Module Organization
- Project roots: `afferent/`, `arbor/`, `canopy/`, `cellar/`, `chroma/`, `collimator/`, `crucible/`, `enchiridion/`, `ledger/`, `legate/`, `protolean/`, `terminus/`, `tincture/`, `trellis/`, `wisp/`.
- Lean sources live in project-named folders (e.g., `Terminus/`, `Afferent/`, `Arbor/`, `Trellis/`, `Tincture/`) with entry points in `*.lean` at the repo root (e.g., `Terminus.lean`).
- Tests are project-local (`Tests/`, `Tests.lean`, `CollimatorTests/`, `AfferentTests.lean`, `ArborTests/`, `TrellisTests/`, `TinctureTests/`, `ChromaTests/`).
- FFI and native code: `ffi/` or `native/` (keep wrappers small and focused).
- Assets and demos: `assets/`, `examples/`, `Demos/`, `testapp/`.
- Vendored dependencies: `third_party/` (avoid editing unless updating a vendored drop).

## Build, Test, and Development Commands
Run commands from the project directory:
- `terminus`: `lake build`, `lake exe hello`, `lake test`.
- `afferent`: `./build.sh` (required), `./run.sh`, `./test.sh`.
- `arbor`: `lake build`, `lake test`, `lake build ascii_demo`.
- `canopy`: `lake build`.
- `cellar`: `lake build`.
- `chroma`: `./build.sh` (required), `./run.sh`, `./build.sh chroma_tests && .lake/build/bin/chroma_tests`.
- `collimator`: `lake build`, `lake build collimator_tests && .lake/build/bin/collimator_tests`.
- `crucible`: `lake build`.
- `enchiridion`: `lake build`, `lake exe enchiridion`, `lake test`.
- `ledger`: `lake build`, `lake test`.
- `legate`: `lake run buildFfi` (first-time), `lake build`, `lake test`, `./run-tests.sh` (full suite + Go integration).
- `protolean`: `lake build`, `lake test`.
- `tincture`: `lake build`, `lake test`.
- `trellis`: `lake build`, `lake test`.
- `wisp`: `lake build`, `lake test`.
After any change, build and run tests. Note that `lake build` only builds the default target; if you touched a non-default executable/library (e.g., `kitchensink`), run a specific build like `lake build kitchensink` (or the appropriate target).

## Coding Style & Naming Conventions
- Lean: follow existing file layout and `namespace` naming (PascalCase modules under project directories). Indent with two spaces and keep definitions grouped by module.
- Prefer descriptive module/file names that mirror the namespace, e.g., `Legate/Stream.lean`.
- Keep C/C++ FFI files in `ffi/` or `native/`; use `lean_*` exports and minimal allocation glue consistent with nearby code.

## Testing Guidelines
- Keep tests alongside their project and name modules with `Tests`/`*Tests` conventions.
- Run targeted `lake test` before cross-project changes; use `./run-tests.sh` in `legate` when touching gRPC/FFI.
- Always run `lake test` when the project supports it; call out if no tests exist or a test command is unavailable (e.g., `cellar` and `canopy` have no test target, `chroma` uses the `chroma_tests` executable).

## Commit & Pull Request Guidelines
- Commit messages are short, lowercase, and imperative (examples in history: “fix the tiles”, “upgrade to v4.26.0”). No ticket prefixes observed.
- PRs should include: a clear summary, tests run, and screenshots or recordings for UI/graphics changes (`terminus`, `afferent`). Link related issues when applicable.

## Toolchain & Configuration Notes
- Each project pins its own `lean-toolchain` (Lean 4.25/4.26). Run `lake` per project directory to avoid version mismatches.
- `afferent` and `chroma` require `./build.sh` to set the macOS toolchain correctly.


ALWAYS VERIFY THAT THE CODE COMPILES!!