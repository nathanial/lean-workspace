/-
  Heartbeat Spinner - Pulsing shape with ECG-like rhythm
-/
import Afferent.UI.Canopy.Core
import AfferentSpinners.Canopy.Widget.Display.Spinner.Core

namespace AfferentSpinners.Canopy.Spinner

open Afferent.Arbor hiding Event
open Afferent
open Linalg

/-- Heartbeat: Pulsing shape with ECG-like rhythm.
    Uses direct path rendering. -/
def heartbeatSpec (t : Float) (color : Color) (dims : Dimensions) : CustomSpec := {
  measure := fun _ _ => (dims.size, dims.size)
  collect := fun layout =>
    let rect := layout.contentRect
    let cx := rect.x + dims.size / 2
    let cy := rect.y + dims.size / 2
    let baseSize := dims.size * 0.25

    -- ECG-like timing: quick pulse, pause, repeat
    let cyclePos := t
    let scale := if cyclePos < 0.15 then
        1.0 + 0.3 * Float.sin (cyclePos / 0.15 * Float.pi)  -- First beat
      else if cyclePos < 0.3 then
        1.0 - 0.1 * Float.sin ((cyclePos - 0.15) / 0.15 * Float.pi)  -- Slight dip
      else if cyclePos < 0.45 then
        1.0 + 0.2 * Float.sin ((cyclePos - 0.3) / 0.15 * Float.pi)  -- Second beat
      else
        1.0  -- Rest

    do
      CanvasM.fillPathColor (Path.heart (Point.mk' cx cy) (baseSize * scale)) color
}

end AfferentSpinners.Canopy.Spinner
