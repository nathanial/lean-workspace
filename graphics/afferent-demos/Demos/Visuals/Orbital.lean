/-
  Orbital Demo
  Demonstrates CPU orbit updates with direct drawing.
-/
import Afferent
import Afferent.UI.Arbor
import Demos.Core.Demo
import Trellis
import Init.Data.FloatArray

open Afferent CanvasM

namespace Demos

def orbitalWidget (t : Float) (screenScale : Float)
    (fontMedium : Font) (orbitalCount : Nat) (orbitalParams : FloatArray)
    : Afferent.Arbor.WidgetBuilder := do
  Afferent.Arbor.custom (spec := {
    measure := fun _ _ => (0, 0)
    collect := fun layout => do
      withContentRect layout fun w h => do
        resetTransform
        setFillColor Color.white
        fillTextXY s!"Orbital: {orbitalCount} orbiting rects (Space to advance)"
          (20 * screenScale) (30 * screenScale) fontMedium
        let rect := layout.contentRect
        let centerX := rect.x + w * 0.5
        let centerY := rect.y + h * 0.5
        for i in [:orbitalCount] do
          let base := i * 5
          let phase := orbitalParams.get! base
          let radius := orbitalParams.get! (base + 1)
          let speed := orbitalParams.get! (base + 2)
          let hue := orbitalParams.get! (base + 3)
          let size := orbitalParams.get! (base + 4)
          let angle := phase + t * speed
          let x := centerX + radius * Float.cos angle
          let y := centerY + radius * Float.sin angle
          let animatedHue := hue + t * 0.2
          setFillColor (Color.hsva (animatedHue - Float.floor animatedHue) 1.0 1.0 1.0)
          fillRectXYWH (x - size) (y - size) (size * 2.0) (size * 2.0)
  }) (style := { flexItem := some (Trellis.FlexItem.growing 1) })

end Demos
