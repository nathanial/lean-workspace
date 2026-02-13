# MDI Widget Aggressive Execution Plan

Date: 2026-02-13
Owner: Canopy team
Status: Ready to execute

## Execution Checkpoint (2026-02-13)

Completed now:
1. `Layout/MDI.lean` implemented with move/resize/snap/maximize toggle behavior.
2. Host/window/titlebar component wiring and FRP reducer (`foldDynM`) implemented.
3. Snap preview overlay implemented.
4. Keyed incremental render path implemented via `dynWidgetKeyedListWith`.
5. Test module `AfferentTests/MDITests.lean` added and wired into `AfferentTests.lean`.
6. Demo tab `CanopyApp/Tabs/MDI.lean` added and registered in `CanopyApp.lean`.
7. `just test-project graphics/afferent` passing.
8. `just test-project graphics/afferent-demos` passing.
9. Added reducer-focused transition tests for move/resize/snap helpers.
10. Added FRP overlap-hit integration coverage for topmost click routing.
11. Completed MDI demo UX polish pass with interaction telemetry labels.

## Mission

Ship a production-usable Canopy MDI widget fast.

Target outcome:
1. Embed MDI inside normal Canopy flex layouts.
2. Inside MDI, windows use absolute positioning (not flex).
3. Windows support move, resize, snap, and focus/z-order.
4. Window contents are normal Canopy widgets.

## Non-negotiables

1. Do not add a new layout engine mode.
2. Do not break existing Canopy widgets.
3. Do not regress drag performance at 60 fps on normal demo loads.
4. Do not leave behavior undefined for overlap hit testing.

## Scope Lock

P0 (must ship):
1. MDI host container.
2. Multiple floating windows.
3. Bring-to-front on focus.
4. Drag by titlebar.
5. Resize by edges/corners.
6. Snap to left/right/top/bottom/4 quarters/maximize.
7. Snap preview overlay.
8. Window bounds clamped to host rect.
9. Per-window Canopy content region.
10. Tests for geometry + interaction reducers.
11. Demo tab in afferent-demos.

P1 (explicitly out for first ship):
1. Tabbed docking groups.
2. Persisted layouts to disk.
3. Fancy animations.
4. Multi-monitor awareness.
5. Keyboard tiling shortcuts beyond basic focus traversal.

## Hard Technical Direction

1. Implement as `Afferent.UI.Canopy.Widget.Layout.MDI`.
2. Use existing absolute positioning via `BoxStyle.position := .absolute`.
3. Keep MDI host as a normal Canopy child so parent flex behavior remains unchanged.
4. Use existing FRP pattern: `foldDynM` over click/hover/mouse-up streams.
5. Use keyed incremental rendering (`dynWidgetKeyedListWith`) for windows.
6. Avoid volatile `emitDynamic` in hot paths unless strictly required.

## Proposed API (P0)

```lean
structure MDIWindow where
  id : Nat
  title : String
  rect : WindowRect
  minSize : Size := { width := 180, height := 120 }
  resizable : Bool := true
  movable : Bool := true
  content : WidgetM Unit

structure MDIConfig where
  snapThreshold : Float := 22
  titlebarHeight : Float := 28
  minWindowWidth : Float := 180
  minWindowHeight : Float := 120
  showSnapPreview : Bool := true
  clampToHost : Bool := true

structure MDIResult where
  activeWindow : Dynamic Spider (Option Nat)
  windows : Dynamic Spider (Array MDIWindowState)
  onWindowMove : Event Spider (Nat × WindowRect)
  onWindowResize : Event Spider (Nat × WindowRect)
  onWindowSnap : Event Spider (Nat × SnapTarget)

def mdi (config : MDIConfig) (windows : Array MDIWindow) : WidgetM MDIResult
```

## Aggressive Timeline

### Day 0 (today): Skeleton and contracts

Deliverables:
1. New file `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/MDI.lean`.
2. All core types compile.
3. Basic non-interactive visual rendering of absolute windows.
4. Export wired in `Layout.lean`.

