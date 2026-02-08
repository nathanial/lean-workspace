import Crucible
import AfferentProgressBars.Canopy.Widget.Display.ProgressBar
import Afferent.UI.Canopy.Theme

open Crucible
open AfferentProgressBars.Canopy

testSuite "afferent-progress-bars"

def testFont : Afferent.Arbor.FontId :=
  { Afferent.Arbor.FontId.default with id := 0, name := "test", size := 14.0 }
def testTheme : Afferent.Canopy.Theme :=
  { Afferent.Canopy.Theme.dark with font := testFont, smallFont := testFont }

test "variant colors map by semantic intent" := do
  let primary := ProgressBar.variantColor .primary testTheme
  let success := ProgressBar.variantColor .success testTheme
  ensure (primary == testTheme.primary.background) "Primary variant should use theme primary color"
  ensure (success != primary) "Success variant should differ from primary"

test "determinate spec measure matches configured dimensions" := do
  let dims : ProgressBar.Dimensions := { width := 260, height := 12, cornerRadius := 6 }
  let spec := ProgressBar.determinateSpec 0.42 .secondary testTheme dims
  let (w, h) := spec.measure 0 0
  ensure (w == 260) s!"Expected width 260, got {w}"
  ensure (h == 12) s!"Expected height 12, got {h}"

test "indeterminate spec measure matches configured dimensions" := do
  let dims : ProgressBar.Dimensions := { width := 180, height := 10, cornerRadius := 5 }
  let spec := ProgressBar.indeterminateSpec 0.9 .warning testTheme dims
  let (w, h) := spec.measure 0 0
  ensure (w == 180) s!"Expected width 180, got {w}"
  ensure (h == 10) s!"Expected height 10, got {h}"

def main : IO UInt32 := runAllSuites
