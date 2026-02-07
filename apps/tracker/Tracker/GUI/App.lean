/-
  Tracker.GUI.App

  Minimal Afferent-powered GUI shell for Tracker.
-/
import Afferent

namespace Tracker.GUI

open Afferent
open Afferent.FFI

/-- Launch a minimal Tracker GUI window. -/
def run : IO Unit := do
  let screenScale ← FFI.getScreenScale

  let baseWidth : Float := 960.0
  let baseHeight : Float := 600.0
  let physWidth := (baseWidth * screenScale).toUInt32
  let physHeight := (baseHeight * screenScale).toUInt32

  let mut canvas ← Canvas.create physWidth physHeight "Tracker"
  let titleFont ← Font.loadSystemScaled "monaco" 44.0 screenScale

  while !(← canvas.shouldClose) do
    canvas.pollEvents

    let ok ← canvas.beginFrame (Color.rgb 0.08 0.10 0.14)
    if ok then
      canvas ← CanvasM.run' (canvas.resetTransform) do
        CanvasM.setFillColor Color.white
        CanvasM.fillTextXY "Tracker" (48.0 * screenScale) (96.0 * screenScale) titleFont

      canvas ← canvas.endFrame

  titleFont.destroy
  canvas.destroy

end Tracker.GUI
