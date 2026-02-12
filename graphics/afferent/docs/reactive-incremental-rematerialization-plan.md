# Reactive Incremental Re-Materialization Plan (Aggressive)

## Goal
Eliminate full-tree per-frame render re-materialization in Canopy reactive rendering, so unchanged subtrees do not execute child render thunks, allocate child arrays, or rebuild widget builders.

## Success Criteria
- `reactive render` time drops materially in Widget Perf label/caption cases (2k cells).
- Unchanged subtree render paths do not run `childRenders.mapM id` each frame.
- Correctness preserved for dynamic subtrees (`dynWidget`, keyed dynamic lists, hover/input-driven visuals).

## Implementation (No telemetry phase)

1. Replace `ComponentRender` primitive with a versioned render cell
- Introduce a `ComponentRender` structure with:
  - `materialize : IO WidgetBuilder`
  - `version : IO Nat`
- Add constructors:
  - `static` for immutable widget builders.
  - `volatile` for per-frame dynamic closures.
  - memoized container render cells driven by child-version signatures.

2. Make static emission the default
- Change `emit` to accept static `WidgetBuilder`.
- Add `emitRender` and `emitDynamic` for explicit non-static render paths.
- Keep dynamic behavior explicit instead of implicit.

3. Memoize all core container combinators
- Convert `column'`, `row'`, `staticColumn'`, `flexRow'`, `flexColumn'`, panel wrappers, and `runWidget` root combine path to cached child-composition render cells.
- Recompute only changed children (by version), not entire child arrays.

4. Convert `dynWidget` and keyed dyn list output to versioned cells
- Maintain subtree generation/version refs.
- Bump subtree version only on real rebuilds.
- Materialize child render arrays only for changed entries.

5. Update explicit dynamic closures
- Any render closure that samples dynamic state at render-time (`sample`) must use `emitDynamic` (volatile) or be rewritten to event-driven updates.

6. Integrate runner fast path
- Read root render version before materialization.
- Reuse `cachedWidget` when version is unchanged.
- Keep input/layout/hit semantics unchanged.

7. Build + test + perf validate
- Build `afferent_demos`.
- Run targeted tests for reactive/canopy widget behavior.
- Re-run Widget Perf label benchmark and compare against baseline.

## Non-goals
- Partial layout recomputation in this pass.
- Render command diffing in this pass.
- Additional telemetry instrumentation phase.

## Risk Controls
- Keep `volatile` path available for any non-conforming render closures.
- Preserve existing `dynWidget` rebuild semantics and scope lifecycle.
- Land in incremental commits by layer to isolate regressions quickly.
