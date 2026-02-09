/-
  Measure cache regression tests.
  Ensures cache reuse does not return stale widget trees and that
  layout-affecting changes invalidate cached measurements.
-/
import AfferentTests.Framework
import Afferent.UI.Arbor
import Afferent.UI.Arbor.Widget.MeasureCache
import Afferent.Graphics.Text.Measurer

namespace AfferentTests.MeasureCacheTests

open Crucible
open AfferentTests
open Afferent.Arbor
open Afferent

testSuite "Measure Cache Tests"

private def runMeasured (cache : IO.Ref MeasureCache) (w : Widget) (availW availH : Float) : IO MeasureResult := do
  runWithFonts FontRegistry.empty (measureWidgetCached cache w availW availH)

private def mkRect (id : Nat) (bg : Option Color) (minW minH : Float) : Widget :=
  Widget.rect id none {
    backgroundColor := bg
    minWidth := some minW
    minHeight := some minH
  }

test "measure cache hits when inputs are unchanged" := do
  setMeasureCacheEnabled true
  resetMeasureCacheInstrumentation
  let cache ← IO.mkRef MeasureCache.empty
  let w := mkRect 1 (some Color.red) 40 24
  let _ ← runMeasured cache w 400 300
  let first ← snapshotMeasureCacheInstrumentation
  shouldBe first.hits 0
  shouldBe first.misses 1

  let _ ← runMeasured cache w 400 300
  let second ← snapshotMeasureCacheInstrumentation
  shouldBe second.hits 1
  shouldBe second.misses 1

test "visual-only changes keep cache hit and return current widget" := do
  setMeasureCacheEnabled true
  resetMeasureCacheInstrumentation
  let cache ← IO.mkRef MeasureCache.empty
  let red := mkRect 2 (some Color.red) 50 18
  let _ ← runMeasured cache red 500 300

  let blue := mkRect 2 (some Color.blue) 50 18
  let second ← runMeasured cache blue 500 300
  let stats ← snapshotMeasureCacheInstrumentation
  shouldBe stats.hits 1
  shouldBe stats.misses 1

  match second.widget with
  | .rect _ _ style =>
    ensure (style.backgroundColor == some Color.blue)
      "Expected cached measure to preserve current widget visual state"
  | _ =>
    ensure false "Expected rect widget"

test "layout-affecting style changes invalidate cached measurement" := do
  setMeasureCacheEnabled true
  resetMeasureCacheInstrumentation
  let cache ← IO.mkRef MeasureCache.empty
  let initial := mkRect 3 (some Color.green) 20 10
  let _ ← runMeasured cache initial 320 200

  let grown := mkRect 3 (some Color.green) 120 10
  let updated ← runMeasured cache grown 320 200
  let stats ← snapshotMeasureCacheInstrumentation
  shouldBe stats.hits 0
  shouldBe stats.misses 2

  match updated.node.content with
  | some cs => shouldBeNear cs.width 120.0
  | none => ensure false "Expected measured content size on rect node"

end AfferentTests.MeasureCacheTests
