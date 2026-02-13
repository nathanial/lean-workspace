/-
  Afferent MDI Tests
  Unit tests for MDI geometry and state helper behavior.
-/
import AfferentTests.Framework
import Afferent.UI.Canopy.Widget.Layout.MDI
import Afferent.UI.Canopy.Reactive.Component
import Afferent.UI.Arbor
import Trellis

namespace AfferentTests.MDITests

open Crucible
open AfferentTests
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Afferent.Arbor
open Reactive Reactive.Host
open Trellis

testSuite "MDI Tests"

/-- Test font ID for widget-building tests. -/
def testFont : FontId := { id := 0, name := "test", size := 14.0 }

/-- Test theme for widget tests. -/
def testTheme : Theme := { Theme.dark with font := testFont, smallFont := testFont }

test "clampRectToHost keeps rect fully inside host" := do
  let host : MDIRect := { x := 100, y := 50, width := 500, height := 300 }
  let rect : MDIRect := { x := -20, y := 400, width := 700, height := 500 }
  let clamped := MDI.clampRectToHost rect host
  shouldBeNear clamped.x 100.0
  shouldBeNear clamped.y 50.0
  shouldBeNear clamped.width 500.0
  shouldBeNear clamped.height 300.0

test "bringToFront moves target id to end" := do
  let z := #[10, 20, 30, 40]
  let next := MDI.bringToFront z 20
  ensure (next == #[10, 30, 40, 20]) s!"Unexpected z-order: {next}"

test "orderedWindows follows z-order and omits missing ids" := do
  let windows : Array MDIWindowState := #[
    { id := 1, title := "A", rect := { x := 0, y := 0, width := 100, height := 100 } },
    { id := 2, title := "B", rect := { x := 0, y := 0, width := 100, height := 100 } },
    { id := 3, title := "C", rect := { x := 0, y := 0, width := 100, height := 100 } }
  ]
  let ordered := MDI.orderedWindows windows #[3, 99, 1]
  ensure (ordered.map (·.id) == #[3, 1]) s!"Unexpected ordered ids: {ordered.map (·.id)}"

test "topmostWindowBy picks highest z-order hit" := do
  let topmost := MDI.topmostWindowBy #[1, 2, 3, 4] (fun id => id == 2 || id == 4)
  ensure (topmost == some 4) s!"Expected topmost 4, got {repr topmost}"

test "movedRect applies pointer delta" := do
  let start : MDIRect := { x := 100, y := 200, width := 300, height := 180 }
  let moved := MDI.movedRect start 250 300 310 280
  shouldBeNear moved.x 160.0
  shouldBeNear moved.y 180.0
  shouldBeNear moved.width 300.0
  shouldBeNear moved.height 180.0

test "moveRectForDrag clamps to host when enabled" := do
  let start : MDIRect := { x := 120, y := 90, width := 240, height := 180 }
  let host : MDIRect := { x := 0, y := 0, width := 300, height := 220 }
  let moved := MDI.moveRectForDrag start 150 130 360 320 (some host) true
  shouldBeNear moved.x 60.0
  shouldBeNear moved.y 40.0
  shouldBeNear moved.width 240.0
  shouldBeNear moved.height 180.0

test "resizeHandleAtPoint detects corner handles first" := do
  let config : MDIConfig := { edgeHandleSize := 6, cornerHandleSize := 12 }
  let rect : MDIRect := { x := 100, y := 100, width := 300, height := 200 }
  let handle := MDI.resizeHandleAtPoint? rect 105 106 config
  ensure (handle == some .northWest) s!"Expected northWest, got {repr handle}"

test "resizedRect enforces minimum width for west resize" := do
  let startRect : MDIRect := { x := 200, y := 120, width := 240, height := 160 }
  let resized := MDI.resizedRect .west startRect 200 120 370 120 180 100
  shouldBeNear resized.width 180.0
  shouldBeNear resized.x 260.0
  shouldBeNear resized.height 160.0

test "resizeRectForDrag clamps host bounds when enabled" := do
  let startRect : MDIRect := { x := 180, y := 80, width := 120, height := 120 }
  let host : MDIRect := { x := 0, y := 0, width := 260, height := 220 }
  let resized := MDI.resizeRectForDrag .southEast startRect 300 200 430 360
    80 80 (some host) true
  shouldBeNear resized.x 10.0
  shouldBeNear resized.y 0.0
  shouldBeNear resized.width 250.0
  shouldBeNear resized.height 220.0

test "snapTargetAtPoint prioritizes maximize near top-center" := do
  let host : MDIRect := { x := 0, y := 0, width := 1000, height := 800 }
  let target := MDI.snapTargetAtPoint host 500 5 30
  ensure (target == some .maximize) s!"Expected maximize, got {repr target}"

test "snapTargetAtPoint returns topLeft near top-left corner" := do
  let host : MDIRect := { x := 0, y := 0, width := 1000, height := 800 }
  let target := MDI.snapTargetAtPoint host 4 4 30
  ensure (target == some .topLeft) s!"Expected topLeft, got {repr target}"

test "snapRect computes right-half geometry" := do
  let host : MDIRect := { x := 10, y := 20, width := 800, height := 600 }
  let snapped := MDI.snapRect host .right
  shouldBeNear snapped.x 410.0
  shouldBeNear snapped.y 20.0
  shouldBeNear snapped.width 400.0
  shouldBeNear snapped.height 600.0

test "topmostWindowAtPoint returns highest overlapping window by z-order" := do
  let windows : Array MDIWindowState := #[
    { id := 1, title := "A", rect := { x := 20, y := 20, width := 200, height := 160 } },
    { id := 2, title := "B", rect := { x := 120, y := 70, width := 220, height := 180 } }
  ]
  let top := MDI.topmostWindowAtPoint windows #[1, 2] 150 100
  ensure (top == some 2) s!"Expected topmost overlap window 2, got {repr top}"

