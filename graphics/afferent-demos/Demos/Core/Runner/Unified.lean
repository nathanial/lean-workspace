/-
  Demo Runner - Unified visual demo loop.
-/
import Reactive
import Afferent
import Afferent.UI.Arbor
import Afferent.UI.Widget
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Demos.Core.Runner.Loading
import Demos.Core.Runner.Types
import Demos.Core.Runner.CanopyApp
import Demos.Perf.Lines
import Std.Data.HashMap
import Init.Data.FloatArray

set_option maxRecDepth 1024

open Reactive Reactive.Host
open Afferent CanvasM
open Afferent.Canopy.Reactive

namespace Demos

/-- Unified visual demo - single Canopy widget tree with demo tabs. -/
def unifiedDemo : IO Unit := do
  IO.println "Unified Canopy Demo Shell"
  IO.println "---------------------------"

  let screenScale ← FFI.getScreenScale
  IO.println s!"Screen scale factor: {screenScale}"

  let baseWidth : Float := 1920.0
  let baseHeight : Float := 1080.0
  let physWidth := (baseWidth * screenScale).toUInt32
  let physHeight := (baseHeight * screenScale).toUInt32
  IO.println s!"Physical resolution: {physWidth}x{physHeight}"

  let canvas ← Canvas.create physWidth physHeight "Afferent - Demo Shell"

  let circleRadius := 2.0 * screenScale
  let physWidthF := baseWidth * screenScale
  let physHeightF := baseHeight * screenScale

  let layoutW : Float := 1000.0
  let layoutH : Float := 800.0
  let layoutPadTop : Float := 60.0 * screenScale
  let calcLayout := fun (availW availH : Float) =>
    let layoutAvailW : Float := availW
    let layoutAvailH : Float := max 1.0 (availH - layoutPadTop)
    let layoutScale : Float := min (layoutAvailW / layoutW) (layoutAvailH / layoutH)
    let layoutOffsetX : Float := (layoutAvailW - layoutW * layoutScale) / 2.0
    let layoutOffsetY : Float := layoutPadTop + (layoutAvailH - layoutH * layoutScale) / 2.0
    (layoutOffsetX, layoutOffsetY, layoutScale)
  let (layoutOffsetX, layoutOffsetY, layoutScale) := calcLayout physWidthF physHeightF

  let lineWidth := 1.0 * screenScale

  let orbitalCount : Nat := 50000
  let minRadius : Float := 20.0 * screenScale
  let maxRadius : Float := (min physWidthF physHeightF) * 0.45
  let speedMin : Float := 0.3
  let speedMax : Float := 1.6
  let sizeMin : Float := 1.0 * screenScale
  let sizeMax : Float := 3.5 * screenScale

  let lineRef ← IO.mkRef (none : Option (Array Float × Nat))
  let _ ← IO.asTask (prio := .dedicated) do
    let lineSegments := Demos.buildLineSegments physWidthF physHeightF
    lineRef.set (some lineSegments)

  let orbitalRef ← IO.mkRef (none : Option FloatArray)
  let _ ← IO.asTask (prio := .dedicated) do
    let params := buildOrbitalParams orbitalCount minRadius maxRadius speedMin speedMax sizeMin sizeMax
    orbitalRef.set (some params)

  let startTime ← IO.monoMsNow

  let statsRef ← IO.mkRef ({} : RunnerStats)

  let renderLoop : IO (Canvas × AppState) := do
    let mut c := canvas
    let mut state : AppState := .loading {}
    let mut lastTime := startTime
    while !(← c.shouldClose) do
      let frameStartNs ← IO.monoNanosNow
      let beginFrameStartNs := frameStartNs
      let ok ← c.beginFrame Color.darkGray
      let beginFrameEndNs ← IO.monoNanosNow
      if ok then
        let now ← IO.monoMsNow
        let t := (now - startTime).toFloat / 1000.0
        let dt := (now - lastTime).toFloat / 1000.0
        lastTime := now
        match state with
        | .loading ls =>
            let ls ← advanceLoading ls screenScale c lineRef orbitalRef orbitalCount
            let progress := loadingProgress ls
            let label := loadingStatus ls
            c ← renderLoading c t screenScale progress label ls.fontSmall
            let assetsOpt ← toLoadedAssets ls screenScale circleRadius lineWidth orbitalCount
              physWidthF physHeightF physWidth physHeight layoutOffsetX layoutOffsetY layoutScale
            match assetsOpt with
            | some assets =>
                let initEnv := mkEnvFromAssets assets 0.0 0.0 0 (pure ()) c.ctx.window statsRef
                let theme : Afferent.Canopy.Theme := {
                  Afferent.Canopy.Theme.dark with
                  font := initEnv.fontCanopyId
                  smallFont := initEnv.fontCanopySmallId
                }
                let spiderEnv ← Reactive.Host.SpiderEnv.new Reactive.Host.defaultErrorHandler
                let (appState, events, inputs) ← (do
                  let (events, inputs) ← Afferent.Canopy.Reactive.createInputs initEnv.fontRegistry theme (some initEnv.fontCanopy)
                  let appState ← Afferent.Canopy.Reactive.ReactiveM.run events (createCanopyApp initEnv)
                  pure (appState, events, inputs)
                ).run spiderEnv
                spiderEnv.postBuildTrigger ()
                let initialRenderVersion ← appState.render.version
                let initialWidget ← appState.render.materialize
                state := .running {
                  assets := assets
                  render := appState.render
                  events := events
                  inputs := inputs
                  spiderEnv := spiderEnv
                  shutdown := appState.shutdown
                  cachedWidget := initialWidget
                  cachedRenderVersion := initialRenderVersion
                }
            | none =>
                state := .loading ls
            c ← c.endFrame
        | .running rs =>
            let mut rs := rs
            let inputStart ← IO.monoNanosNow
            let keyCode ← c.getKeyCode
            let click ← FFI.Window.getClick c.ctx.window
            let (mouseX, mouseY) ← FFI.Window.getMousePos c.ctx.window
            let (screenW, screenH) ← c.ctx.getCurrentSize
            if screenW != rs.assets.physWidthF || screenH != rs.assets.physHeightF then
              rs := { rs with assets := {
                rs.assets with
                physWidthF := screenW
                physHeightF := screenH
                physWidth := screenW.toUInt32
                physHeight := screenH.toUInt32
              } }

            let mut hoverPathOpt : Option (Array Afferent.Arbor.WidgetId) := none
            let mouseMoved := mouseX != rs.lastMouseX || mouseY != rs.lastMouseY
            match rs.inputSnapshot with
            | some snapshot =>
                let componentMap := snapshot.hitIndex.componentMap
                match click with
                | some ce =>
                    let hitPath := Afferent.Arbor.hitTestPathIndexed snapshot.hitIndex ce.x ce.y
                    let clickData : Afferent.Canopy.Reactive.ClickData := {
                      click := ce
                      hitPath := hitPath
                      layouts := snapshot.layouts
                      componentMap := componentMap
                    }
                    rs.inputs.fireClick clickData
                | none => pure ()

                if mouseMoved then
                  let hoverPath := Afferent.Arbor.hitTestPathIndexed snapshot.hitIndex mouseX mouseY
                  hoverPathOpt := some hoverPath
                  let hoverData : Afferent.Canopy.Reactive.HoverData := {
                    x := mouseX
                    y := mouseY
                    hitPath := hoverPath
                    layouts := snapshot.layouts
                    componentMap := componentMap
                  }
                  rs.inputs.fireHover hoverData
                  rs := { rs with lastMouseX := mouseX, lastMouseY := mouseY }
            | none =>
                if mouseMoved then
                  rs := { rs with lastMouseX := mouseX, lastMouseY := mouseY }

            let hasKey ← FFI.Window.hasKeyPressed c.ctx.window
            if hasKey then
              let modifiers ← FFI.Window.getModifiers c.ctx.window
              let keyEvent : Afferent.Arbor.KeyEvent := {
                key := Afferent.Arbor.Key.fromKeyCode keyCode
                modifiers := Afferent.Arbor.Modifiers.fromBitmask modifiers
                isPress := true
              }
              let keyData : Afferent.Canopy.Reactive.KeyData := {
                event := keyEvent
                focusedWidget := none
              }
              rs.inputs.fireKey keyData
              rs := { rs with keysDown := rs.keysDown.insert keyCode true }
              c.clearKey

            let mut releasedKeys : Array UInt16 := #[]
            for (code, _) in rs.keysDown.toList do
              let down ← FFI.Window.isKeyDown c.ctx.window code
              if !down then
                releasedKeys := releasedKeys.push code

            if !releasedKeys.isEmpty then
              let modifiers ← FFI.Window.getModifiers c.ctx.window
              for code in releasedKeys do
                let keyEvent : Afferent.Arbor.KeyEvent := {
                  key := Afferent.Arbor.Key.fromKeyCode code
                  modifiers := Afferent.Arbor.Modifiers.fromBitmask modifiers
                  isPress := false
                }
                let keyData : Afferent.Canopy.Reactive.KeyData := {
                  event := keyEvent
                  focusedWidget := none
                }
                rs.inputs.fireKey keyData
                rs := { rs with keysDown := rs.keysDown.erase code }

            let (scrollX, scrollY) ← FFI.Window.getScrollDelta c.ctx.window
            if scrollX != 0.0 || scrollY != 0.0 then
              match rs.inputSnapshot with
              | some snapshot =>
                  let modifiers ← FFI.Window.getModifiers c.ctx.window
                  let scrollEvent : Afferent.Arbor.ScrollEvent := {
                    x := mouseX
                    y := mouseY
                    deltaX := scrollX
                    deltaY := scrollY
                    modifiers := Afferent.Arbor.Modifiers.fromBitmask modifiers
                  }
                  let scrollPath := match hoverPathOpt with
                    | some path => path
                    | none => Afferent.Arbor.hitTestPathIndexed snapshot.hitIndex mouseX mouseY
                  let scrollData : Afferent.Canopy.Reactive.ScrollData := {
                    scroll := scrollEvent
                    hitPath := scrollPath
                    layouts := snapshot.layouts
                    componentMap := snapshot.hitIndex.componentMap
                  }
                  rs.inputs.fireScroll scrollData
              | none => pure ()
              FFI.Window.clearScroll c.ctx.window

            let (mouseDx, mouseDy) ← FFI.Window.getMouseDelta c.ctx.window
            rs.inputs.fireMouseDelta { dx := mouseDx, dy := mouseDy }

            let buttons ← FFI.Window.getMouseButtons c.ctx.window
            let leftDown := (buttons &&& (1 : UInt8)) != (0 : UInt8)
            if !leftDown && rs.prevLeftDown then
              match rs.inputSnapshot with
              | some snapshot =>
                  let mouseUpPath := match hoverPathOpt with
                    | some path => path
                    | none => Afferent.Arbor.hitTestPathIndexed snapshot.hitIndex mouseX mouseY
                  let mouseUpData : Afferent.Canopy.Reactive.MouseButtonData := {
                    x := mouseX
                    y := mouseY
                    button := 0
                    hitPath := mouseUpPath
                    layouts := snapshot.layouts
                    componentMap := snapshot.hitIndex.componentMap
                  }
                  rs.inputs.fireMouseUp mouseUpData
              | none => pure ()
            rs := { rs with prevLeftDown := leftDown }

            if click.isSome then
              FFI.Window.clearClick c.ctx.window

            let inputEnd ← IO.monoNanosNow
            let reactiveStart := inputEnd
            rs.inputs.fireAnimationFrame dt
            let reactivePropagateEnd ← IO.monoNanosNow
            let currentRenderVersion ← rs.render.version
            let (widgetBuilder, rsNext) ←
              if currentRenderVersion == rs.cachedRenderVersion then
                pure (rs.cachedWidget, rs)
              else
                let rebuiltWidget ← rs.render.materialize
                pure (rebuiltWidget, {
                  rs with
                  cachedWidget := rebuiltWidget
                  cachedRenderVersion := currentRenderVersion
                })
            rs := rsNext
            let reactiveEnd ← IO.monoNanosNow

            let rootWidget := Afferent.Arbor.build widgetBuilder
            let layoutStart ← IO.monoNanosNow
            let measureResult ← runWithFonts rs.assets.fontPack.registry
              (Afferent.Arbor.measureWidget rootWidget screenW screenH)
            let measuredWidget := measureResult.widget
            let layouts := Trellis.layout measureResult.node screenW screenH
            let layoutEnd ← IO.monoNanosNow
            let indexStart := layoutEnd
            let indexBuildStart := indexStart
            let hitIndex := Afferent.Arbor.buildHitTestIndex measuredWidget layouts
            let indexBuildEnd ← IO.monoNanosNow
            let indexSnapshotStoreStart := indexBuildEnd
            rs := { rs with inputSnapshot := some { layouts := layouts, hitIndex := hitIndex } }
            let indexSnapshotStoreEnd ← IO.monoNanosNow
            let indexInteractiveIdsStart := indexSnapshotStoreEnd
            let indexInteractiveIdsEnd ← IO.monoNanosNow
            let indexRegistrySetStart := indexInteractiveIdsEnd
            let indexRegistrySetEnd ← IO.monoNanosNow
            let indexEnd := indexRegistrySetEnd

            let collectStart ← IO.monoNanosNow
            let commands := Afferent.Arbor.collectCommands measuredWidget layouts
            let collectEnd ← IO.monoNanosNow
            let executeStart ← IO.monoNanosNow
            let ((batchStats, executeBatchNs, executeCustomNs), c') ← CanvasM.run c do
              let executeBatchStart ← IO.monoNanosNow
              let batchStats ← Afferent.Widget.executeCommandsBatchedWithStats rs.assets.fontPack.registry commands
              let executeBatchEnd ← IO.monoNanosNow
              pure (batchStats, executeBatchEnd - executeBatchStart, 0)
            let executeEnd ← IO.monoNanosNow
            c := c'
            let endFrameStart ← IO.monoNanosNow
            c ← c.endFrame
            let frameEndNs ← IO.monoNanosNow
            let endFrameEnd := frameEndNs
            let beginFrameMs := (beginFrameEndNs - beginFrameStartNs).toFloat / 1000000.0
            let inputMs := (inputEnd - inputStart).toFloat / 1000000.0
            let reactivePropagateMs := (reactivePropagateEnd - reactiveStart).toFloat / 1000000.0
            let reactiveRenderMs := (reactiveEnd - reactivePropagateEnd).toFloat / 1000000.0
            let reactiveMs := (reactiveEnd - reactiveStart).toFloat / 1000000.0
            let layoutMs := (layoutEnd - layoutStart).toFloat / 1000000.0
            let indexMs := (indexEnd - indexStart).toFloat / 1000000.0
            let indexBuildMs := (indexBuildEnd - indexBuildStart).toFloat / 1000000.0
            let indexSnapshotStoreMs := (indexSnapshotStoreEnd - indexSnapshotStoreStart).toFloat / 1000000.0
            let indexInteractiveIdsMs := (indexInteractiveIdsEnd - indexInteractiveIdsStart).toFloat / 1000000.0
            let indexRegistrySetMs := (indexRegistrySetEnd - indexRegistrySetStart).toFloat / 1000000.0
            let collectMs := (collectEnd - collectStart).toFloat / 1000000.0
            let executeMs := (executeEnd - executeStart).toFloat / 1000000.0
            let executeBatchMs := executeBatchNs.toFloat / 1000000.0
            let executeCustomMs := executeCustomNs.toFloat / 1000000.0
            let executeOverheadMs := max 0.0 (executeMs - executeBatchMs - executeCustomMs)
            let batchResidualMs := max 0.0
              (executeBatchMs - batchStats.timeFlattenMs - batchStats.timeCoalesceMs - batchStats.timeBatchLoopMs)
            let endFrameMs := (endFrameEnd - endFrameStart).toFloat / 1000000.0
            let frameMs := (frameEndNs - frameStartNs).toFloat / 1000000.0
            let fps := if frameMs > 0.0 then 1000.0 / frameMs else 0.0
            let accountedMs :=
              beginFrameMs + inputMs + reactiveMs + layoutMs + indexMs + collectMs + executeMs + endFrameMs
            let unaccountedMs := frameMs - accountedMs
            let widgetCount := (Afferent.Arbor.Widget.allIds measuredWidget).size
            let layoutCount := layouts.layouts.size
            let drawCalls := batchStats.batchedCalls + batchStats.individualCalls
            statsRef.set {
              frameMs := frameMs
              fps := fps
              beginFrameMs := beginFrameMs
              inputMs := inputMs
              reactiveMs := reactiveMs
              reactivePropagateMs := reactivePropagateMs
              reactiveRenderMs := reactiveRenderMs
              layoutMs := layoutMs
              indexMs := indexMs
              indexBuildMs := indexBuildMs
              indexSnapshotStoreMs := indexSnapshotStoreMs
              indexInteractiveIdsMs := indexInteractiveIdsMs
              indexRegistrySetMs := indexRegistrySetMs
              collectMs := collectMs
              executeMs := executeMs
              executeBatchMs := executeBatchMs
              executeCustomMs := executeCustomMs
              executeOverheadMs := executeOverheadMs
              batchResidualMs := batchResidualMs
              endFrameMs := endFrameMs
              accountedMs := accountedMs
              unaccountedMs := unaccountedMs
              commandCount := commands.size
              coalescedCommandCount := batchStats.totalCommands
              drawCalls := drawCalls
              batchedCalls := batchStats.batchedCalls
              individualCalls := batchStats.individualCalls
              rectsBatched := batchStats.rectsBatched
              circlesBatched := batchStats.circlesBatched
              strokeRectsBatched := batchStats.strokeRectsBatched
              strokeRectDirectRuns := batchStats.strokeRectDirectRuns
              strokeRectDirectRects := batchStats.strokeRectDirectRects
              textsBatched := batchStats.textsBatched
              textFillCommands := batchStats.textFillCommands
              textBatchFlushes := batchStats.textBatchFlushes
              flattenMs := batchStats.timeFlattenMs
              coalesceMs := batchStats.timeCoalesceMs
              batchLoopMs := batchStats.timeBatchLoopMs
              drawCallMs := batchStats.timeDrawCallsMs
              textPackMs := batchStats.timeTextPackMs
              textFfiMs := batchStats.timeTextFFIMs
              widgetCount := widgetCount
              layoutCount := layoutCount
            }
            state := .running rs
    pure (c, state)

  let renderTask ← IO.asTask (prio := .dedicated) renderLoop
  canvas.ctx.window.runEventLoop
  let (c, state) ← match renderTask.get with
    | .ok result => pure result
    | .error err => throw err

  IO.println "Cleaning up..."
  match state with
  | .loading ls => cleanupLoading ls
  | .running rs =>
      rs.shutdown
      rs.spiderEnv.currentScope.dispose
      cleanupAssets rs.assets
  c.destroy

end Demos
