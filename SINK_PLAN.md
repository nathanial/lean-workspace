# SINK_PLAN: Direct Sink Rendering Experiment

Date: 2026-02-11
Scope: `graphics/afferent` direct-stream rendering path (bypass full command materialization)

## Objective
Determine quickly whether a sink-based render pipeline is a real win.
If results are weak, stop early and avoid sunk cost.
Keep parallel-path code to the minimum possible lifetime.

## Why This Plan Exists
Current pipeline does:
1. collect widget tree -> `Array RenderCommand`
2. transform/coalesce/merge passes
3. batch execution

Hypothesis: materializing full-frame command arrays and reprocessing them is a major cost for large widget trees.

## Baseline (Reference)
Use FAST_PLAN baseline for comparison:

| Scenario | Baseline Total (ms) | Baseline Collect (ms) |
|---|---:|---:|
| switch | 15.8 | 13.2 |
| dropdown | 28.2 | 21.9 |
| stepper | 49.1 | 40.8 |
| static deep tree | 13.3 | 10.8 |
| dynamic subtree swap | 35.2 | 3.9 |
| fanout dynWidget | 8.5 | 1.6 |

## Progress Log
### 2026-02-11 - Direct `BatchCommandSink` state path (removed `pendingRef`)
- Status: implemented
- Validation:
  - `just test-project graphics/afferent` passed (`565 passed`, `0 failed`)
  - `just test-project graphics/afferent-demos` passed (`19 passed`, `0 failed`)
- Benchmark snapshot:
  - switch baseline: total `16.9ms`, collect `14.0ms`
  - dropdown baseline: total `28.8ms`, collect `22.5ms`
  - stepper baseline: total `49.3ms`, collect `41.0ms`
  - static deep tree: total `11.8ms`, collect `9.2ms`
  - dynamic subtree swap: total `34.9ms`, collect `3.5ms`
  - fanout dynWidget: total `8.5ms`, collect `1.7ms`
- Result:
  - Command materialization array in batched sink path was removed.
  - End-to-end perf remains roughly flat/noisy on core scenarios (no clear stepper win yet).

## Test/Benchmark Commands
Run after each phase:
- `just test-project graphics/afferent`
- `just test-project graphics/afferent-demos`

Collect from demos output:
- switch/dropdown/stepper: total + collect
- static deep tree: total + collect
- dynamic subtree swap: total + update
- fanout dynWidget: total + update

## Hard Stop Rules (avoid red herring)
Stop this effort if either is true after Phase 2:
1. Stepper total improvement is < 5% and stepper collect improvement is < 10%.
2. Any persistent regression > 5% in two or more core scenarios.

If stopped, revert sink changes and pivot to a different strategy.

## Migration Policy (minimize dual paths)
1. Maintain one collection entrypoint: widget traversal emits to a `RenderSink`.
2. Allow temporary fallback only at command-family boundaries, not a second full pipeline.
3. Each phase must delete at least one legacy surface area (entrypoint, pass, or command-family handling) before moving on.
4. If a phase cannot delete legacy code, justify it in this file before starting the next phase.

## Phase 0: Instrumentation Baseline
### Work
- Add timing counters for sink path stages (collect-stream, batch flush, fallback sections).
- Keep existing path behavior intact while adding measurement hooks.

### Files (expected)
- `graphics/afferent/src/Afferent/Output/Execute/Render.lean`
- `graphics/afferent/src/Afferent/Output/Execute/Batched.lean`
- new sink module under `graphics/afferent/src/Afferent/Output/Execute/`

### Gate
- All tests pass.
- Benchmark numbers stay within normal run-to-run noise (~<= 3%).

## Phase 1: Sink Interface + Legacy Adapter (No behavior change)
### Work
- Define `RenderSink` interface (`emit*` for rect/text/circle/clip/transform/custom/fallback).
- Implement `CommandArraySink` adapter that writes exactly the same commands as today.
- Wire collector to target sink abstraction as the only collection path.
- Remove direct non-sink collection entrypoints.

### Gate
- All tests pass.
- Output parity maintained (no visible regressions in demos).
- Benchmarks with `CommandArraySink` remain near baseline (<= 5% drift).
- Legacy deletion checkpoint complete: old collection entrypoints removed.

## Phase 2: Direct Batch Sink (core primitives)
### Work
- Implement `BatchSink` that updates batch state directly while traversing widgets.
- Handle first set only:
  - `fillRect`, `strokeRect`, `fillCircle`, `strokeCircle`, `fillText`
  - scope boundaries: `save/restore`, clip, transform push/pop
- Fallback unhandled commands to existing execute path.
- Delete legacy handling for migrated primitive families from command materialization/coalesce execution.

### Gate (primary decision point)
- All tests pass.
- Must achieve at least one:
  - stepper total improves >= 5%, or
  - stepper collect-stage equivalent improves >= 10%.

If not met: stop and roll back sink experiment.
- Legacy deletion checkpoint complete: migrated primitive families no longer use old command path.

## Phase 3: Coverage Expansion + Fallback Reduction
### Work
- Add direct sink handling for:
  - instanced polygon/arc, fragment draws
  - scroll-specific clipping/offset patterns
- Minimize fallback frequency.
- Remove obsolete command-array passes that are no longer needed after coverage expansion.

### Gate
- All tests pass.
- Stepper total improvement >= 10% vs baseline OR static deep tree total >= 12% improvement.
- No scenario worsens by > 5%.
- Legacy deletion checkpoint complete: old path reduced to only truly-unported command families.

## Phase 4: Cleanup / Adopt or Abort
### Adopt path (if winning)
- Keep sink path as the primary path.
- Add docs and perf regression test notes.
- Remove remaining legacy command materialization path and related passes.

### Abort path (if not winning)
- Remove/disable sink code.
- Keep only useful instrumentation.
- Update FAST_PLAN/SINK_PLAN with final conclusion.

## Memory Safety Constraints
- No unbounded persistent caches introduced by sink path.
- Reuse frame-local buffers only.
- Track high-water sizes for sink buffers each benchmark run.
- If high-water grows > 20% without clear speedup, treat as failure.

## Success Criteria
- Proven, repeatable benchmark improvement on large-tree scenarios.
- No test regressions.
- No memory-growth surprises.
- Clear go/no-go outcome by end of Phase 2 or Phase 3.
