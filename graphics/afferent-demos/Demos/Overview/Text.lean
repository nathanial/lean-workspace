/-
  Text Demo - Cards showing font sizes, colors, and text on shapes.
-/
import Afferent
import Afferent.UI.Widget
import Afferent.UI.Arbor
import Demos.Overview.Card
import Trellis

open Afferent Afferent.Arbor
open Trellis (EdgeInsets)

namespace Demos

private structure TextCard where
  label : String
  draw : CardDraw

/-- Center a single line of text within the rect. -/
private def centeredText (text : String) (font : FontId) (color : Color)
    (r : Rect) (reg : Afferent.FontRegistry) : Afferent.CanvasM Unit := do
  CanvasM.fillTextBlockId reg text r font color .center .middle

/-- Text cards rendered as widgets. -/
def textWidget (fonts : DemoFonts) : WidgetBuilder := do
  let cards : Array TextCard := #[(
    { label := "Small", draw := fun r reg => centeredText "Small 16pt" fonts.small Afferent.Color.white r reg }
  ), (
    { label := "Medium", draw := fun r reg => centeredText "Medium 24pt" fonts.medium Afferent.Color.white r reg }
  ), (
    { label := "Large", draw := fun r reg => centeredText "Large 36pt" fonts.large Afferent.Color.white r reg }
  ), (
    { label := "Huge", draw := fun r reg => centeredText "Huge 48pt" fonts.huge Afferent.Color.white r reg }
  ), (
    { label := "Red", draw := fun r reg => centeredText "Red Text" fonts.medium Afferent.Color.red r reg }
  ), (
    { label := "Green", draw := fun r reg => centeredText "Green Text" fonts.medium Afferent.Color.green r reg }
  ), (
    { label := "Blue", draw := fun r reg => centeredText "Blue Text" fonts.medium Afferent.Color.blue r reg }
  ), (
    { label := "Yellow", draw := fun r reg => centeredText "Yellow Text" fonts.medium Afferent.Color.yellow r reg }
  ), (
    { label := "Cyan", draw := fun r reg => centeredText "Cyan Text" fonts.medium Afferent.Color.cyan r reg }
  ), (
    { label := "Magenta", draw := fun r reg => centeredText "Magenta Text" fonts.medium Afferent.Color.magenta r reg }
  ), (
    { label := "Headline",
      draw := fun r reg => centeredText "Afferent" fonts.large Afferent.Color.white r reg }
  ), (
    { label := "Text on Shape",
      draw := fun r reg => do
        let rect := Rect.mk' (r.origin.x + 8) (r.origin.y + r.size.height * 0.3) (r.size.width - 16) (r.size.height * 0.4)
        CanvasM.fillRectColor rect Afferent.Color.blue 6
        CanvasM.fillTextBlockId reg "Text on Shape" rect fonts.small Afferent.Color.white .center .middle }
  ), (
    { label := "Labels",
      draw := fun r reg => do
        let center := rectCenter r
        let radius := minSide r * 0.3
        CanvasM.fillPathColor (Afferent.Path.circle center radius) Afferent.Color.red
        CanvasM.fillTextBlockId reg "Labels" (Rect.mk' (center.x - radius) (center.y - 10) (radius * 2) 20)
          fonts.small Afferent.Color.white .center .middle }
  ), (
    { label := "Rounded Button",
      draw := fun r reg => do
        let rect := Rect.mk' (r.origin.x + 8) (r.origin.y + r.size.height * 0.3) (r.size.width - 16) (r.size.height * 0.4)
        CanvasM.fillRectColor rect Afferent.Color.green 10
        CanvasM.fillTextBlockId reg "Rounded" rect fonts.small Afferent.Color.black .center .middle }
  ), (
    { label := "Alphabet",
      draw := fun r reg => do
        let x := r.origin.x + 6
        let y1 := r.origin.y + r.size.height * 0.4
        let y2 := r.origin.y + r.size.height * 0.7
        CanvasM.fillTextId reg "ABCDEFGHIJKLMNOPQRSTUVWXYZ" x y1 fonts.small Afferent.Color.white
        CanvasM.fillTextId reg "abcdefghijklmnopqrstuvwxyz" x y2 fonts.small Afferent.Color.white }
  ), (
    { label := "Digits",
      draw := fun r reg =>
        let x := r.origin.x + 6
        let y := r.origin.y + r.size.height * 0.55
        CanvasM.fillTextId reg "0123456789 !@#$%^&*()" x y fonts.small Afferent.Color.white }
  ), (
    { label := "Transparent",
      draw := fun r reg => do
        let x := r.origin.x + 6
        let y0 := r.origin.y + r.size.height * 0.35
        let step := r.size.height * 0.22
        CanvasM.fillTextId reg "Semi-transparent" x y0 fonts.small (Afferent.Color.hsva 0.0 0.0 1.0 0.7)
        CanvasM.fillTextId reg "More transparent" x (y0 + step) fonts.small (Afferent.Color.hsva 0.0 0.0 1.0 0.4)
        CanvasM.fillTextId reg "Very faint" x (y0 + step * 2) fonts.small (Afferent.Color.hsva 0.0 0.0 1.0 0.2) }
  ), (
    { label := "Error",
      draw := fun r reg => do
        let rect := Rect.mk' (r.origin.x + 8) (r.origin.y + r.size.height * 0.3) (r.size.width - 16) (r.size.height * 0.4)
        CanvasM.fillRectColor rect (Afferent.Color.hsva 0.0 0.75 0.8 1.0) 6
        CanvasM.fillTextBlockId reg "Error" rect fonts.small Afferent.Color.white .center .middle }
  ), (
    { label := "Success",
      draw := fun r reg => do
        let rect := Rect.mk' (r.origin.x + 8) (r.origin.y + r.size.height * 0.3) (r.size.width - 16) (r.size.height * 0.4)
        CanvasM.fillRectColor rect (Afferent.Color.hsva 0.333 0.667 0.6 1.0) 6
        CanvasM.fillTextBlockId reg "Success" rect fonts.small Afferent.Color.white .center .middle }
  ), (
    { label := "Warning",
      draw := fun r reg => do
        let rect := Rect.mk' (r.origin.x + 8) (r.origin.y + r.size.height * 0.3) (r.size.width - 16) (r.size.height * 0.4)
        CanvasM.fillRectColor rect (Afferent.Color.hsva 0.119 0.875 0.8 1.0) 6
        CanvasM.fillTextBlockId reg "Warning" rect fonts.small Afferent.Color.black .center .middle }
  )]

  let widgets := cards.map fun card =>
    demoCardFlex fonts.label card.label card.draw
  gridFlex 4 10 4 widgets (EdgeInsets.uniform 10)

