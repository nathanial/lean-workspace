# Layout Caching Optimization Plan

## Objective

Implement full incremental layout caching for Arbor/Trellis so unchanged subtrees are reused across frames, while preserving correctness under dynamic updates.

Primary outcomes:

- Reuse unchanged subtree layout work even when parent widgets rebuild.
- Avoid stale layout reuse when content/constraints actually change.
- Add robust tests to validate both correctness and recomputation behavior.

## Scope

In scope:

- Incremental subtree layout caching in Trellis.
- Safe measurement caching keyed by layout-affecting signatures.
- Cache hit/miss/recompute instrumentation.
- Correctness tests, invalidation tests, stale-cache tests, and perf-regression tests.

Out of scope (initially):

- GPU/render-command cache redesign.
- Broad refactors unrelated to layout/measurement cache behavior.

## Current Pipeline (Baseline)

Per frame:

1. Build widget tree.
2. Measure widget tree to `LayoutNode`.
3. Run `Trellis.layout` on full tree.
4. Build hit-test index.
5. Collect render commands.

Even with `dynWidget`, layout is currently recomputed globally each frame. Existing render cache helps `CustomSpec.collect`, but does not avoid full layout traversal.

## Milestones

## M0 - Baseline Instrumentation and Safety Harness

### Deliverables

- Add instrumentation counters/timers for:
  - layout cache hits/misses
  - reused node count vs recomputed node count
  - measure cache hits/misses
- Add toggles:
  - `layoutCacheEnabled`
  - `measureCacheEnabled`
  - `strictValidationMode` (cached vs uncached equivalence checks in tests)

### Target Files

- `graphics/trellis/Trellis/Algorithm.lean`
- `graphics/afferent/src/Afferent/UI/Arbor/Widget/MeasureCache.lean`
- `graphics/afferent-demos/Demos/Core/Runner/Unified.lean`

### Tests

- New test: `graphics/trellis/TrellisTests/LayoutCacheInstrumentationTests.lean`
  - verifies counters increment on hit/miss paths
  - verifies toggle disables cache path cleanly

### Exit Criteria

- Instrumentation available in tests and demo runner stats.
- No behavior change when cache disabled.

## M1 - Layout-Affecting Signatures

### Deliverables

- Define stable layout signature for each `LayoutNode`/widget subtree using only layout-affecting inputs:
  - dimensions/constraints/padding/margins/positioning relevant to layout
  - container props (flex/grid settings)
  - text content/font/wrap width inputs
  - custom widget layout key (new hook for custom specs)
- Exclude render-only state (hover colors, animation color phase, etc.).

### Target Files

- `graphics/afferent/src/Afferent/UI/Arbor/Widget/Core.lean`
- `graphics/afferent/src/Afferent/UI/Arbor/Widget/Measure.lean`
- `graphics/trellis/Trellis/Node.lean`

### Tests

- New test: `graphics/trellis/TrellisTests/LayoutSignatureTests.lean`
  - signature changes when size-relevant fields change
  - signature stable when render-only fields change
  - signature differs for structural child changes

### Exit Criteria

- Signature contract is explicit and test-covered.
- Signature stability is deterministic across rebuilds with same inputs.

## M2 - Safe Measurement Cache (No Stale Text/Layout Inputs)

### Deliverables

- Update measure cache keys to include signature data (not just `(widgetId, availW, availH)`).
- Ensure changing text/value/config invalidates cache correctly.
- Retain cache hits for unchanged repeated structures.

### Target Files

- `graphics/afferent/src/Afferent/UI/Arbor/Widget/MeasureCache.lean`
- `graphics/afferent/src/Afferent/UI/Arbor/Widget/Measure.lean`

### Tests

- New test: `graphics/afferent/test/AfferentTests/MeasureCacheInvalidationTests.lean`
  - text change invalidates measured result
  - width/height constraint change invalidates measured result
  - hover/color-only change does not invalidate measured result
  - removed/replaced subtree does not serve stale measurement

### Exit Criteria

- No stale measure results in targeted invalidation tests.
- Repeat-frame hit rate improves for stable scenes.

## M3 - Trellis Subtree Layout Cache (Core Incremental Layout)

### Deliverables

- Add `LayoutCache` with bounded capacity (LRU).
- Cache value stores local-coordinate computed subtree layout and metadata.
- Cache key includes:
  - subtree identity (stable path or explicit subtree id)
  - subtree layout signature
  - available width/height
  - relevant subgrid context key
- On cache hit:
  - reuse subtree layout
  - apply parent translation
  - skip descent into cached subtree

### Target Files

