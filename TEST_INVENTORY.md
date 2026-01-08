# TEST_INVENTORY.md - Lean 4 Workspace Test Coverage

## Summary Statistics

| Metric | Value |
|--------|-------|
| **Total Projects** | 57 |
| **Projects with Tests** | 51 (89.5%) |
| **Projects without Tests** | 6 (10.5%) |
| **Testing Framework** | Crucible (all test-enabled projects) |

---

## Projects With Tests (51)

### Graphics (9/11)

| Project | Test Configuration | Notes |
|---------|-------------------|-------|
| terminus | lean_lib Tests, test_driver | TUI framework tests |
| afferent | lean_exe afferent_tests, test_driver | Metal GPU graphics, FFI tests |
| afferent-demos | lean_lib AfferentDemosTests, test_driver | Demo tests |
| tincture | lean_lib TinctureTests, test_driver | Color utilities |
| trellis | lean_lib TrellisTests, test_driver | CSS layout engine |
| raster | lean_lib Tests, test_driver | Image processing, STB FFI |
| vane | lean_lib VaneTests, test_driver | Terminal emulator, PTY FFI |
| worldmap | lean_lib Tests, test_driver | Tile-based map viewer |
| cairn | lean_lib Tests, test_driver | Voxel game |

### Web (7/7)

| Project | Test Configuration | Notes |
|---------|-------------------|-------|
| herald | lean_lib Tests, test_driver | HTTP parser |
| scribe | lean_lib Tests, test_driver | HTML builder |
| citadel | lean_lib Tests, test_driver | HTTP server, OpenSSL FFI |
| loom | lean_lib Tests, test_driver | Web framework |
| markup | lean_lib Tests, test_driver | HTML parser |
| chronicle | lean_lib Tests, test_driver | Logging library |
| stencil | lean_lib Tests + Bench, test_driver | Template engine with benchmarks |

### Network (4/4)

| Project | Test Configuration | Notes |
|---------|-------------------|-------|
| wisp | lean_lib WispTests, test_driver | HTTP client, libcurl FFI |
| legate | lean_lib Tests + IntegrationTests, test_driver | gRPC client, 2 test suites |
| oracle | lean_lib Tests, test_driver | OpenRouter API client |
| protolean | lean_lib Tests, test_driver | Protocol buffers |

### Data (9/10)

| Project | Test Configuration | Notes |
|---------|-------------------|-------|
| ledger | lean_lib Tests, test_driver | Fact database |
| quarry | lean_lib Tests, test_driver | SQLite, C FFI |
| chisel | lean_lib Tests, test_driver | SQL DSL |
| collimator | lean_lib CollimatorTests, test_driver | Optics library, mathlib dep |
| convergent | lean_lib ConvergentTests, test_driver | CRDTs, property tests |
| entity | lean_lib EntityTests, test_driver | ECS library |
| reactive | lean_lib ReactiveTests, test_driver | FRP library, property tests |
| tabular | lean_lib Tests, test_driver | CSV parser |
| totem | lean_lib Tests, test_driver | TOML parser |

### Apps (10/11)

| Project | Test Configuration | Notes |
|---------|-------------------|-------|
| homebase-app | lean_lib Tests, test_driver | Personal dashboard |
| todo-app | lean_lib Tests, test_driver | Loom web app |
| lighthouse | lean_lib Tests, test_driver | TUI app with ledger |
| enchiridion | lean_lib Tests, test_driver | TUI app, oracle integration |
| blockfall | lean_lib Tests, test_driver | Terminus game |
| twenty48 | lean_lib Tests, test_driver | Terminus game (2048) |
| minefield | lean_lib Tests, test_driver | Terminus game (Minesweeper) |
| solitaire | lean_lib Tests, test_driver | Terminus game |
| tracker | lean_exe tests, test_driver | Issue tracking CLI |

### Util (11/13)

| Project | Test Configuration | Notes |
|---------|-------------------|-------|
| staple | lean_lib Tests, test_driver | Macros/utilities |
| parlance | lean_lib Tests, test_driver | CLI argument parser |
| chronos | lean_lib Tests, test_driver | Time library, POSIX FFI |
| rune | lean_lib RuneTests, test_driver | Regex library |
| sift | lean_lib SiftTests, test_driver | Parser combinators |
| conduit | lean_lib ConduitTests, test_driver | Go-style channels, pthread FFI |
| crypt | lean_lib Tests, test_driver | Cryptography, libsodium FFI |
| smalltalk | lean_lib Tests, test_driver | Smalltalk interpreter |
| docgen | lean_lib Tests, test_driver | Documentation generator |
| tracer | lean_lib Tests, test_driver | Distributed tracing |

