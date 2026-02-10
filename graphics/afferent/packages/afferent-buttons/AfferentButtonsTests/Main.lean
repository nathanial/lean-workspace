import Crucible
import Afferent.UI.Canopy.Widget.Input.Button
import Afferent.UI.Canopy.Theme

open Crucible
open Afferent.Canopy
open Afferent.Arbor

testSuite "afferent-buttons"

def testFont : Afferent.Arbor.FontId :=
  { Afferent.Arbor.FontId.default with id := 0, name := "test", size := 14.0 }

def testTheme : Theme :=
  { Theme.dark with font := testFont, smallFont := testFont }

test "variant color mapping uses expected theme slots" := do
  ensure (Button.variantColors testTheme .primary == testTheme.primary)
    "Primary variant should map to theme.primary"
  ensure (Button.variantColors testTheme .ghost == testTheme.outline)
    "Ghost variant should map to theme.outline"

test "content places icon before label for leading position" := do
  let (widget, _) ← (Button.content "Run" (some "▶") .leading testFont (Afferent.Color.fromRgb8 255 255 255)).run {}
  match widget with
  | .flex _ _ _ _ children =>
      ensure (children.size == 2) s!"Expected 2 children, got {children.size}"
      match children[0]!, children[1]! with
      | .text _ _ icon .., .text _ _ label .. =>
          ensure (icon == "▶") s!"Expected icon first, got '{icon}'"
          ensure (label == "Run") s!"Expected label second, got '{label}'"
      | _, _ => ensure false "Expected icon+label text widgets"
  | _ => ensure false "Expected flex content row"

test "content places label before icon for trailing position" := do
  let (widget, _) ← (Button.content "Run" (some "▶") .trailing testFont (Afferent.Color.fromRgb8 255 255 255)).run {}
  match widget with
  | .flex _ _ _ _ children =>
      ensure (children.size == 2) s!"Expected 2 children, got {children.size}"
      match children[0]!, children[1]! with
      | .text _ _ label .., .text _ _ icon .. =>
          ensure (label == "Run") s!"Expected label first, got '{label}'"
          ensure (icon == "▶") s!"Expected icon second, got '{icon}'"
      | _, _ => ensure false "Expected label+icon text widgets"
  | _ => ensure false "Expected flex content row"

test "buttonVisualWith respects explicit dimensions and outline border" := do
  let saveButtonId : ComponentId := 1401
  let builder := Button.buttonVisualWith
    saveButtonId "Save" none .leading testTheme .outline {}
    10 6 4
    (width := some 180) (height := some 40)
  let (widget, _) ← builder.run {}
  ensure (widget.componentId? == some saveButtonId) "Root widget should preserve assigned component id"
  match widget.style? with
  | some style =>
      ensure (style.borderWidth == 1.0) s!"Expected outline border width 1.0, got {style.borderWidth}"
      ensure (match style.width with | .length w => w == 180 | _ => false)
        "Expected explicit width 180"
      ensure (match style.height with | .length h => h == 40 | _ => false)
        "Expected explicit height 40"
  | none =>
      ensure false "Expected a styled root widget"

def main : IO UInt32 := runAllSuites