- New: `graphics/trellis/Trellis/LayoutCache.lean`
- `graphics/trellis/Trellis/Algorithm.lean`
- `graphics/trellis/Trellis/Result.lean` (if helper APIs needed)

### Tests

- New test: `graphics/trellis/TrellisTests/LayoutCacheCorrectnessTests.lean`
  - cached vs uncached outputs identical for same input tree
  - parent position change translates child layouts without recompute
  - ancestor update that does not alter child available size preserves child cache hit
  - available size change forces expected subtree recompute

### Exit Criteria

- `strictValidationMode` passes equivalence checks.
- Recomputed-node count drops in synthetic unchanged-subtree scenarios.

## M4 - Invalidation Robustness and Stale-Node Protection

### Deliverables

- Harden invalidation for:
  - subtree removal
  - subtree replacement with reused ids/paths
  - dynamic structure churn (`dynWidget` generation changes)
- Ensure cache cannot return layouts for nodes no longer present.

### Target Files

- `graphics/trellis/Trellis/LayoutCache.lean`
- `graphics/afferent/src/Afferent/UI/Canopy/Reactive/Component.lean`
- `graphics/afferent/src/Afferent/UI/Arbor/Widget/DSL.lean`

### Tests

- New test: `graphics/trellis/TrellisTests/LayoutCacheStaleNodeTests.lean`
  - remove subtree then rebuild: no stale entries used
  - replace subtree content with same shape but different constraints: invalidation triggers
  - dynamic generation bump invalidates relevant cache scope
- New stress test: `graphics/trellis/TrellisTests/LayoutCacheFuzzTests.lean`
  - randomized tree mutations; cached and uncached layouts must match

### Exit Criteria

- No stale-node failures in deterministic and fuzz tests.
- No cache poisoning across dynamic rebuild cycles.

## M5 - Runner Integration and Perf Gates

### Deliverables

- Integrate cache in:
  - `graphics/afferent-demos/Demos/Core/Runner/Unified.lean`
  - `graphics/afferent/src/Afferent/App/UIRunner.lean`
- Add perf reporting for cache effectiveness and recompute reduction.

### Tests

- Extend benchmark test coverage:
  - `graphics/afferent-demos/AfferentDemosTests/WidgetPerfBench.lean`
  - add scenarios:
    - static large subtree + animated ancestor
    - stepper grid hover and non-hover
    - mixed tree with partial updates
- Add assertions (not just printed metrics):
  - minimum cache hit ratio for stable scenario
  - maximum recomputed-node ratio under stable-subtree scenario

### Exit Criteria

- Layout cache enabled path passes all tests.
- Stable-subtree benchmark shows meaningful recompute reduction.

## Test Strategy

## 1. Correctness Equivalence

For each test tree:

- run uncached layout
- run cached layout
- assert `LayoutResult.layouts` equivalent (node ids, border/content rects)

This is the primary guard against stale or incorrect cache reuse.

## 2. Invalidation Accuracy

Verify cache invalidates exactly when it should:

- text/content changes
- size constraints changes
- subtree structure changes
- available-space changes

And does **not** invalidate on render-only changes.

## 3. Recompute-Rate Assertions

Track recomputed vs reused counts:

- stable scene should converge to high reuse
- controlled updates should only recompute impacted branches

## 4. Stale-Node Safety

Explicitly test subtree deletion/replacement cycles and generation churn to ensure removed nodes are never reused.

## 5. Capacity/Eviction Behavior

LRU tests for:

- bounded memory behavior
- no correctness regression after eviction/repopulation

## Test Execution Plan

Run targeted suites during development:

1. `just test-project graphics/trellis`
2. `just test-project graphics/afferent`
3. `just test-project graphics/afferent-demos`

Before merge:

1. `just test-project graphics/trellis`
2. `just test-project graphics/afferent`
3. `just test-project graphics/afferent-demos`
4. `just test-all` (full regression)

## Risk Register

- Risk: cache key misses a layout-affecting field -> stale layout.
  - Mitigation: signature tests + strict cached/uncached equivalence mode + fuzz mutation tests.
- Risk: overly broad keys reduce hit rate.
  - Mitigation: recompute-rate benchmarks and key tuning.
- Risk: memory growth from cache entries.
  - Mitigation: LRU cap + eviction tests + telemetry.

## Definition of Done

- Full test matrix passes.
- Cached and uncached layouts are equivalent across correctness/fuzz suites.
- Stale-node tests pass.
- Benchmarks show reduced recomputation for unchanged subtrees.
- Feature can be toggled off cleanly for fallback.
