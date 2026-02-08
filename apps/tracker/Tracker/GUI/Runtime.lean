import Reactive
import Afferent
import Afferent.UI.Arbor
import Afferent.UI.Widget
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Tracker.GUI.Types

namespace Tracker.GUI.Runtime

open Reactive Reactive.Host
open Afferent
open Afferent.FFI
open Afferent.Canopy.Reactive

private def mkTheme (fontId smallFontId : Afferent.Arbor.FontId) : Afferent.Canopy.Theme :=
  { Afferent.Canopy.Theme.dark with font := fontId, smallFont := smallFontId }

private def collectInteractiveNames
    (nameMap : Std.HashMap String Afferent.Arbor.WidgetId) : Array String :=
  nameMap.toList.foldl (fun acc entry => acc.push entry.1) #[]

def run (createApp : ReactiveM Tracker.GUI.GuiApp) : IO Unit := do
  FFI.init

  let screenScale ← FFI.getScreenScale
  let baseWidth : Float := 1200.0
  let baseHeight : Float := 760.0
  let physWidth := (baseWidth * screenScale).toUInt32
  let physHeight := (baseHeight * screenScale).toUInt32

  let mut canvas ← Canvas.create physWidth physHeight "Tracker"
  let uiFont ← Afferent.Font.load "/System/Library/Fonts/Monaco.ttf" (18 * screenScale).toUInt32
  let uiSmallFont ← Afferent.Font.load "/System/Library/Fonts/Monaco.ttf" (14 * screenScale).toUInt32

  let (fontRegistry, uiFontId) := FontRegistry.empty.register uiFont "tracker-ui"
  let (fontRegistry, uiSmallFontId) := fontRegistry.register uiSmallFont "tracker-ui-small"
  let theme := mkTheme uiFontId uiSmallFontId

  let spiderEnv ← SpiderEnv.new defaultErrorHandler
  let (events, inputs, app) ← (do
    let (events, inputs) ← createInputs fontRegistry theme (some uiFont)
    let app ← ReactiveM.run events createApp
    pure (events, inputs, app)
  ).run spiderEnv
  spiderEnv.postBuildTrigger ()

  let prevLeftDown ← IO.mkRef false
  let mut lastFrameMs ← IO.monoMsNow

  while !(← canvas.shouldClose) do
    canvas.pollEvents
    let nowMs ← IO.monoMsNow
    let dt := (nowMs - lastFrameMs).toFloat / 1000.0
    lastFrameMs := nowMs

    let ok ← canvas.beginFrame (Color.rgb 0.07 0.09 0.12)
    if ok then
      let (currentW, currentH) ← canvas.ctx.getCurrentSize

      let widgetBuilder ← app.render
      let widget := Afferent.Arbor.build widgetBuilder
      let measureResult ← runWithFonts fontRegistry (Afferent.Arbor.measureWidget widget currentW currentH)
      let measuredWidget := measureResult.widget
      let layouts := Trellis.layout measureResult.node currentW currentH
      let hitIndex := Afferent.Arbor.buildHitTestIndex measuredWidget layouts
      let nameMap := hitIndex.nameMap
      let interactiveNames := collectInteractiveNames nameMap
      events.registry.interactiveNames.set interactiveNames

      let (mouseX, mouseY) ← canvas.ctx.window.getMousePos
      let hitPath := Afferent.Arbor.hitTestPathIndexed hitIndex mouseX mouseY

      inputs.fireHover {
        x := mouseX
        y := mouseY
        hitPath := hitPath
        widget := measuredWidget
        layouts := layouts
        nameMap := nameMap
      }

      let buttons ← canvas.ctx.window.getMouseButtons
      let leftDown := (buttons &&& (1 : UInt8)) != (0 : UInt8)
      let wasLeftDown ← prevLeftDown.get
      if leftDown && !wasLeftDown then
        inputs.fireClick {
          click := { button := 0, x := mouseX, y := mouseY, modifiers := 0 }
          hitPath := hitPath
          widget := measuredWidget
          layouts := layouts
          nameMap := nameMap
        }
      if !leftDown && wasLeftDown then
        inputs.fireMouseUp {
          x := mouseX
          y := mouseY
          button := 0
          hitPath := hitPath
          widget := measuredWidget
          layouts := layouts
          nameMap := nameMap
        }
      prevLeftDown.set leftDown

      if ← canvas.hasKeyPressed then
        let keyCode ← canvas.getKeyCode
        let modifiers ← canvas.ctx.window.getModifiers
        let keyEvent : Afferent.Arbor.KeyEvent := {
          key := Afferent.Arbor.Key.fromKeyCode keyCode
          modifiers := Afferent.Arbor.Modifiers.fromBitmask modifiers
          isPress := true
        }
        inputs.fireKey { event := keyEvent, focusedWidget := none }
        canvas.clearKey

      let (scrollX, scrollY) ← canvas.ctx.window.getScrollDelta
      if scrollX != 0.0 || scrollY != 0.0 then
        inputs.fireScroll {
          scroll := { x := mouseX, y := mouseY, deltaX := scrollX, deltaY := scrollY }
          hitPath := hitPath
          widget := measuredWidget
          layouts := layouts
          nameMap := nameMap
        }
        canvas.ctx.window.clearScroll

      inputs.fireAnimationFrame dt

      canvas ← CanvasM.run' canvas do
        let _ ← Afferent.Widget.renderArborWidgetWithCustomAndStats fontRegistry widget currentW currentH
        pure ()
      canvas ← canvas.endFrame

  app.shutdown
  spiderEnv.currentScope.dispose
  uiFont.destroy
  uiSmallFont.destroy
  canvas.destroy

end Tracker.GUI.Runtime
