/-
  Strokes Demo - Cards showing line widths and stroked paths.
-/
import Afferent
import Afferent.UI.Widget
import Afferent.UI.Arbor
import Demos.Overview.Card
import Trellis
import Linalg.Core

open Afferent Afferent.Arbor
open Trellis (EdgeInsets)
open Linalg

namespace Demos

/-- Build a straight line path. -/
private def linePath (p1 p2 : Point) : Afferent.Path :=
  Afferent.Path.empty.moveTo p1 |>.lineTo p2

/-- Stroke a circle via path. -/
private def strokeCircle (center : Point) (radius : Float) (color : Color) (lineWidth : Float) : CanvasM Unit := do
  CanvasM.strokePathColor (Afferent.Path.circle center radius) color lineWidth

/-- Stroke an ellipse via path. -/
private def strokeEllipse (center : Point) (rx ry : Float) (color : Color) (lineWidth : Float) : CanvasM Unit := do
  CanvasM.strokePathColor (Afferent.Path.ellipse center rx ry) color lineWidth

/-- Rect stroke width examples. -/
private def rectWidthCommands (r : Rect) : CanvasM Unit := do
  let w := r.size.width * 0.18
  let h := r.size.height * 0.45
  let y := r.origin.y + r.size.height * 0.28
  let startX := r.origin.x + r.size.width * 0.08
  let spacing := r.size.width * 0.22
  CanvasM.strokeRectColor (Rect.mk' startX y w h) Afferent.Color.white 1.0
  CanvasM.strokeRectColor (Rect.mk' (startX + spacing) y w h) Afferent.Color.yellow 2.0
  CanvasM.strokeRectColor (Rect.mk' (startX + spacing * 2) y w h) Afferent.Color.cyan 4.0
  CanvasM.strokeRectColor (Rect.mk' (startX + spacing * 3) y w h) Afferent.Color.magenta 8.0

/-- Circle stroke widths. -/
private def circleWidthCommands (r : Rect) : CanvasM Unit := do
  let y := r.origin.y + r.size.height * 0.5
  let radius := minSide r * 0.18
  let startX := r.origin.x + r.size.width * 0.2
  let spacing := r.size.width * 0.28
  strokeCircle ⟨startX, y⟩ radius Afferent.Color.red 2.0
  strokeCircle ⟨startX + spacing, y⟩ radius Afferent.Color.green 4.0
  strokeCircle ⟨startX + spacing * 2, y⟩ radius Afferent.Color.blue 6.0

/-- Horizontal line widths. -/
private def lineWidthCommands (r : Rect) : CanvasM Unit := do
  let x0 := r.origin.x + r.size.width * 0.1
  let x1 := r.origin.x + r.size.width * 0.9
  let y0 := r.origin.y + r.size.height * 0.25
  let step := r.size.height * 0.15
  CanvasM.strokePathColor (linePath ⟨x0, y0⟩ ⟨x1, y0⟩) Afferent.Color.white 1.0
  CanvasM.strokePathColor (linePath ⟨x0, y0 + step⟩ ⟨x1, y0 + step⟩) Afferent.Color.white 2.0
  CanvasM.strokePathColor (linePath ⟨x0, y0 + step * 2⟩ ⟨x1, y0 + step * 2⟩) Afferent.Color.white 4.0
  CanvasM.strokePathColor (linePath ⟨x0, y0 + step * 3⟩ ⟨x1, y0 + step * 3⟩) Afferent.Color.white 8.0

/-- Diagonal line examples. -/
private def diagonalCommands (r : Rect) : CanvasM Unit := do
  let x0 := r.origin.x + r.size.width * 0.15
  let y0 := r.origin.y + r.size.height * 0.25
  let x1 := r.origin.x + r.size.width * 0.85
  let y1 := r.origin.y + r.size.height * 0.75
  CanvasM.strokePathColor (linePath ⟨x0, y0⟩ ⟨x1, y1⟩) Afferent.Color.yellow 2.0
  CanvasM.strokePathColor (linePath ⟨x0 + 10, y0⟩ ⟨x1 + 10, y1⟩) Afferent.Color.cyan 3.0
  CanvasM.strokePathColor (linePath ⟨x0 + 20, y0⟩ ⟨x1 + 20, y1⟩) Afferent.Color.magenta 4.0

/-- Rounded rectangle strokes. -/
private def roundedRectCommands (r : Rect) : CanvasM Unit := do
  let w := r.size.width * 0.25
  let h := r.size.height * 0.45
  let y := r.origin.y + r.size.height * 0.28
  let startX := r.origin.x + r.size.width * 0.1
  let spacing := r.size.width * 0.3
  CanvasM.strokeRectColor (Rect.mk' startX y w h) Afferent.Color.orange 3.0 10
  CanvasM.strokeRectColor (Rect.mk' (startX + spacing) y w h) Afferent.Color.green 4.0 20
  CanvasM.strokeRectColor (Rect.mk' (startX + spacing * 2) y w h) Afferent.Color.purple 5.0 30

/-- Ellipse stroke examples. -/
private def ellipseCommands (r : Rect) : CanvasM Unit := do
  let y := r.origin.y + r.size.height * 0.5
  let startX := r.origin.x + r.size.width * 0.2
  let spacing := r.size.width * 0.28
  strokeEllipse ⟨startX, y⟩ (minSide r * 0.3) (minSide r * 0.16) Afferent.Color.red 2.0
  strokeEllipse ⟨startX + spacing, y⟩ (minSide r * 0.16) (minSide r * 0.28) Afferent.Color.green 3.0
  strokeEllipse ⟨startX + spacing * 2, y⟩ (minSide r * 0.24) (minSide r * 0.24) Afferent.Color.blue 4.0

/-- Star stroke examples. -/
private def starCommands (r : Rect) : CanvasM Unit := do
  let y := r.origin.y + r.size.height * 0.5
  let startX := r.origin.x + r.size.width * 0.22
  let spacing := r.size.width * 0.26
  CanvasM.strokePathColor (Afferent.Path.star ⟨startX, y⟩ (minSide r * 0.25) (minSide r * 0.12) 5) Afferent.Color.yellow 2.0
  CanvasM.strokePathColor (Afferent.Path.star ⟨startX + spacing, y⟩ (minSide r * 0.22) (minSide r * 0.1) 6) Afferent.Color.cyan 3.0
  CanvasM.strokePathColor (Afferent.Path.star ⟨startX + spacing * 2, y⟩ (minSide r * 0.2) (minSide r * 0.09) 8) Afferent.Color.magenta 4.0

/-- Polygon strokes. -/
private def polygonCommands (r : Rect) : CanvasM Unit := do
  let y := r.origin.y + r.size.height * 0.5
  let startX := r.origin.x + r.size.width * 0.14
  let spacing := r.size.width * 0.18
  CanvasM.strokePathColor (Afferent.Path.polygon ⟨startX, y⟩ (minSide r * 0.18) 3) Afferent.Color.red 2.0
  CanvasM.strokePathColor (Afferent.Path.polygon ⟨startX + spacing, y⟩ (minSide r * 0.18) 4) Afferent.Color.orange 2.0
  CanvasM.strokePathColor (Afferent.Path.polygon ⟨startX + spacing * 2, y⟩ (minSide r * 0.18) 5) Afferent.Color.yellow 2.0
  CanvasM.strokePathColor (Afferent.Path.polygon ⟨startX + spacing * 3, y⟩ (minSide r * 0.18) 6) Afferent.Color.green 2.0
  CanvasM.strokePathColor (Afferent.Path.polygon ⟨startX + spacing * 4, y⟩ (minSide r * 0.18) 8) Afferent.Color.cyan 2.0

/-- Heart stroke example. -/
private def heartCommands (r : Rect) : CanvasM Unit := do
  let center := rectCenter r
  CanvasM.strokePathColor (Afferent.Path.heart center (minSide r * 0.45)) Afferent.Color.red 3.0

/-- Combined fill + stroke example. -/
private def fillStrokeCommands (r : Rect) : CanvasM Unit := do
  let center := rectCenter r
  let circleR := minSide r * 0.25
  let rectW := minSide r * 0.45
  let rectH := minSide r * 0.32
  CanvasM.fillPathColor (Afferent.Path.circle ⟨center.x - rectW * 0.4, center.y⟩ circleR) (Afferent.Color.hsva 0.667 0.75 0.8 1.0)
  CanvasM.strokePathColor (Afferent.Path.circle ⟨center.x - rectW * 0.4, center.y⟩ circleR) Afferent.Color.white 3.0
  CanvasM.fillPathColor (Afferent.Path.roundedRect (Rect.mk' (center.x + rectW * 0.05) (center.y - rectH / 2) rectW rectH) 12)
    (Afferent.Color.hsva 0.0 0.75 0.8 1.0)
  CanvasM.strokePathColor (Afferent.Path.roundedRect (Rect.mk' (center.x + rectW * 0.05) (center.y - rectH / 2) rectW rectH) 12)
    Afferent.Color.white 2.0

/-- Zigzag path stroke. -/
private def zigzagCommands (r : Rect) : CanvasM Unit := do
  let x0 := r.origin.x + r.size.width * 0.1
  let y0 := r.origin.y + r.size.height * 0.65
  let dx := r.size.width * 0.1
  let dy := r.size.height * 0.25
  let zigzag := Afferent.Path.empty
    |>.moveTo ⟨x0, y0⟩
    |>.lineTo ⟨x0 + dx, y0 - dy⟩
    |>.lineTo ⟨x0 + dx * 2, y0⟩
    |>.lineTo ⟨x0 + dx * 3, y0 - dy⟩
    |>.lineTo ⟨x0 + dx * 4, y0⟩
    |>.lineTo ⟨x0 + dx * 5, y0 - dy⟩
    |>.lineTo ⟨x0 + dx * 6, y0⟩
  CanvasM.strokePathColor zigzag Afferent.Color.yellow 3.0

/-- Wave path stroke. -/
private def waveCommands (r : Rect) : CanvasM Unit := do
  let x0 := r.origin.x + r.size.width * 0.1
  let y0 := r.origin.y + r.size.height * 0.6
  let w := r.size.width * 0.8
  let h := r.size.height * 0.25
  let wave := Afferent.Path.empty
    |>.moveTo ⟨x0, y0⟩
    |>.bezierCurveTo ⟨x0 + w * 0.2, y0 - h⟩ ⟨x0 + w * 0.4, y0 + h⟩ ⟨x0 + w * 0.6, y0⟩
    |>.bezierCurveTo ⟨x0 + w * 0.8, y0 - h⟩ ⟨x0 + w, y0 + h⟩ ⟨x0 + w, y0⟩
  CanvasM.strokePathColor wave Afferent.Color.cyan 4.0

/-- Spiral-like path stroke. -/
private def spiralCommands (r : Rect) : CanvasM Unit := do
  let x0 := r.origin.x + r.size.width * 0.15
  let y0 := r.origin.y + r.size.height * 0.55
  let w := r.size.width * 0.7
  let h := r.size.height * 0.3
  let spiral := Afferent.Path.empty
    |>.moveTo ⟨x0, y0⟩
    |>.quadraticCurveTo ⟨x0 + w * 0.2, y0 - h⟩ ⟨x0 + w * 0.4, y0⟩
    |>.quadraticCurveTo ⟨x0 + w * 0.6, y0 + h⟩ ⟨x0 + w * 0.8, y0⟩
    |>.quadraticCurveTo ⟨x0 + w, y0 - h * 0.6⟩ ⟨x0 + w, y0 + h * 0.4⟩
  CanvasM.strokePathColor spiral Afferent.Color.magenta 3.0

/-- Arc stroke examples. -/
private def arcCommands (r : Rect) : CanvasM Unit := do
  let y := r.origin.y + r.size.height * 0.6
  let startX := r.origin.x + r.size.width * 0.2
  let spacing := r.size.width * 0.28
  CanvasM.strokePathColor (Afferent.Path.arcPath ⟨startX, y⟩ (minSide r * 0.22) 0 Float.pi) Afferent.Color.red 3.0
  CanvasM.strokePathColor (Afferent.Path.arcPath ⟨startX + spacing, y⟩ (minSide r * 0.22) 0 (Float.pi * 1.5)) Afferent.Color.green 3.0
  CanvasM.strokePathColor (Afferent.Path.semicircle ⟨startX + spacing * 2, y⟩ (minSide r * 0.22) 0) Afferent.Color.blue 4.0

/-- Pie slice outlines. -/
private def pieCommands (r : Rect) : CanvasM Unit := do
  let y := r.origin.y + r.size.height * 0.6
  let startX := r.origin.x + r.size.width * 0.3
  let spacing := r.size.width * 0.35
  CanvasM.strokePathColor (Afferent.Path.pie ⟨startX, y⟩ (minSide r * 0.22) 0 Float.halfPi) Afferent.Color.yellow 2.0
  CanvasM.strokePathColor (Afferent.Path.pie ⟨startX + spacing, y⟩ (minSide r * 0.22) (Float.pi * 0.25) (Float.pi * 1.25)) Afferent.Color.cyan 2.0

/-- Arrow stroke. -/
private def arrowCommands (r : Rect) : CanvasM Unit := do
  let cx := r.origin.x + r.size.width * 0.5
  let cy := r.origin.y + r.size.height * 0.55
  let arrow := Afferent.Path.empty
    |>.moveTo ⟨cx - 30, cy - 20⟩
    |>.lineTo ⟨cx + 30, cy⟩
    |>.lineTo ⟨cx - 30, cy + 20⟩
    |>.moveTo ⟨cx - 30, cy⟩
    |>.lineTo ⟨cx + 30, cy⟩
  CanvasM.strokePathColor arrow Afferent.Color.white 3.0

/-- Cross stroke. -/
private def crossCommands (r : Rect) : CanvasM Unit := do
  let cx := r.origin.x + r.size.width * 0.5
  let cy := r.origin.y + r.size.height * 0.55
  let cross := Afferent.Path.empty
    |>.moveTo ⟨cx, cy - 30⟩
    |>.lineTo ⟨cx, cy + 30⟩
    |>.moveTo ⟨cx - 30, cy⟩
    |>.lineTo ⟨cx + 30, cy⟩
  CanvasM.strokePathColor cross Afferent.Color.red 4.0

/-- Strokes rendered as cards in a grid. -/
def strokesWidget (labelFont : FontId) : WidgetBuilder := do
  let cards : Array (String × CardDraw) := #[(
    "Rect Widths", fun r => rectWidthCommands r
  ), (
    "Circle Widths", fun r => circleWidthCommands r
  ), (
    "Line Widths", fun r => lineWidthCommands r
  ), (
    "Diagonals", fun r => diagonalCommands r
  ), (
    "Rounded Rects", fun r => roundedRectCommands r
  ), (
    "Ellipses", fun r => ellipseCommands r
  ), (
    "Stars", fun r => starCommands r
  ), (
    "Polygons", fun r => polygonCommands r
  ), (
    "Heart", fun r => heartCommands r
  ), (
    "Fill+Stroke", fun r => fillStrokeCommands r
  ), (
    "Zigzag", fun r => zigzagCommands r
  ), (
    "Wave", fun r => waveCommands r
  ), (
    "Spiral", fun r => spiralCommands r
  ), (
    "Arcs", fun r => arcCommands r
  ), (
    "Pie Outlines", fun r => pieCommands r
  ), (
    "Arrow", fun r => arrowCommands r
  ), (
    "Cross", fun r => crossCommands r
  )]
  let widgets := cards.map fun (label, draw) => demoCardFlex labelFont label draw
  gridFlex 4 10 4 widgets (EdgeInsets.uniform 10)

/-- Curated subset of strokes for responsive grid display. -/
def strokesSubset : Array (String × CardDraw) := #[
  ("Rect Widths", fun r => rectWidthCommands r),
  ("Circle Widths", fun r => circleWidthCommands r),
  ("Line Widths", fun r => lineWidthCommands r),
  ("Rounded Rects", fun r => roundedRectCommands r),
  ("Stars", fun r => starCommands r),
  ("Fill+Stroke", fun r => fillStrokeCommands r),
  ("Wave", fun r => waveCommands r),
  ("Arcs", fun r => arcCommands r),
  ("Arrow", fun r => arrowCommands r)
]

/-- Responsive strokes widget that fills available space. -/
def strokesWidgetFlex (labelFont : FontId) : WidgetBuilder := do
  let widgets := strokesSubset.map fun (label, draw) => demoCardFlex labelFont label draw
  gridFlex 3 3 4 widgets

end Demos
