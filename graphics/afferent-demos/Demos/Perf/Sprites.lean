/-
  Sprites Performance Test - Bunnymark-style textured sprites
-/
import Afferent
import Afferent.UI.Arbor
import Demos.Core.Demo
import Trellis

open Afferent CanvasM

namespace Demos

def spritesPerfWidget (screenScale : Float) (font : Font) (texture : FFI.Texture)
    (particles : Render.Dynamic.ParticleState) (halfSize : Float) : Afferent.Arbor.WidgetBuilder := do
  Afferent.Arbor.custom (spec := {
    measure := fun _ _ => (0, 0)
    collect := fun layout => do
      withContentRect layout fun _ _ => do
        resetTransform
        setFillColor Color.white
        fillTextXY
          s!"Sprites: {particles.count} textured sprites (Space to advance)"
          (20 * screenScale) (30 * screenScale) font
        fillDynamicSprites texture particles halfSize
  }) (style := { flexItem := some (Trellis.FlexItem.growing 1) })

def stepSpritesPerfFrame (c : Canvas) (dt : Float) (font : Font)
    (particles : Render.Dynamic.ParticleState) (texture : FFI.Texture) (halfSize : Float)
    (screenScale : Float) : IO (Canvas × Render.Dynamic.ParticleState) := do
  let nextParticles := particles.updateBouncing dt halfSize
  let c ← run' c do
    resetTransform
    setFillColor Color.white
    fillTextXY
      s!"Sprites: {nextParticles.count} textured sprites (Space to advance)"
      (20 * screenScale) (30 * screenScale) font
    fillDynamicSprites texture nextParticles halfSize
  pure (c, nextParticles)

end Demos
