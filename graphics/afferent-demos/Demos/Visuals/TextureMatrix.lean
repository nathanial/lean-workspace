/-
  Texture Scale Demo
  Demonstrates scaling a sprite on the CPU.
-/
import Afferent
import Afferent.UI.Arbor
import Demos.Core.Demo
import Trellis

open Afferent CanvasM

namespace Demos

def textureMatrixWidget (t : Float) (screenScale : Float) (windowWidth windowHeight : Float)
    (fontMedium fontSmall : Font) (texture : FFI.Texture) : Afferent.Arbor.WidgetBuilder := do
  Afferent.Arbor.custom (spec := {
    measure := fun _ _ => (0, 0)
    collect := fun _ => #[]
  }) (style := { flexItem := some (Trellis.FlexItem.growing 1) })

end Demos
