# Prioritized Hit List: Remaining `emitDynamic` Sites

Date: February 12, 2026

Goal: continue applying the versioned-render pattern (`emitRender` + explicit `version`) to remove unnecessary reactive re-materialization.

## Already fixed

- `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/TabView.lean`
- `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/Scroll.lean`

## Priority 0 (highest impact)

1. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/SplitPane.lean:268`
- Why high: state updates are driven by hover + drag streams; during drag this path updates continuously.
- Current cost shape: volatile closure rematerializes both pane subtrees on each update.
- Action: replace `emitDynamic` with explicit `ComponentRender`; version should hash `firstRenders` + `secondRenders` versions and include a small state stamp for `(ratio, hovered, dragging)`.

2. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Data/NodeEditor.lean:1170`
- Why high: `stateDyn` is hot (pointer motion, drag, selection), and body rendering can be large.
- Current cost shape: volatile closure rematerializes per-node body widget arrays each reactive update.
- Action: use `emitRender` with version derived from body render versions + node-editor state stamp; preserve existing dynamic behavior while stopping unconditional volatility.

## Priority 1

3. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Navigation/Menu.lean:482`
- Why: hover-path/open-path updates can be frequent while menu is open.
- Action: convert to versioned render cell keyed by trigger render versions + `(open, hoverPath, openPath)`.

4. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Navigation/MenuBar.lean:315`
- Why: similar to `Menu`; multiple dynamic states merged and rebuilt on hover/open changes.
- Action: versioned render cell keyed by menu state tuple + any stable width snapshots.

5. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/Card.lean:191`
6. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/Card.lean:201`
7. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/Card.lean:211`
8. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/Card.lean:222`
- Why: wrappers are container primitives. If used widely, volatility propagates up and defeats memoization.
- Action: convert wrappers to non-volatile render cells with child-version hashing.
- Note: current usage is not huge, but this is a strategic cleanup to prevent future regressions.

## Priority 2

9. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/Popover.lean:233`
- Why: mostly interaction-scoped (open/close), not usually frame-hot.
- Action: versioned render cell keyed by anchor/content child versions + `isOpen`.

10. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/Modal.lean:305`
- Why: open/close and close-hover driven; medium interaction frequency.
- Action: versioned render cell keyed by content child versions + `(isOpen, closeHovered)`.

11. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Display/Tooltip.lean:188`
- Why: visibility toggles and hover-driven dims; generally localized.
- Action: versioned render cell keyed by target child versions + visibility and/or dimension stamp.

## Priority 3 (cleanup / low current impact)

12. `graphics/afferent/src/Afferent/UI/Canopy/Reactive/Component.lean:862` (`when'`)
- Why: currently not used in tree scan, but helper is volatile by construction.
- Action: rewrite helper to use `dynWidget condition` + `emitRender` instead of `condition.sample` inside `emitDynamic`.

## Execution order recommendation

1. SplitPane
2. NodeEditor
3. Menu + MenuBar
4. Card wrappers
5. Popover + Modal + Tooltip
6. `when'`

## Verification checklist per conversion

1. No semantic regression in interaction behavior.
2. No `emitDynamic` left in converted file unless truly required.
3. `reactive render` decreases or remains flat in relevant benchmarks.
4. Existing targeted tests/build still pass.

