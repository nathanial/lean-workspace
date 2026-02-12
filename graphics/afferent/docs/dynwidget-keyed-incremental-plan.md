# DynWidget Keyed Incremental Rebuild Plan

## Objective

Reduce `dynWidget` rebuild cost for large subtrees by reusing unchanged keyed children instead of clearing and rebuilding the entire child scope every update.

This targets cases common in `graphics/afferent-demos` where:
1. Only part of a large tree changes per frame.
2. Animation-heavy regions coexist with mostly static regions.

## Current Bottleneck

Current `dynWidget` in `graphics/afferent/src/Afferent/UI/Canopy/Reactive/Component.lean` does full subtree rebuild on each update:
1. `childScope.clear`
2. Re-run builder for whole subtree
3. Replace render array

For large trees this makes rebuild cost proportional to total subtree size, not changed subset size.

## Design Direction

Implement a new keyed incremental combinator first, then optionally migrate selected callsites.

Proposed initial API:

```lean
def dynWidgetKeyedList [BEq k] [Hashable k] [DynWidgetResult b]
  (dynItems : Dynamic Spider (Array a))
  (keyOf : a → k)
  (builder : a → WidgetM b)
  : WidgetM (Dynamic Spider (Array b))
```

Rationale:
1. Keeps existing `dynWidget` behavior unchanged.
2. Matches list/grid/tree UI patterns in demos.
3. Makes diffing semantics explicit via keys.

## Data Model

Use per-key entries stored in a map:

```lean
structure KeyedDynEntry (k b) where
  key : k
  scope : Reactive.SubscriptionScope
  renders : Array ComponentRender
  result : b
  generation : Nat
```

Working state held in refs:
1. `entriesRef : IO.Ref (HashMap k (KeyedDynEntry k b))`
2. `orderRef : IO.Ref (Array k)` for stable render order
3. `globalGenRef : IO.Ref Nat` for container-level invalidation only when needed

## Incremental Algorithm

On each `dynItems.updated`:

1. Build `newKeys` and `newOrder`.
2. Dispose removed keys:
   `oldKeys - newKeys`, then `entry.scope.dispose`.
3. For each item in new order:
   if key missing then create entry in fresh child scope.
   if key exists and item unchanged by update policy then reuse entry.
   if key exists and item changed then:
   dispose old entry scope, rebuild just that key in fresh child scope.
4. Write updated map and order.
5. Rebuild top-level render list by concatenating child `renders` in `newOrder`.

Initial update policy for "changed":
1. Always rebuild existing keys in V1 unless caller provides equality.
2. Add optional `shouldRebuild : a → a → Bool` in V2 to skip unchanged keyed items.

## Rendering and Cache Generation

Key point: avoid invalidating unchanged keyed children.

Plan:
1. Track generation per keyed entry.
2. Wrap each child render with that entry generation.
3. Only increment generation for keys that were rebuilt.
4. Keep unchanged keys at prior generation so render-command cache can hit.

This aligns with cache-generation usage in `Afferent.UI.Arbor.Widget.DSL`.

## Implementation Phases

### Phase 0: Baseline and Guardrails

1. Capture current benchmark numbers from:
   `graphics/afferent-demos/AfferentDemosTests/WidgetTreePerfStress.lean`.
2. Record dynWidget metrics snapshot (`rebuildCount`, `rebuildNanos`) for baseline.
3. Add this baseline to test notes in PR description.

### Phase 1: Internal Keyed Builder Primitive

1. Add internal helpers in `Component.lean` to:
   create keyed child entry, dispose entry, materialize ordered renders.
2. Keep public API unchanged in this phase.
3. Add focused tests for scope disposal correctness.

### Phase 2: Public `dynWidgetKeyedList`

1. Add new combinator API and docs.
2. Reuse `DynWidgetResult` result-tracking optimization.
3. Register all subscriptions in child scopes so disposal remains deterministic.

### Phase 3: Pilot Callsite Migration

Migrate one or two high-impact demo paths first, not entire codebase.

Suggested pilots:
1. `AfferentDemosTests/WidgetTreePerfStress.lean` dynamic swap benchmark path.
2. One list/grid widget path in `Afferent/UI/Canopy/Widget/Data`.

### Phase 4: Expand + Tune

1. Add optional `shouldRebuild` predicate for keyed entries.
2. Consider helper wrappers for common key types.
3. Evaluate whether some animation islands should use explicit root fan-out pattern.

## Testing Plan

Add tests in `graphics/afferent/test/AfferentTests`:

1. Key reuse test:
   unchanged keys keep same entry generation.
2. Key removal test:
   removed key scopes are disposed exactly once.
3. Reorder test:
   reordering keys preserves entry state and does not rebuild unchanged keys.
4. Mixed update test:
   add/remove/update in one frame updates only expected keys.

Keep performance validation in:
1. `AfferentDemosTests/WidgetTreePerfStress.lean`.
2. Existing `data/reactive` benchmark additions for 20k-scale behavior.

## Success Criteria

1. Dynamic subtree benchmark shows substantial drop in rebuild time when only subset of keys changes.
2. No regressions in correctness tests around subscriptions and interaction behavior.
3. Render-command cache hit rate improves for unchanged keyed children.
4. Existing `dynWidget` callsites remain source-compatible and behaviorally unchanged.

## Risks

1. Key instability at callsites can cause churn and erase benefits.
2. Incorrect scope lifecycle can leak subscriptions or dispose active ones.
3. Generation stamping mistakes can cause stale renders or over-invalidation.

## Open Questions Before Coding

1. Should V1 expose only `Array a` input, or also `List a` convenience API?
2. Do we want V1 to require caller-provided change predicate, or default to rebuild-on-key-hit?
3. Which exact demo callsite should be first pilot for minimal migration risk?
4. Do we want dynWidget metrics extended with per-key rebuild counts in V1 or V2?

## Implementation Status (2026-02-12)

Completed:
1. Phase 1: internal keyed entry lifecycle (create/reuse/rebuild/dispose) in `Component.lean`.
2. Phase 2: public `dynWidgetKeyedListWith` + `dynWidgetKeyedList`.
3. Phase 2 tests: keyed reuse, removal disposal, pure reorder, mixed add/remove/update.
4. Phase 3 pilot: `WidgetTreePerfStress` dynamic swap path moved to keyed incremental sections.
5. Phase 3 pilot: toast list path migrated to keyed incremental rebuild.
6. Phase 4 (V2 capability): optional `shouldRebuild` predicate exposed in `dynWidgetKeyedListWith`.

Validation run:
1. `just test-project graphics/afferent` passed.
2. `just test-project graphics/afferent-demos` passed.
3. `just test-project data/reactive` passed.

Benchmark snapshot (from `graphics/afferent-demos/AfferentDemosTests/WidgetTreePerfStress.lean`):
1. Dynamic subtree swap (pre sparse-keyed change in this branch): `update=35.1ms`, `total=35.1ms`, `dynWidget rebuilds=20`, `dynWidget total=276.6ms`.
2. Dynamic subtree swap (after sparse-keyed change): `update=11.7ms`, `total=16.3ms`, `dynWidget rebuilds=10`, `dynWidget total=96.9ms`.
3. Interpretation: keyed incremental boundary plus sparse per-frame churn reduced update-phase cost by about `66%` and total-frame cost by about `54%` in this stress scenario.
