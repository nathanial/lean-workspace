import Crucible
import AfferentSpinners.Canopy.Widget.Display.Spinner
import Afferent.UI.Canopy.Theme

open Crucible
open AfferentSpinners.Canopy
open Afferent.Arbor

testSuite "afferent-spinners"

def testFont : Afferent.Arbor.FontId :=
  { Afferent.Arbor.FontId.default with id := 0, name := "test", size := 14.0 }
def testTheme : Afferent.Canopy.Theme :=
  { Afferent.Canopy.Theme.dark with font := testFont, smallFont := testFont }

test "default spinner color falls back to theme primary" := do
  let config : Spinner.Config := {}
  let color := Spinner.getColor config testTheme
  ensure (color == testTheme.primary.background) "Default spinner color should use theme primary background"

test "explicit spinner color override is respected" := do
  let override := Afferent.Color.fromRgb8 255 0 128
  let config : Spinner.Config := { color := some override }
  let color := Spinner.getColor config testTheme
  ensure (color == override) "Spinner color override should be used when provided"

test "spinnerVisual emits component-id root widget" := do
  let config : Spinner.Config := { variant := .orbit, dims := { size := 50.0, strokeWidth := 2.0 } }
  let rootId : ComponentId := 7
  let builder := spinnerVisual rootId 0.25 config testTheme
  let (widget, _) ← builder.run {}
  ensure (widget.componentId? == some rootId) "Spinner root widget should preserve assigned component id"

def main : IO UInt32 := runAllSuites
