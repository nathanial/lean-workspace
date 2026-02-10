/-
  Measure cache invalidation tests.
  Verifies signature-keyed measurement cache invalidates on layout-affecting
  input changes and reuses entries for render-only changes.
-/
import AfferentTests.Framework
import Afferent.UI.Arbor
import Afferent.UI.Arbor.Widget.MeasureCache
import Afferent.Graphics.Text.Measurer

namespace AfferentTests.MeasureCacheInvalidationTests

open Crucible
open AfferentTests
open Afferent.Arbor
open Afferent

testSuite "Measure Cache Invalidation Tests"

private def fontA : FontId := { id := 1, name := "mono-14", size := 14.0 }

private def runMeasured (cache : IO.Ref MeasureCache) (w : Widget) (availW availH : Float) : IO MeasureResult := do
  runWithFonts FontRegistry.empty (measureWidgetCached cache w availW availH)

private def mkText (id : Nat) (content : String) (color : Color) (width : Float) : Widget :=
  Widget.text id none content fontA color .left (some 240) (some (TextLayout.singleLine content width 16))

private def mkRect (id : Nat) (bg : Option Color) (minW minH : Float) : Widget :=
  Widget.rect id none {
    backgroundColor := bg
    minWidth := some minW
    minHeight := some minH
  }

test "text change invalidates measured result" := do
  setMeasureCacheEnabled true
  resetMeasureCacheInstrumentation
  let cache ← IO.mkRef MeasureCache.empty
  let first := mkText 10 "old" Color.white 30
  let _ ← runMeasured cache first 600 400

  let secondInput := mkText 10 "new value" Color.white 90
  let second ← runMeasured cache secondInput 600 400
  let stats ← snapshotMeasureCacheInstrumentation
  shouldBe stats.hits 0
  shouldBe stats.misses 2

  match second.widget with
  | .text _ _ content .. =>
    shouldBe content "new value"
  | _ =>
    ensure false "Expected text widget result"

  match second.node.content with
  | some cs => shouldBeNear cs.width 90.0
  | none => ensure false "Expected measured text content size"

test "available-space change invalidates measured result" := do
  setMeasureCacheEnabled true
  resetMeasureCacheInstrumentation
  let cache ← IO.mkRef MeasureCache.empty
  let w := mkRect 20 (some Color.green) 48 18
  let _ ← runMeasured cache w 500 300
  let _ ← runMeasured cache w 520 300

  let stats ← snapshotMeasureCacheInstrumentation
  shouldBe stats.hits 0
  shouldBe stats.misses 2

test "render-only color change reuses cache and preserves current visuals" := do
  setMeasureCacheEnabled true
  resetMeasureCacheInstrumentation
  let cache ← IO.mkRef MeasureCache.empty
  let red := mkRect 30 (some Color.red) 64 20
  let _ ← runMeasured cache red 700 480

  let blue := mkRect 30 (some Color.blue) 64 20
  let second ← runMeasured cache blue 700 480
  let stats ← snapshotMeasureCacheInstrumentation
  shouldBe stats.hits 1
  shouldBe stats.misses 1

  match second.widget with
  | .rect _ _ style =>
    shouldBe style.backgroundColor (some Color.blue)
  | _ =>
    ensure false "Expected rect widget"

test "replaced subtree does not serve stale measurement" := do
  setMeasureCacheEnabled true
  resetMeasureCacheInstrumentation
  let cache ← IO.mkRef MeasureCache.empty
  let style : BoxStyle := {}
  let oldChild := mkText 41 "A" Color.white 12
  let oldTree := Widget.flex 40 none (Trellis.FlexContainer.row 0) style #[oldChild]
  let _ ← runMeasured cache oldTree 640 480

  let newChild := mkText 41 "AAAAAAAA" Color.white 96
  let newTree := Widget.flex 40 none (Trellis.FlexContainer.row 0) style #[newChild]
  let second ← runMeasured cache newTree 640 480
  let stats ← snapshotMeasureCacheInstrumentation
  shouldBe stats.hits 0
  shouldBe stats.misses 2

  match second.widget with
  | .flex _ _ _ _ children =>
    shouldBe children.size 1
    match children[0]? with
    | some child =>
      match child with
      | .text _ _ content _ _ _ _ _ =>
        shouldBe content "AAAAAAAA"
      | _ =>
        ensure false "Expected first child to be text"
    | _ => ensure false "Expected first child to be text"
  | _ =>
    ensure false "Expected flex widget"

  match second.node.children[0]? with
  | some childNode =>
    match childNode.content with
    | some cs => shouldBeNear cs.width 96.0
    | none => ensure false "Expected child measured content size"
  | none =>
    ensure false "Expected child layout node"

end AfferentTests.MeasureCacheInvalidationTests
