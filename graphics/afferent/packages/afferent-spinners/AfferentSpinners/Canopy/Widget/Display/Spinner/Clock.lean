/-
  Clock Spinner - Clock hands rotating at different speeds
-/
import Afferent.UI.Canopy.Core
import AfferentSpinners.Canopy.Widget.Display.Spinner.Core

namespace AfferentSpinners.Canopy.Spinner

open Afferent.Arbor hiding Event
open Afferent
open Linalg

/-- Clock: Clock hands rotating at different speeds. -/
def clockSpec (t : Float) (color : Color) (dims : Dimensions) : CustomSpec := {
  measure := fun _ _ => (dims.size, dims.size)
  collect := fun layout =>
    let rect := layout.contentRect
    let cx := rect.x + dims.size / 2
    let cy := rect.y + dims.size / 2
    let radius := dims.size * 0.4
    let center := Point.mk' cx cy

    -- Second hand (fast), minute hand (slower), hour hand (slowest)
    let secondAngle := t * Float.twoPi - Float.halfPi
    let minuteAngle := t * Float.twoPi / 12.0 - Float.halfPi
    let hourAngle := t * Float.twoPi / 60.0 - Float.halfPi

    let hourEnd := Point.mk' (cx + radius * 0.4 * Float.cos hourAngle)
                             (cy + radius * 0.4 * Float.sin hourAngle)
    let minuteEnd := Point.mk' (cx + radius * 0.65 * Float.cos minuteAngle)
                               (cy + radius * 0.65 * Float.sin minuteAngle)
    let secondEnd := Point.mk' (cx + radius * 0.85 * Float.cos secondAngle)
                               (cy + radius * 0.85 * Float.sin secondAngle)

    let hourColor := color.withAlpha 0.8
    let minuteColor := color.withAlpha 0.9

    do
      CanvasM.strokeCircleColor center radius (color.withAlpha 0.3) (dims.strokeWidth * 0.5)

      -- Hour hand (thickest)
      CanvasM.strokeLineColor center hourEnd hourColor (dims.strokeWidth * 1.5)

      -- Minute hand
      CanvasM.strokeLineColor center minuteEnd minuteColor dims.strokeWidth

      -- Second hand (thinnest)
      CanvasM.strokeLineColor center secondEnd color (dims.strokeWidth * 0.6)

      CanvasM.fillCircleColor center (dims.strokeWidth * 0.8) color
}

end AfferentSpinners.Canopy.Spinner