Exit criteria:
1. `just test-project graphics/afferent` passes.

### Day 1: Interaction core

Deliverables:
1. Focus + z-order promotion on click.
2. Titlebar drag.
3. Host-bounded clamping.
4. Mouse-up termination and cancel paths.

Exit criteria:
1. Drag works in demo.
2. No stuck drag states.
3. Unit tests for reducer transitions.

### Day 2: Resizing

Deliverables:
1. Edge/corner handles and hit areas.
2. Resize reducer for all directions.
3. Min-size enforcement.
4. Clamp to host and avoid negative sizes.

Exit criteria:
1. Resize behavior stable under rapid pointer movement.
2. Geometry tests for each handle direction.

### Day 3: Snap system

Deliverables:
1. Snap target detection.
2. Preview overlay rendering.
3. Commit on mouse-up.
4. Maximize and unsnap behavior policy (single-toggle model).

Exit criteria:
1. All P0 snap targets work.
2. Snap rules deterministic under overlap and edge cases.

### Day 4: Demo integration and polish for shippability

Deliverables:
1. New MDI demo tab in afferent-demos.
2. Demo with at least 5 windows and mixed content widgets.
3. Visual affordances: active/inactive titlebars, handle visibility.

Exit criteria:
1. `just test-project graphics/afferent-demos` passes.
2. Manual demo pass complete.

### Day 5: Performance hardening and ship gate

Deliverables:
1. Keyed render path confirmed.
2. No obvious hot-loop volatile rebuilds.
3. Lightweight perf sanity scenario added or adapted in demos tests.
4. Ship notes and known limits documented.

Exit criteria:
1. Drag and resize feel smooth in demo.
2. Final test commands green.

## File-Level Worklist

Core:
1. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout/MDI.lean` (new)
2. `graphics/afferent/src/Afferent/UI/Canopy/Widget/Layout.lean` (export)

Tests:
1. `graphics/afferent/test/AfferentTests/MDITests.lean` (new)
2. `graphics/afferent/test/AfferentTests.lean` (import)

Demos:
1. `graphics/afferent-demos/Demos/Core/Runner/CanopyApp/Tabs/MDI.lean` (new)
2. `graphics/afferent-demos/Demos/Core/Runner/CanopyApp.lean` (tab registration)

## Test Matrix (minimum)

Geometry:
1. Clamp window rect to host rect.
2. Apply resize delta for each edge/corner.
3. Min width/height enforcement.
4. Snap target selection by pointer position.
5. Snap rect generation for each target.

Interaction reducer:
1. Click titlebar starts move.
2. Click handle starts resize.
3. Click window promotes z-order.
4. Mouse-up ends interaction.
5. Drag outside host still clamps correctly.

Integration:
1. Overlapping windows route clicks to topmost.
2. Window content remains interactive.
3. Snap preview appears only while dragging.

## Performance Rules

1. No full rematerialization of all windows on single-window drag.
2. Use keyed window identity, never index identity.
3. Avoid per-frame structure churn where state is unchanged.
4. Treat `emitDynamic` in core MDI path as suspect by default.

## Daily Command Set

Run from repo root:

```bash
just test-project graphics/afferent
just test-project graphics/afferent-demos
```

If fast loop needed:

```bash
just test-project graphics/afferent MDI
just test-project graphics/afferent-demos MDI
```

## Aggressive Execution Rules

1. No optional features until P0 is complete and tested.
2. No broad refactors outside touched MDI files.
3. Every day must end with running tests and a working demo state.
4. If blocked for more than 2 hours, cut scope to preserve ship date.
5. Prefer working behavior over perfect abstraction in first pass.

## Ship Gate Checklist

1. P0 feature list complete.
2. New tests added and passing.
3. Existing relevant test suites passing.
4. Demo tab showcases all required interactions.
5. Known limitations documented in this file or follow-up doc.

## Immediate Next Actions

1. Create `MDI.lean` with type skeleton and rendering shell.
2. Wire export and compile.
3. Implement reducer-driven move interaction first.
4. Add first geometry tests before resize/snap.
