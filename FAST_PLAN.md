# FAST_PLAN: Afferent CPU-Side Rendering Optimization

Date: 2026-02-11
Scope: `graphics/afferent` and `graphics/afferent-demos` benchmark verification

## Goal
Reduce CPU frame time for large widget trees by eliminating avoidable allocation churn and `O(n^2)` append patterns in the render/collect/event pipeline.

## Baseline (Current)
Collected from:
- `just test-project graphics/afferent-demos`

### WidgetPerf Bench (baseline/no-hover)
| Scenario | Widgets | Total (ms) | Collect (ms) | Measure (ms) | Update (ms) |
|---|---:|---:|---:|---:|---:|
| switch | 6213 | 15.8 | 13.2 | 1.6 | 0.9 |
| dropdown | 10213 | 28.2 | 21.9 | 5.0 | 1.2 |
| stepper | 16213 | 49.1 | 40.8 | 6.8 | 1.4 |

### WidgetTree Stress
| Scenario | Widgets | Total (ms) | Collect (ms) | Measure (ms) | Update (ms) |
|---|---:|---:|---:|---:|---:|
| static deep tree | 3964 | 13.3 | 10.8 | 2.0 | 0.5 |
| dynamic subtree swap | 1580 | 35.2 | 3.9 | 0.9 | 30.4 |
| fanout dynWidget | 912 | 8.5 | 1.6 | 0.5 | 6.3 |

## Confirmed Hotspots

### High-confidence `O(n^2)` append/copy patterns
1. Instanced merge logic (nested rebuild + array append)
- `graphics/afferent/src/Afferent/Draw/Optimize/Coalesce.lean:496`
- `graphics/afferent/src/Afferent/Draw/Optimize/Coalesce.lean:536`

2. Text transform packing with repeated append
- `graphics/afferent/src/Afferent/Output/Execute/Batches.lean:286`

3. Fragment parameter accumulation with repeated append
- `graphics/afferent/src/Afferent/Output/Execute/Batched.lean:408`

### High allocation churn (not strictly `O(n^2)`)
4. Hit-test path copying per index item
- `graphics/afferent/src/Afferent/UI/Arbor/Event/HitTest.lean:145`
- `graphics/afferent/src/Afferent/UI/Arbor/Event/HitTest.lean:166`

5. Hit-index rebuild per event in non-reactive dispatch path
- `graphics/afferent/src/Afferent/UI/Arbor/App/UI.lean:148`

6. Repeated subtree materialization (`mapM id`) in reactive combinators
- `graphics/afferent/src/Afferent/UI/Canopy/Reactive/Component.lean:562`
- `graphics/afferent/src/Afferent/UI/Canopy/Reactive/Component.lean:840`

## Phased Implementation Plan

## Phase 1: Remove Known `O(n^2)` Appends in Active Draw Path
### Changes
- Rewrite instanced polygon/arc merge to single-pass grouping (no nested group rebuild arrays).
- Replace `acc ++ e.transform` text packing with preallocated/push-based assembly.
- Replace `fragmentParamsBatch ++ params` with push-based append into existing batch buffer.

### Primary files
- `graphics/afferent/src/Afferent/Draw/Optimize/Coalesce.lean`
- `graphics/afferent/src/Afferent/Output/Execute/Batches.lean`
- `graphics/afferent/src/Afferent/Output/Execute/Batched.lean`

### Expected improvement after Phase 1
- Collect-heavy scenarios: **15% to 30% collect-time reduction**.
- Projected examples:
  - switch collect: `13.2 -> 9.2 to 11.2 ms`
  - dropdown collect: `21.9 -> 15.3 to 18.6 ms`
  - stepper collect: `40.8 -> 28.6 to 34.7 ms`
- End-to-end total improvement in large static trees: **10% to 25%**.

### Validation gate
- Re-run `just test-project graphics/afferent-demos`.
- Accept phase if stepper `collect` drops by at least **15%** and no regressions in pass/fail.

## Phase 2: Event/Hit-Test Allocation Reduction
### Changes
- Stop rebuilding hit index per event in generic dispatch path; pass a frame-cached hit index when available.
- Reduce path-copying in hit-test index build (store parent link/index and reconstruct only for winning hit, or similar compact representation).

### Primary files
- `graphics/afferent/src/Afferent/UI/Arbor/App/UI.lean`
- `graphics/afferent/src/Afferent/UI/Arbor/Event/HitTest.lean`
- (possibly) runner wiring files that already cache per-frame layout/index

### Expected improvement after Phase 2
- Hover/click-heavy frames: **20% to 45% lower event-path cost**.
- Projected hover-overhead reductions:
  - stepper hover cost component: `~5.0 ms -> ~2.8 to 4.0 ms`
  - dropdown hover cost component: `~2.6 ms -> ~1.5 to 2.1 ms`
- Modest total-frame gain in interactive scenarios: **5% to 15%**.

### Validation gate
- Re-run same benchmark suite.
- Compare hover-vs-baseline delta lines; require at least **20% reduction** in hover overhead for stepper case.

## Phase 3: Reactive Subtree Materialization Churn
### Changes
- Reduce repeated `mapM id` materialization in container combinators and dynamic subtree render wrappers.
- Introduce lightweight helper(s) to avoid rebuilding equivalent columns when child render arrays are unchanged.
- Keep behavior identical (same tree semantics, same event routing).

### Primary files
- `graphics/afferent/src/Afferent/UI/Canopy/Reactive/Component.lean`
- Additional Canopy widget combinator files where repeated `mapM id` appears.

### Expected improvement after Phase 3
- Dynamic-heavy tests (especially `dynamic subtree swap`): **10% to 30% update-time reduction**.
- Projected examples:
  - dynamic subtree swap update: `30.4 -> 21.0 to 27.4 ms`
  - fanout dynWidget update: `6.3 -> 4.7 to 5.7 ms`
- Total gain in dynamic tests: **8% to 25%**.

### Validation gate
- Re-run benchmark suite.
- Require dynamic subtree swap `update` reduction of at least **10%**.

## Phase 4: Cache-Touch and Secondary Churn Cleanup
### Changes
- Audit and tune LRU `touch` frequency on hot hit paths (keep correctness, reduce unnecessary writes).
- Remove any remaining frequent `++` in hot loops discovered during profiling.
- Optional: tighten metric instrumentation to keep future regressions visible.

### Primary files
- `graphics/afferent/src/Afferent/Draw/Collect.lean`
- `graphics/afferent/src/Afferent/UI/Arbor/Widget/MeasureCache.lean`
- `graphics/afferent/src/Afferent/Draw/Builder.lean` (if found hot in follow-up)

### Expected improvement after Phase 4
- Incremental: **3% to 10% total-frame improvement** in large-tree scenarios.
- Main value is regression prevention and stability under long sessions.

### Validation gate
- Re-run suite and confirm no phase regressions.
- Require non-negative improvement in all major baseline scenarios.

## Execution/Measurement Protocol
For each phase:
1. Implement only that phase.
2. Run:
   - `just test-project graphics/afferent-demos`
3. Capture and compare:
   - switch/dropdown/stepper (total, collect)
   - static deep tree (total, collect)
   - dynamic subtree swap (total, update)
   - fanout dynWidget (total, update)
4. If gate fails, revert/adjust before proceeding.

## Success Criteria (End State)
- Stepper baseline total: `49.1 ms` -> target **<= 36 ms**.
- Stepper collect: `40.8 ms` -> target **<= 28 ms**.
- Dynamic subtree swap update: `30.4 ms` -> target **<= 24 ms**.
- No rendering correctness regressions, and all test suites continue passing.
