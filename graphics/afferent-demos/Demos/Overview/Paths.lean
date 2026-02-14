/-
  Paths Cards - Non-convex polygons, arcTo, and transformed arcs.
  Rendered as Arbor card widgets.
-/
import Afferent
import Afferent.UI.Arbor
import Afferent.UI.Widget
import Trellis
import Demos.Overview.Card
import Linalg.Core

open Afferent Afferent.Arbor
open Trellis (EdgeInsets)
open Linalg

namespace Demos

structure PathsCardDef where
  label : String
  draw : CardDraw

private def pathsCommands (path : Afferent.Path) (color : Color) : CanvasM Unit := do
  CanvasM.fillPathColor path color

private def pathsCommandsStroke (path : Afferent.Path) (fillColor strokeColor : Color) (lineWidth : Float)
    : CanvasM Unit := do
  CanvasM.fillPathColor path fillColor
  CanvasM.strokePathColor path strokeColor lineWidth

private def pathsBaseRect (r : Rect) : Rect :=
  insetRect r (minSide r * 0.12)

private def pathsConcaveArrowPath (r : Rect) : Afferent.Path :=
  let b := pathsBaseRect r
  let x := b.origin.x
  let y := b.origin.y
  let w := b.size.width
  let h := b.size.height
  Afferent.Path.empty
    |>.moveTo ⟨x + w * 0.5, y⟩
    |>.lineTo ⟨x + w, y + h * 0.4⟩
    |>.lineTo ⟨x + w * 0.65, y + h * 0.4⟩
    |>.lineTo ⟨x + w * 0.65, y + h⟩
    |>.lineTo ⟨x + w * 0.35, y + h⟩
    |>.lineTo ⟨x + w * 0.35, y + h * 0.4⟩
    |>.lineTo ⟨x, y + h * 0.4⟩
    |>.closePath

private def pathsLShapePath (r : Rect) : Afferent.Path :=
  let b := pathsBaseRect r
  let x := b.origin.x
  let y := b.origin.y
  let w := b.size.width
  let h := b.size.height
  Afferent.Path.empty
    |>.moveTo ⟨x, y⟩
    |>.lineTo ⟨x + w, y⟩
    |>.lineTo ⟨x + w, y + h * 0.32⟩
    |>.lineTo ⟨x + w * 0.35, y + h * 0.32⟩
    |>.lineTo ⟨x + w * 0.35, y + h⟩
    |>.lineTo ⟨x, y + h⟩
    |>.closePath

private def pathsConcaveStarPath (r : Rect) : Afferent.Path := Id.run do
  let b := pathsBaseRect r
  let center := rectCenter b
  let outerR := minSide b * 0.48
  let innerR := outerR * 0.45
  let mut star := Afferent.Path.empty.moveTo ⟨center.x, center.y - outerR⟩
  for i in [1:10] do
    let angle := Float.pi / 5.0 * i.toFloat - Float.halfPi
    let radius := if i % 2 == 0 then outerR else innerR
    star := star.lineTo ⟨center.x + radius * Float.cos angle, center.y + radius * Float.sin angle⟩
  return star.closePath

private def pathsChevronPath (r : Rect) : Afferent.Path :=
  let b := pathsBaseRect r
  let x := b.origin.x
  let y := b.origin.y
  let w := b.size.width
  let h := b.size.height
  Afferent.Path.empty
    |>.moveTo ⟨x, y + h * 0.2⟩
    |>.lineTo ⟨x + w * 0.5, y + h * 0.8⟩
    |>.lineTo ⟨x + w, y + h * 0.2⟩
    |>.lineTo ⟨x + w, y + h * 0.45⟩
    |>.lineTo ⟨x + w * 0.5, y + h⟩
    |>.lineTo ⟨x, y + h * 0.45⟩
    |>.closePath

private def pathsRoundedRectPath (r : Rect) : Afferent.Path :=
  let b := pathsBaseRect r
  let cr := min b.size.width b.size.height * 0.18
  let x := b.origin.x
  let y := b.origin.y
  let w := b.size.width
  let h := b.size.height
  Afferent.Path.empty
    |>.moveTo ⟨x + cr, y⟩
    |>.lineTo ⟨x + w - cr, y⟩
    |>.arcTo ⟨x + w, y⟩ ⟨x + w, y + cr⟩ cr
    |>.lineTo ⟨x + w, y + h - cr⟩
    |>.arcTo ⟨x + w, y + h⟩ ⟨x + w - cr, y + h⟩ cr
    |>.lineTo ⟨x + cr, y + h⟩
    |>.arcTo ⟨x, y + h⟩ ⟨x, y + h - cr⟩ cr
    |>.lineTo ⟨x, y + cr⟩
    |>.arcTo ⟨x, y⟩ ⟨x + cr, y⟩ cr
    |>.closePath

private def pathsRoundedTrianglePath (r : Rect) : Afferent.Path :=
  let b := pathsBaseRect r
  let cx := b.origin.x + b.size.width / 2
  let topY := b.origin.y
  let bottomY := b.origin.y + b.size.height
  let leftX := b.origin.x
  let rightX := b.origin.x + b.size.width
  let p1 := Point.mk' cx topY
  let p2 := Point.mk' leftX bottomY
  let p3 := Point.mk' rightX bottomY
  let triR := minSide b * 0.12
  let mid12 := Point.mk' ((p1.x + p2.x) / 2) ((p1.y + p2.y) / 2)
  Afferent.Path.empty
    |>.moveTo mid12
    |>.arcTo p1 p3 triR
    |>.arcTo p3 p2 triR
    |>.arcTo p2 p1 triR
    |>.closePath