test "commitSnapRelease maximize toggles to saved rect on second maximize" := do
  let host : MDIRect := { x := 0, y := 0, width := 800, height := 500 }
  let original : MDIRect := { x := 40, y := 30, width := 320, height := 220 }
  let (maxRect, savedAfterMax) := MDI.commitSnapRelease 7 original host .maximize {}
  ensure (MDIRect.approxEq maxRect host) s!"Expected maximize rect, got {repr maxRect}"
  ensure (savedAfterMax.contains 7) "Expected saved rect after maximize"
  let (restoredRect, savedAfterRestore) := MDI.commitSnapRelease 7 maxRect host .maximize savedAfterMax
  ensure (MDIRect.approxEq restoredRect original)
    s!"Expected restored rect {repr original}, got {repr restoredRect}"
  ensure (!savedAfterRestore.contains 7) "Expected saved rect removed after restore"

test "FRP: overlap click routes to topmost window and focus can shift" := do
  let activeAfterSequence ← runSpider do
    let viewportW := 680.0
    let viewportH := 420.0
    let (events, inputs) ← createInputs Afferent.FontRegistry.empty testTheme
    let activeDynRef ← SpiderM.liftIO <| IO.mkRef (none : Option (Dynamic Spider (Option Nat)))

    let (_, render) ← ReactiveM.run events do
      runWidget do
        let windows : Array MDIWindowSpec := #[
          {
            id := 1
            title := "Window A"
            rect := { x := 20, y := 20, width := 260, height := 190 }
            content := pure ()
          },
          {
            id := 2
            title := "Window B"
            rect := { x := 120, y := 80, width := 260, height := 190 }
            content := pure ()
          }
        ]
        let result ← mdi {
          fillWidth := false
          fillHeight := false
          width := some viewportW
          height := some viewportH
        } windows
        SpiderM.liftIO <| activeDynRef.set (some result.activeWindow)
        pure ()

    let mkLayoutSnapshot : SpiderM (LayoutResult × HitTestIndex) := do
      let builder ← SpiderM.liftIO render.materialize
      let widget := Afferent.Arbor.build builder
      let measured : MeasureResult := Afferent.Arbor.measureWidget (M := Id) widget viewportW viewportH
      let layouts := Trellis.layout measured.node viewportW viewportH
      let hitIndex := buildHitTestIndex measured.widget layouts
      pure (layouts, hitIndex)

    let fireClickAt : Float → Float → SpiderM Unit := fun x y => do
      let (layouts, hitIndex) ← mkLayoutSnapshot
      let path := hitTestPathIndexed hitIndex x y
      ensure (!path.isEmpty) s!"Expected hit path at ({x}, {y})"
      inputs.fireClick {
        click := { button := 0, x := x, y := y, modifiers := (0 : UInt16) }
        hitPath := path
        layouts := layouts
        componentMap := hitIndex.componentMap
      }

    let activeDynOpt ← SpiderM.liftIO activeDynRef.get
    let activeDyn ← match activeDynOpt with
      | some dyn => pure dyn
      | none =>
          ensure false "Expected active-window dynamic from mdi result"
          Dynamic.pureM none

    -- Overlap point: should pick window 2 initially (top of initial z-order #[1,2]).
    let overlapX := 170.0
    let overlapY := 120.0
    -- Window A only point: promotes window 1 to front.
    let soloAX := 40.0
    let soloAY := 40.0

    fireClickAt overlapX overlapY
    let afterFirstOverlap ← activeDyn.sample

    fireClickAt soloAX soloAY
    let afterSoloA ← activeDyn.sample

    pure #[afterFirstOverlap, afterSoloA]

  ensure (activeAfterSequence[0]? == some (some 2))
    s!"Expected first overlap click to hit window 2, got {repr (activeAfterSequence[0]?)}"
  ensure (activeAfterSequence[1]? == some (some 1))
    s!"Expected solo click to activate window 1, got {repr (activeAfterSequence[1]?)}"

end AfferentTests.MDITests
