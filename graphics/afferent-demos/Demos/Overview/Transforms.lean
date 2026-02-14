/-
  Transforms Demo - Cards showing translation, scaling, rotation, and nesting.
-/
import Afferent
import Afferent.UI.Widget
import Afferent.UI.Arbor
import Demos.Overview.Card
import Trellis
import Linalg.Core

open Afferent.Arbor
open Trellis (EdgeInsets)
open Linalg

namespace Demos

/-- Base reference shapes (rect + circle). -/
private def referenceCommands (r : Rect) (color : Color) : RenderM Unit := do
  let rect := Rect.mk' (r.origin.x + r.size.width * 0.15)
    (r.origin.y + r.size.height * 0.3)
    (r.size.width * 0.3) (r.size.height * 0.2)
  let center := Point.mk' (r.origin.x + r.size.width * 0.7)
    (r.origin.y + r.size.height * 0.4)
  let radius := minSide r * 0.18
  RenderM.fillRect rect color
  RenderM.fillPath (Afferent.Path.circle center radius) color

/-- Translation example. -/
private def translateCommands (r : Rect) : RenderM Unit := do
  let dx := r.size.width * 0.12
  let dy := r.size.height * 0.08
  RenderM.pushTranslate dx dy
  referenceCommands r Afferent.Color.red
  RenderM.popTransform

