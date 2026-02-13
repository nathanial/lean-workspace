/-
  Orbital Instanced Demo
  Demonstrates CPU orbit updates with GPU instancing.
-/
import Afferent
import Afferent.UI.Arbor
import Demos.Core.Demo
import Trellis
import Init.Data.FloatArray

open Afferent CanvasM

namespace Demos

def orbitalInstancedWidget (t : Float) (screenScale : Float)
    (windowW windowH : Float)
    (fontMedium : Font) (orbitalCount : Nat) (orbitalParams : FloatArray)
    (orbitalBuffer : FFI.FloatBuffer) : Afferent.Arbor.WidgetBuilder := do
  Afferent.Arbor.custom (spec := {
    measure := fun _ _ => (0, 0)
    collect := fun _ => #[]
  }) (style := { flexItem := some (Trellis.FlexItem.growing 1) })

end Demos
