/-
  Gears Spinner - Two interlocking gears rotating in opposite directions
-/
import Afferent.UI.Canopy.Core
import AfferentSpinners.Canopy.Widget.Display.Spinner.Core

namespace AfferentSpinners.Canopy.Spinner

open Afferent.Arbor hiding Event
open Afferent
open Linalg

/-! ## Gear Geometry -/

/-- Build a gear polygon at `center` with per-tooth valleys and tips. -/
private def gearPolygonPoints (center : Point) (scale rotation : Float) (teeth : Nat) : Array Point := Id.run do
  let innerRadius : Float := 0.7   -- Inner radius as fraction of outer
  let toothDepth : Float := 0.3    -- Tooth extends outward by this fraction
  let outerRadius : Float := 1.0 + toothDepth  -- Total outer extent
  let numPoints := teeth * 4  -- 4 points per tooth
  let angleStep := Float.twoPi / numPoints.toFloat
  let mut points : Array Point := Array.mkEmpty numPoints
  for i in [:numPoints] do
    let angle := rotation + i.toFloat * angleStep
    let posInTooth := i % 4
    let r := match posInTooth with
      | 0 => innerRadius           -- Valley
      | 1 => outerRadius           -- Outer
      | 2 => outerRadius           -- Outer
      | _ => innerRadius           -- Valley
    let x := center.x + scale * r * Float.cos angle
    let y := center.y + scale * r * Float.sin angle
    points := points.push (Point.mk' x y)
  points

/-- Gears: Two interlocking gears rotating in opposite directions.
    Draws each gear directly from procedural polygon geometry. -/
def gearsSpec (t : Float) (color : Color) (dims : Dimensions) : CustomSpec := {
  measure := fun _ _ => (dims.size, dims.size)
  collect := fun layout =>
    let rect := layout.contentRect
    let cx := rect.x + dims.size / 2
    let cy := rect.y + dims.size / 2

    -- Two gears offset horizontally
    let gear1X := cx - dims.size * 0.18
    let gear1Y := cy
    let gear2X := cx + dims.size * 0.18
    let gear2Y := cy
    let gear1Scale := dims.size * 0.22  -- Scale to desired size
    let gear2Scale := dims.size * 0.18
    let gear1Teeth : Nat := 8
    let gear2Teeth : Nat := 6

    -- Gears rotate opposite directions, synced by teeth ratio
    let gear1Angle := t * Float.twoPi
    let gear2Angle := -t * Float.twoPi * (gear1Teeth.toFloat / gear2Teeth.toFloat)

    do
      -- Draw gear 1 (8-tooth)
      let gear1Points := gearPolygonPoints (Point.mk' gear1X gear1Y) gear1Scale gear1Angle gear1Teeth
      CanvasM.fillPolygon gear1Points color

      -- Draw gear 2 (6-tooth)
      let gear2Color := color.withAlpha 0.85
      let gear2Points := gearPolygonPoints (Point.mk' gear2X gear2Y) gear2Scale gear2Angle gear2Teeth
      CanvasM.fillPolygon gear2Points gear2Color

      -- Center holes
      CanvasM.fillCircleColor (Point.mk' gear1X gear1Y) (gear1Scale * 0.25) (color.withAlpha 0.3)
      CanvasM.fillCircleColor (Point.mk' gear2X gear2Y) (gear2Scale * 0.25) (color.withAlpha 0.25)
}

end AfferentSpinners.Canopy.Spinner
