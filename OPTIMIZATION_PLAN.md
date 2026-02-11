# Afferent UI Optimization Plan

## Goal
Improve real application performance in `graphics/afferent` and `graphics/afferent-demos` without changing semantics just to game benchmarks.

This plan targets bottlenecks observed in current stress/perf tests:
- High `update` time in large dynamic subtree swaps.
- Significant `dynWidget` rebuild costs when many subtrees update.
- Broad event fan-out costs in large interactive trees.

## Non-Goals
- No benchmark-only hacks.
- No behavior changes that invalidate existing widget lifecycle semantics.
- No removal of `dynWidget` as a core abstraction.

## Principles
1. Preserve semantics first.
2. Move expensive work to smaller/dirtier regions.
3. Deduplicate updates before they hit `dynWidget`.
4. Keep stable identities for unchanged subtrees.
5. Validate each optimization with end-to-end tests and perf numbers.

## Priority 1: Reduce Event Fan-Out Overhead

### Problem
Hover processing currently scales with the number of interactive components per event in:
- `graphics/afferent/src/Afferent/UI/Canopy/Reactive/Inputs.lean` (`buildHoverChangeEvent`)

### Change
Replace full interactive-set scanning with path-delta processing:
1. Track previous hovered widget/component set.
2. Convert current hover hit path to a set.
3. Emit only enter/leave deltas.
4. Update hover fan registry from those deltas.

### Expected Impact
- Major reduction in per-hover CPU for large trees.
- Lower reactive churn feeding `useHover` and related dynamics.

### Risk
- Medium: hover semantics must remain exact for nested and overlapping targets.

## Priority 2: Add Deduplicating DynWidget Boundary API

### Problem
`dynWidget` rebuilds whenever `dynValue.updated` fires, even if the mapped render-state is effectively unchanged.

Relevant area:
- `graphics/afferent/src/Afferent/UI/Canopy/Reactive/Component.lean`

### Change
Add a new API variant (example: `dynWidgetUniq`) that deduplicates `dynValue` updates at the boundary:
1. Wrap source dynamic with `Dynamic.holdUniqDynM` or equivalent dedupe.
2. Rebuild only when value is `BEq`-different.
3. Keep existing `dynWidget` behavior unchanged for backward compatibility.

### Expected Impact
- Fewer unnecessary subtree rebuilds.
- Immediate gains in widgets that map/frame-update into coarse state buckets.

### Risk
- Low/Medium: requires careful API design for non-`BEq` inputs and migration path.

## Priority 3: Reduce Rebuild Granularity in Data Widgets

### Problem
Some data widgets rebuild larger visual trees than necessary for localized updates.

Targets:
- `graphics/afferent/src/Afferent/UI/Canopy/Widget/Data/ListBox.lean`
- `graphics/afferent/src/Afferent/UI/Canopy/Widget/Data/TreeView.lean`
- `graphics/afferent/src/Afferent/UI/Canopy/Widget/Data/Table.lean`
- `graphics/afferent/src/Afferent/UI/Canopy/Widget/Data/DataGrid.lean`

### Change
Refactor to keyed row/node subcomponents:
1. Split monolithic render-state dynWidget into smaller keyed dynWidgets.
2. Rebuild only affected rows/nodes/cells.
3. Preserve stable identity for unchanged children.

### Expected Impact
- Lower rebuild CPU and less command/layout churn.
- Better scaling for large data-driven UIs.

### Risk
- Medium: identity/focus/selection behavior must remain stable.

## Priority 4: Add Keyed Dynamic Collection Primitive

### Problem
`dynWidget` is subtree-level replacement by design. Real apps need keyed incremental list/tree updates.

### Change
Add framework primitive for keyed dynamic collections (conceptually similar to dynamic-for keyed by item id):
1. Maintain child scopes by key.
2. Rebuild only inserted/removed/changed keys.
3. Reuse unchanged child scopes and render closures.

### Expected Impact
- Large improvement for list/grid/tree patterns.
- Enables framework-level performance gains across many widgets.

### Risk
- High: new primitive requires robust lifecycle and ordering semantics.

## Priority 5: Incremental Layout and Hit-Index Recompute

### Problem
Current frame pipeline re-measures/layouts/rebuilds hit index broadly, even for localized subtree changes.

### Change
Introduce dirty-region/subtree propagation:
1. Track dirty nodes from reactive updates.
2. Recompute layout only for affected branches when constraints allow.
3. Rebuild hit-test index incrementally for changed branches.

### Expected Impact
- Necessary for true order-of-magnitude gains in very large trees.
- Reduces global frame cost from localized updates.

### Risk
- High: architectural change in layout/index pipeline.

## Implementation Roadmap

### Phase A (Low Risk, High ROI)
1. Hover path-delta fan-out optimization.
2. `dynWidgetUniq` API + selective adoption in demos/widgets.
3. Add perf assertions/metrics snapshots for rebuild counts and update time.

### Phase B (Medium Risk)
1. Refactor ListBox/TreeView/Table/DataGrid to keyed partial rebuild patterns.
2. Validate focus/hover/selection stability via existing tests.

### Phase C (Higher Risk, Structural)
1. Implement keyed dynamic collection primitive.
2. Migrate heavy widgets and demo stress patterns to primitive.

### Phase D (Deep Engine Work)
1. Incremental layout/hit-index recomputation.
2. Extend stress benchmarks to report dirty-node vs full-node processing.

## Validation Strategy

Run after each phase:
1. `just test-project graphics/afferent`
2. `just test-project graphics/afferent-demos`
3. Compare:
   - `update` ms/frame
   - `dynWidget` rebuild count
   - `dynWidget` total rebuild nanos
   - total frame time in stress benchmarks

Pass criteria for each change:
1. No functional regressions.
2. Measurable perf improvement in at least one target scenario.
3. No major regressions in unaffected scenarios.

## Current Bottleneck Interpretation
Based on current stress output, the most expensive dynamic scenario is large subtree swapping (high rebuild cost per rebuild), not high-fanout tiny leaf updates. This indicates subtree-level rebuild granularity is the dominant short-term optimization target.