/-- Scaling example. -/
private def scaleCommands (r : Rect) : RenderM Unit := do
  let center := rectCenter r
  let rectW := r.size.width * 0.32
  let rectH := r.size.height * 0.2
  let circleR := minSide r * 0.16
  RenderM.pushTranslate center.x center.y
  RenderM.pushScale 1.3 1.3
  RenderM.fillRect (Rect.mk' (-rectW / 2) (-rectH / 2) rectW rectH) Afferent.Color.green
  RenderM.fillPath (Afferent.Path.circle ⟨rectW * 0.6, 0⟩ circleR) Afferent.Color.green
  RenderM.popTransform
  RenderM.popTransform

/-- Rotation fan example. -/
private def rotateFanCommands (r : Rect) : RenderM Unit := do
  let center := rectCenter r
  let rectW := r.size.width * 0.35
  let rectH := r.size.height * 0.1
  RenderM.pushTranslate center.x center.y
  for i in [:8] do
    let angle := i.toFloat * (Float.pi / 4.0)
    let color := Afferent.Color.rgba
      (0.5 + 0.5 * Float.cos angle)
      (0.5 + 0.5 * Float.sin angle)
      0.5
      0.8
    RenderM.pushRotate angle
    RenderM.fillRect (Rect.mk' (rectW * 0.1) (-rectH / 2) rectW rectH) color
    RenderM.popTransform
  RenderM.popTransform

/-- Scaled circles example. -/
private def scaledCircleCommands (r : Rect) : RenderM Unit := do
  let center := rectCenter r
  let spacing := r.size.width * 0.2
  let startX := center.x - spacing * 1.5
  let baseRadius := minSide r * 0.18
  for i in [:4] do
    let s := 0.6 + i.toFloat * 0.25
    let x := startX + i.toFloat * spacing
    let color := Afferent.Color.rgba
      (1.0 - i.toFloat * 0.15)
      (i.toFloat * 0.2)
      (0.5 + i.toFloat * 0.1)
      1.0
    RenderM.pushTranslate x center.y
    RenderM.pushScale s s
    RenderM.fillPath (Afferent.Path.circle ⟨0, 0⟩ baseRadius) color
    RenderM.popTransform
    RenderM.popTransform

/-- Combined rotate + scale star. -/
private def combinedCommands (r : Rect) : RenderM Unit := do
  let center := rectCenter r
  let radius := minSide r * 0.35
  RenderM.pushTranslate center.x center.y
  RenderM.pushRotate (Float.pi / 6.0)
  RenderM.pushScale 1.2 0.8
  RenderM.fillPath (Afferent.Path.star ⟨0, 0⟩ radius (radius * 0.5) 5) Afferent.Color.yellow
  RenderM.popTransform
  RenderM.popTransform
  RenderM.popTransform

/-- Nested transforms (concentric circles). -/
private def nestedCommands (r : Rect) : RenderM Unit := do
  let center := rectCenter r
  let radius := minSide r * 0.35
  RenderM.pushTranslate center.x center.y
  RenderM.fillPath (Afferent.Path.circle ⟨0, 0⟩ radius) Afferent.Color.blue
  RenderM.pushScale 0.6 0.6
  RenderM.fillPath (Afferent.Path.circle ⟨0, 0⟩ radius) Afferent.Color.cyan
  RenderM.pushScale 0.5 0.5
  RenderM.fillPath (Afferent.Path.circle ⟨0, 0⟩ radius) Afferent.Color.white
  RenderM.popTransform
  RenderM.popTransform
  RenderM.popTransform

/-- Alpha blending demo. -/
private def alphaCommands (r : Rect) : RenderM Unit := do
  let center := rectCenter r
  let w := r.size.width * 0.45
  let h := r.size.height * 0.3
  let base := Rect.mk' (center.x - w / 2) (center.y - h / 2) w h
  RenderM.fillRect base (Afferent.Color.rgba 1.0 0.0 0.0 1.0)
  RenderM.fillRect (Rect.mk' (base.origin.x + w * 0.2) (base.origin.y + h * 0.2) w h)
    (Afferent.Color.rgba 0.0 0.0 1.0 0.5)
  RenderM.fillRect (Rect.mk' (base.origin.x + w * 0.4) (base.origin.y + h * 0.4) w h)
    (Afferent.Color.rgba 0.0 1.0 0.0 0.3)

/-- Orbiting squares demo. -/
private def orbitCommands (r : Rect) : RenderM Unit := do
  let center := rectCenter r
  let radius := minSide r * 0.32
  let size := minSide r * 0.12
  RenderM.pushTranslate center.x center.y
  for i in [:6] do
    let angle := i.toFloat * (Float.twoPi / 6.0)
    let color := Afferent.Color.rgba
      (if i % 2 == 0 then 1.0 else 0.5)
      (if i % 3 == 0 then 1.0 else 0.3)
      (if i % 2 == 1 then 1.0 else 0.2)
      1.0
    RenderM.pushRotate angle
    RenderM.pushTranslate radius 0
    RenderM.fillRect (Rect.mk' (-size / 2) (-size / 2) size size) color
    RenderM.popTransform
    RenderM.popTransform
  RenderM.popTransform

/-- Skew-like effect via rotate + scale. -/
private def skewCommands (r : Rect) : RenderM Unit := do
  let center := rectCenter r
  let rectW := r.size.width * 0.5
  let rectH := r.size.height * 0.3
  RenderM.pushTranslate center.x center.y
  RenderM.pushRotate (Float.pi / 12.0)
  RenderM.pushScale 1.5 0.7
  RenderM.fillRect (Rect.mk' (-rectW / 2) (-rectH / 2) rectW rectH) Afferent.Color.magenta
  RenderM.popTransform
  RenderM.popTransform
  RenderM.popTransform

/-- Hearts with different transforms. -/
private def heartCommands (r : Rect) : RenderM Unit := do
  let center := rectCenter r
  let radius := minSide r * 0.35
  RenderM.pushTranslate (center.x - radius * 0.6) center.y
  RenderM.fillPath (Afferent.Path.heart ⟨0, 0⟩ radius) Afferent.Color.red
  RenderM.popTransform
  RenderM.pushTranslate (center.x + radius * 0.6) center.y
  RenderM.pushRotate (Float.pi / 8.0)
  RenderM.pushScale 0.7 0.7
  RenderM.fillPath (Afferent.Path.heart ⟨0, 0⟩ radius) Afferent.Color.magenta
  RenderM.popTransform
  RenderM.popTransform
  RenderM.popTransform

/-- Transform cards rendered as widgets. -/
def transformsWidget (labelFont : FontId) : WidgetBuilder := do
  let cards : Array (String × CardDraw) := #[(
    "Reference", fun r => referenceCommands r Afferent.Color.white
  ), (
    "Translate", translateCommands
  ), (
    "Scale", scaleCommands
  ), (
    "Rotate Fan", rotateFanCommands
  ), (
    "Scale Series", scaledCircleCommands
  ), (
    "Rotate+Scale", combinedCommands
  ), (
    "Nested", nestedCommands
  ), (
    "Alpha", alphaCommands
  ), (
    "Orbit", orbitCommands
  ), (
    "Skew", skewCommands
  ), (
    "Hearts", heartCommands
  )]
  let widgets := cards.map fun (label, draw) => demoCardFlex labelFont label draw
  gridFlex 4 10 4 widgets (EdgeInsets.uniform 10)

/-- Curated subset of transforms for responsive grid display. -/
def transformsSubset : Array (String × CardDraw) := #[
  ("Reference", fun r => referenceCommands r Afferent.Color.white),
  ("Translate", translateCommands),
  ("Scale", scaleCommands),
  ("Rotate Fan", rotateFanCommands),
  ("Nested", nestedCommands),
  ("Alpha", alphaCommands),
  ("Orbit", orbitCommands),
  ("Skew", skewCommands),
  ("Hearts", heartCommands)
]

/-- Responsive transforms widget that fills available space. -/
def transformsWidgetFlex (labelFont : FontId) : WidgetBuilder := do
  let widgets := transformsSubset.map fun (label, draw) => demoCardFlex labelFont label draw
  gridFlex 3 3 4 widgets

end Demos