### Math (2/2)

| Project | Test Configuration | Notes |
|---------|-------------------|-------|
| linalg | lean_lib LinalgTests, test_driver | Vectors/matrices |
| measures | lean_lib MeasuresTests, test_driver | Units and measurements |

### Audio (1/1)

| Project | Test Configuration | Notes |
|---------|-------------------|-------|
| fugue | lean_lib FugueTests, test_driver | Audio synthesis, AudioToolbox FFI |

### Testing (1/1)

| Project | Test Configuration | Notes |
|---------|-------------------|-------|
| crucible | lean_lib Tests, test_driver | Self-hosted (tests itself) |

---

## Projects Without Tests (6)

| Project | Category | Reason |
|---------|----------|--------|
| ask | Apps | CLI tool, no test_driver configured |
| assimptor | Util | 3D model loader wrapper, no test config |
| cellar | Data | Disk cache, no test config |
| chroma | Graphics | Color picker app, has crucible dep but no test_driver |
| grove | Graphics | File browser app, has crucible dep but no test_driver |
| timeout | Util | Incomplete project (no lakefile) |

---

## Testing Framework: Crucible

All 51 test-enabled projects use **Crucible**, a custom Lean 4 test framework developed in this workspace.

### Features

- **Type-safe assertions**: `result ≡ expected`, `shouldSatisfy`, `shouldContain`
- **DSL syntax**: `test "description" := do ...` and `testSuite "name"`
- **Test macros**: `#generate_tests` for automatic test discovery
- **Lake integration**: `@[test_driver]` attribute for seamless `lake test`

### Sample Usage

```lean
import Crucible

testSuite "Math Operations"

test "addition works" := do
  (2 + 3) ≡ 5

test "list contains" := do
  shouldContain [1, 2, 3] 2

#generate_tests
```

---

## Test Coverage by Tier

| Tier | Projects | With Tests | Coverage |
|------|----------|------------|----------|
| 0 | crucible, staple, cellar, assimptor, raster | 3/5 | 60% |
| 1 | herald, trellis, collimator, protolean, scribe, chronicle, terminus, fugue, linalg, chronos, measures, rune, sift, tincture, wisp, chisel, ledger, quarry, convergent, reactive, tabular, entity, totem, conduit, tracer, smalltalk | 26/26 | 100% |
| 2 | citadel, legate, oracle, parlance, blockfall, twenty48, minefield, solitaire, stencil | 9/9 | 100% |
| 3 | loom, afferent, ask, lighthouse, enchiridion, docgen, tracker | 6/7 | 86% |
| 4 | todo-app, homebase-app, chroma, vane, worldmap, grove, cairn, afferent-demos | 6/8 | 75% |

**Foundation libraries (Tier 0-1) have excellent coverage; app-layer projects (Tier 3-4) have some gaps.**

---

## Projects with Complex FFI + Tests

These projects have significant FFI and maintain test coverage:

| Project | FFI Type |
|---------|----------|
| citadel | OpenSSL socket FFI |
| quarry | SQLite C FFI |
| wisp | libcurl FFI |
| legate | gRPC + CMake build |
| conduit | pthread FFI |
| crypt | libsodium FFI |
| chronos | POSIX time FFI |
| afferent | Metal GPU + Objective-C |

---

## Projects with Property Testing

These projects use **plausible** for property-based testing:

- convergent (CRDTs)
- reactive (FRP)
- tincture (color utilities)

---

## Running Tests

### Standard Pattern

```bash
cd <category>/<project>
lake test
```

### Projects Requiring Special Build

| Project | Command |
|---------|---------|
| afferent, grove, vane, worldmap, cairn, chroma | `./build.sh` (sets LEAN_CC) |
| legate | `lake run buildFfi` first (CMake for gRPC) |
| quarry, raster | Downloads vendored deps automatically |

---

## Recommendations

1. **Enable tests for remaining 6 projects:**
   - `cellar`: Add basic cache operation tests
   - `assimptor`: Add 3D model loading tests
   - `chroma`, `grove`: Complete app-layer tests (crucible dep already exists)
   - `ask`: Add CLI integration tests
   - `timeout`: Complete project structure

2. **Expand property testing:** Consider adding plausible-based tests to more data libraries

3. **Integration test pattern:** Legate has exemplary split (unit + integration tests); consider for citadel/loom

4. **Tier 0 coverage:** cellar and assimptor are foundation libraries without tests - prioritize these