private def pathsPillTabPath (r : Rect) : Afferent.Path :=
  let b := pathsBaseRect r
  let tabH := b.size.height * 0.35
  let tabW := b.size.width * 0.75
  let x := b.origin.x + (b.size.width - tabW) / 2
  let y := b.origin.y + (b.size.height - tabH) / 2
  let tabR := tabH / 2
  Afferent.Path.empty
    |>.moveTo ⟨x + tabR, y⟩
    |>.lineTo ⟨x + tabW - tabR, y⟩
    |>.arcTo ⟨x + tabW, y⟩ ⟨x + tabW, y + tabH / 2⟩ tabR
    |>.arcTo ⟨x + tabW, y + tabH⟩ ⟨x + tabW - tabR, y + tabH⟩ tabR
    |>.lineTo ⟨x + tabR, y + tabH⟩
    |>.arcTo ⟨x, y + tabH⟩ ⟨x, y + tabH / 2⟩ tabR
    |>.arcTo ⟨x, y⟩ ⟨x + tabR, y⟩ tabR
    |>.closePath

private def pathsCirclePath (r : Rect) : Afferent.Path :=
  Afferent.Path.circle (rectCenter r) (minSide r * 0.38)

private def pathsScaledCircleCommands (r : Rect) (sx sy : Float) (color : Color) : CanvasM Unit := do
  let center := rectCenter r
  let radius := minSide r * 0.28
  let path := Afferent.Path.circle ⟨0, 0⟩ radius
  CanvasM.pushTranslate center.x center.y
  CanvasM.pushScale sx sy
  CanvasM.fillPathColor path color
  CanvasM.popTransform
  CanvasM.popTransform

private def pathsRotatedPieCommands (r : Rect) : CanvasM Unit := do
  let center := rectCenter r
  let radius := minSide r * 0.38
  let path := Afferent.Path.pie ⟨0, 0⟩ radius 0 Float.halfPi
  CanvasM.pushTranslate center.x center.y
  CanvasM.pushRotate (Float.pi / 6)
  CanvasM.fillPathColor path (Afferent.Color.orange)
  CanvasM.popTransform
  CanvasM.popTransform

private def pathsTransformedArcCommands (r : Rect) : CanvasM Unit := do
  let center := rectCenter r
  let radius := minSide r * 0.34
  let path := Afferent.Path.arcPath ⟨0, 0⟩ radius 0 (Float.pi * 1.5)
  let lineWidth := max 1.0 (radius * 0.12)
  CanvasM.pushTranslate center.x center.y
  CanvasM.pushRotate (Float.pi / 4)
  CanvasM.pushScale 1.5 0.75
  CanvasM.fillPathColor path Afferent.Color.cyan
  CanvasM.strokePathColor path Afferent.Color.white lineWidth
  CanvasM.popTransform
  CanvasM.popTransform
  CanvasM.popTransform

private def pathsCards : Array PathsCardDef := #[
  { label := "Concave Arrow", draw := fun r _reg => pathsCommands (pathsConcaveArrowPath r) Afferent.Color.blue },
  { label := "L-Shape", draw := fun r _reg => pathsCommands (pathsLShapePath r) Afferent.Color.green },
  { label := "Concave Star", draw := fun r _reg => pathsCommands (pathsConcaveStarPath r) Afferent.Color.yellow },
  { label := "Chevron", draw := fun r _reg => pathsCommands (pathsChevronPath r) Afferent.Color.magenta },
  { label := "Rounded Rect", draw := fun r _reg => pathsCommands (pathsRoundedRectPath r) Afferent.Color.cyan },
  { label := "Rounded Tri", draw := fun r _reg => pathsCommands (pathsRoundedTrianglePath r) Afferent.Color.orange },
  { label := "Pill Tab", draw := fun r _reg => pathsCommands (pathsPillTabPath r) Afferent.Color.purple },
  { label := "Circle 1:1", draw := fun r _reg => pathsCommands (pathsCirclePath r) (Afferent.Color.gray 0.6) },
  { label := "Scale 2:1", draw := fun r _reg => pathsScaledCircleCommands r 2.0 1.0 Afferent.Color.red },
  { label := "Scale 1:2", draw := fun r _reg => pathsScaledCircleCommands r 1.0 2.0 Afferent.Color.green },
  { label := "Pie 30deg", draw := fun r _reg => pathsRotatedPieCommands r },
  { label := "Arc 45deg", draw := fun r _reg => pathsTransformedArcCommands r }
]

/-- Paths rendered as cards in a grid (overview-friendly). -/
def pathsWidgetFlex (labelFont : FontId) : WidgetBuilder := do
  let cards := pathsCards.map (fun feature =>
    demoCardFlex labelFont feature.label feature.draw)
  gridFlex 3 4 4 cards (EdgeInsets.uniform 6)

end Demos