/-- Curated subset of text cards for responsive grid display. -/
def textSubset (fonts : DemoFonts) : Array (String × CardDraw) := #[
  ("Small", fun r reg => centeredText "Small" fonts.small Afferent.Color.white r reg),
  ("Medium", fun r reg => centeredText "Medium" fonts.medium Afferent.Color.white r reg),
  ("Large", fun r reg => centeredText "Large" fonts.large Afferent.Color.white r reg),
  ("Red", fun r reg => centeredText "Red" fonts.medium Afferent.Color.red r reg),
  ("Green", fun r reg => centeredText "Green" fonts.medium Afferent.Color.green r reg),
  ("Blue", fun r reg => centeredText "Blue" fonts.medium Afferent.Color.blue r reg),
  ("Yellow", fun r reg => centeredText "Yellow" fonts.medium Afferent.Color.yellow r reg),
  ("Cyan", fun r reg => centeredText "Cyan" fonts.medium Afferent.Color.cyan r reg),
  ("Magenta", fun r reg => centeredText "Magenta" fonts.medium Afferent.Color.magenta r reg)
]

/-- Responsive text widget that fills available space. -/
def textWidgetFlex (fonts : DemoFonts) : WidgetBuilder := do
  let widgets := (textSubset fonts).map fun (label, draw) => demoCardFlex fonts.label label draw
  gridFlex 3 3 4 widgets

end Demos
