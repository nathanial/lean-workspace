# Reactive Performance Insight: Versioned Renders Over Volatile Re-materialization

Date: February 12, 2026

## The critical insight

The main blocker for 2k-label performance was not text draw throughput.  
The blocker was reactive re-materialization work happening every frame for subtrees that had no meaningful visual change.

In short:

- `emitDynamic` creates volatile render cells.
- Volatile render cells force parent render churn.
- Parent churn triggers child re-materialization and builder reconstruction.
- This burns frame time even when pixels are effectively unchanged.

Replacing volatile render paths with explicit, versioned `ComponentRender` cells (and incrementing versions only when relevant state/children changed) removed that tax and enabled stable 60+ fps for 2k labels.

## How to recognize the same problem

Look for this profile shape:

- `reactive` is large (often double-digit ms) while `draw`/`text ffi` is moderate.
- command count and draw count look reasonable, but frame time is still bad.
- changing renderer internals yields small wins, but fps stays capped.

This usually means CPU time is spent rebuilding widget trees, not drawing them.

## Root cause pattern

Hot path structure that causes unnecessary work:

1. container uses `dynWidget ...` and inside emits `emitDynamic`.
2. emitted closure samples or rebuilds child builders each frame.
3. parent render version advances due to volatile child presence.
4. unchanged subtrees are still rematerialized.

## Fix pattern

Use non-volatile render cells with explicit versions:

1. build a `ComponentRender` with:
   - `materialize := ...` (normal subtree materialization)
   - `version := ...` (hash of relevant child versions and local state stamp)
2. `emitRender render` instead of `emitDynamic`.
3. drive updates from events/dynamics (`dynWidget`) that represent real state changes.
4. keep volatile rendering only where per-frame recompute is truly required.

## What changed in this pass

This pattern was applied in:

- `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/TabView.lean`
- `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/Scroll.lean`

Result: large drop in `reactive render` cost and 60+ fps for the 2k-label benchmark.

## Rollout checklist for more widgets

For each widget/container:

1. find `emitDynamic` usage.
2. ask: does this closure need to run every frame, or only on specific dynamic/event changes?
3. if not every frame, convert to versioned `ComponentRender` + `emitRender`.
4. make `version` depend only on:
   - child render versions,
   - local state that affects output.
5. avoid sampling changing globals in `materialize` unless they are included in `version`.
6. profile again and verify `reactive render` drops.

Useful discovery command:

```bash
rg -n "emitDynamic" graphics/afferent/src/Afferent/UI/Canopy/Widget -g '*.lean'
```

## Guardrails

- Keep semantic correctness first: output must update when state changes.
- Do not use stale versions; under-versioning can freeze UI updates.
- Prefer incremental child reuse over full subtree rebuilds.
- Treat volatile rendering as an explicit exception path, not the default.

## Practical target

For static or mostly-static screens (like the 2k-label perf case), reactive idle cost should be near-constant and low (single-digit ms total reactive, ideally low single-digit), with frame time dominated by actual layout + execute work.
