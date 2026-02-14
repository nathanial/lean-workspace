/-
  DualRing Spinner - Two concentric rings rotating in opposite directions
-/
import Afferent.UI.Canopy.Core
import AfferentSpinners.Canopy.Widget.Display.Spinner.Core

namespace AfferentSpinners.Canopy.Spinner

open Afferent.Arbor hiding Event
open Afferent
open Linalg

/-- DualRing: Two concentric rings rotating in opposite directions.
    Note: `t` is raw elapsed time in seconds, not wrapped progress. -/
def dualRingSpec (t : Float) (color : Color) (dims : Dimensions) : CustomSpec := {
  measure := fun _ _ => (dims.size, dims.size)
  collect := fun layout =>
    let rect := layout.contentRect
    let cx := rect.x + dims.size / 2
    let cy := rect.y + dims.size / 2
    let outerRadius := (dims.size - dims.strokeWidth) / 2 - 2
    let innerRadius := outerRadius * 0.6
    -- Use raw time directly - cos/sin handle any angle value smoothly
    let outerAngle := t * Float.pi  -- Half rotation per second
    let innerAngle := -t * Float.pi * 1.5  -- Opposite direction, faster
    let innerColor := color.withAlpha 0.6
    let innerStrokeWidth := dims.strokeWidth * 0.7

    do
      -- Outer arc (180°)
      CanvasM.strokeArcColor (Point.mk' cx cy) outerRadius outerAngle Float.pi color dims.strokeWidth
      -- Inner arc (135°)
      CanvasM.strokeArcColor (Point.mk' cx cy) innerRadius innerAngle (Float.pi * 0.75) innerColor innerStrokeWidth
}

end AfferentSpinners.Canopy.Spinner
