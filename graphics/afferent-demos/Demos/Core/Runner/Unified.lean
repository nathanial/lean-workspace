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
import Demos.Core.Runner.FrameScratch
import Demos.Core.Runner.Types
import Demos.Core.Runner.CanopyApp
import Demos.Perf.Lines
import Std.Data.HashMap
import Std.Internal.Async.Process
import Init.Data.FloatArray

set_option maxRecDepth 1024

open Reactive Reactive.Host
open Afferent CanvasM
open Afferent.Canopy.Reactive

namespace Demos

@[noinline] private def keepAliveOption {α : Type} (value : Option α) : Bool :=
  value.isSome

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
      let usageStart ← Std.Internal.IO.Process.getResourceUsage
      let processInfoStart ← FFI.Runtime.getProcessInfo
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
                let initialWidget ← appState.render
                let frameScratch ← FrameScratch.create 4096 256 1024 1024 1024
                state := .running {
                  assets := assets
                  render := appState.render
                  events := events
                  inputs := inputs
                  spiderEnv := spiderEnv
                  shutdown := appState.shutdown
                  cachedWidget := initialWidget
                  frameScratch := frameScratch
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

            match rs.frameCache with
            | some cache =>
                let nameMap := cache.hitIndex.nameMap
                let mut hoverPathOpt : Option (Array Afferent.Arbor.WidgetId) := none
                match click with
                | some ce =>
                    let hitPath := Afferent.Arbor.hitTestPathIndexed cache.hitIndex ce.x ce.y
                    let clickData : Afferent.Canopy.Reactive.ClickData := {
                      click := ce
                      hitPath := hitPath
                      widget := cache.measuredWidget
                      layouts := cache.layouts
                      nameMap := nameMap
                    }
                    rs.inputs.fireClick clickData
                | none => pure ()

                let mouseMoved := mouseX != rs.lastMouseX || mouseY != rs.lastMouseY
                if mouseMoved then
                  let hoverPath := Afferent.Arbor.hitTestPathIndexed cache.hitIndex mouseX mouseY
                  hoverPathOpt := some hoverPath
                  let hoverData : Afferent.Canopy.Reactive.HoverData := {
                    x := mouseX
                    y := mouseY
                    hitPath := hoverPath
                    widget := cache.measuredWidget
                    layouts := cache.layouts
                    nameMap := nameMap
                  }
                  rs.inputs.fireHover hoverData
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
                releasedKeys ← rs.keysDown.foldM (init := releasedKeys) fun acc code _ => do
                  let down ← FFI.Window.isKeyDown c.ctx.window code
                  if down then
                    pure acc
                  else
                    pure (acc.push code)

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
                    | none => Afferent.Arbor.hitTestPathIndexed cache.hitIndex mouseX mouseY
                  let scrollData : Afferent.Canopy.Reactive.ScrollData := {
                    scroll := scrollEvent
                    hitPath := scrollPath
                    widget := cache.measuredWidget
                    layouts := cache.layouts
                    nameMap := nameMap
                  }
                  rs.inputs.fireScroll scrollData
                  FFI.Window.clearScroll c.ctx.window

                let (mouseDx, mouseDy) ← FFI.Window.getMouseDelta c.ctx.window
                rs.inputs.fireMouseDelta { dx := mouseDx, dy := mouseDy }

                let buttons ← FFI.Window.getMouseButtons c.ctx.window
                let leftDown := (buttons &&& (1 : UInt8)) != (0 : UInt8)
                if !leftDown && rs.prevLeftDown then
                  let mouseUpPath := match hoverPathOpt with
                    | some path => path
                    | none => Afferent.Arbor.hitTestPathIndexed cache.hitIndex mouseX mouseY
                  let mouseUpData : Afferent.Canopy.Reactive.MouseButtonData := {
                    x := mouseX
                    y := mouseY
                    button := 0
                    hitPath := mouseUpPath
                    widget := cache.measuredWidget
                    layouts := cache.layouts
                    nameMap := nameMap
                  }
                  rs.inputs.fireMouseUp mouseUpData
                rs := { rs with prevLeftDown := leftDown }
            | none =>
                let buttons ← FFI.Window.getMouseButtons c.ctx.window
                let leftDown := (buttons &&& (1 : UInt8)) != (0 : UInt8)
                rs := { rs with prevLeftDown := leftDown }

            if click.isSome then
              FFI.Window.clearClick c.ctx.window

            let reusableHitIndex := rs.frameCache.map (·.hitIndex)
            rs := { rs with frameCache := none }

            let inputEnd ← IO.monoNanosNow
            let reactiveStart := inputEnd
            rs.inputs.fireAnimationFrame dt
            let reactivePropagateEnd ← IO.monoNanosNow
            let widgetBuilder ← rs.render
            rs := { rs with cachedWidget := widgetBuilder }
            let reactiveEnd ← IO.monoNanosNow

            let sizeStart ← IO.monoNanosNow
            let (screenW, screenH) ← c.ctx.getCurrentSize
            if screenW != rs.assets.physWidthF || screenH != rs.assets.physHeightF then
              rs := { rs with assets := {
                rs.assets with
                physWidthF := screenW
                physHeightF := screenH
                physWidth := screenW.toUInt32
                physHeight := screenH.toUInt32
              } }
            let sizeEnd ← IO.monoNanosNow

            let buildStart ← IO.monoNanosNow
            let rootWidget := Afferent.Arbor.build widgetBuilder
            let buildEnd ← IO.monoNanosNow
            let layoutStart ← IO.monoNanosNow
            let measureResult ← runWithFonts rs.assets.fontPack.registry
              (Afferent.Arbor.measureWidget rootWidget screenW screenH)
            let measuredWidget := measureResult.widget
            let layouts := Trellis.layout measureResult.node screenW screenH
            let layoutEnd ← IO.monoNanosNow
            let livenessHold := rs.phaseProbe.livenessHoldNext
            let deferredLayoutTemps :=
              if livenessHold then
                some (widgetBuilder, rootWidget, measureResult)
              else
                none
            let collectFirst := rs.phaseProbe.collectFirstNext
            let collectScratch ← rs.frameScratch.checkoutCollect
            let hitScratch ← rs.frameScratch.checkoutHit
            let (indexMs, collectMs, hitIndex, commands, cacheHits, cacheMisses, indexCollectStartNs, indexCollectEndNs,
                collectDeferredOverlayScratch, hitTestScratch) ←
              if collectFirst then
                let collectStart ← IO.monoNanosNow
                let (commands, cacheHits, cacheMisses, collectDeferredOverlayScratch) ←
                  Afferent.Arbor.collectCommandsCachedWithStatsScratch c.renderCache measuredWidget layouts collectScratch
                let collectEnd ← IO.monoNanosNow
                let indexStart ← IO.monoNanosNow
                let (hitIndex, hitTestScratch) :=
                  Afferent.Arbor.buildHitTestIndexWithScratch measuredWidget layouts reusableHitIndex hitScratch
                let indexEnd ← IO.monoNanosNow
                let indexMs := (indexEnd - indexStart).toFloat / 1000000.0
                let collectMs := (collectEnd - collectStart).toFloat / 1000000.0
                pure (indexMs, collectMs, hitIndex, commands, cacheHits, cacheMisses, collectStart, indexEnd,
                  collectDeferredOverlayScratch, hitTestScratch)
              else
                let indexStart ← IO.monoNanosNow
                let (hitIndex, hitTestScratch) :=
                  Afferent.Arbor.buildHitTestIndexWithScratch measuredWidget layouts reusableHitIndex hitScratch
                let indexEnd ← IO.monoNanosNow
                let collectStart ← IO.monoNanosNow
                let (commands, cacheHits, cacheMisses, collectDeferredOverlayScratch) ←
                  Afferent.Arbor.collectCommandsCachedWithStatsScratch c.renderCache measuredWidget layouts collectScratch
                let collectEnd ← IO.monoNanosNow
                let indexMs := (indexEnd - indexStart).toFloat / 1000000.0
                let collectMs := (collectEnd - collectStart).toFloat / 1000000.0
                pure (indexMs, collectMs, hitIndex, commands, cacheHits, cacheMisses, indexStart, collectEnd,
                  collectDeferredOverlayScratch, hitTestScratch)
            let syncStart ← IO.monoNanosNow
            rs := { rs with frameCache := some {
              measuredWidget := measuredWidget
              layouts := layouts
              hitIndex := hitIndex
            } }
            let nameSyncStart ← IO.monoNanosNow
            let previousInteractiveNames ← rs.frameScratch.checkoutInteractiveNames
            if previousInteractiveNames != hitIndex.names then
              rs.events.registry.interactiveNames.set hitIndex.names
              rs.frameScratch.checkinInteractiveNames hitIndex.names
            else
              rs.frameScratch.checkinInteractiveNames previousInteractiveNames
            let nameSyncEnd ← IO.monoNanosNow

            let probe := rs.phaseProbe
            let probe :=
              if collectFirst then
                { probe with
                  collectFirstSamples := probe.collectFirstSamples + 1
                  collectFirstCollectTotalMs := probe.collectFirstCollectTotalMs + collectMs
                  collectFirstIndexTotalMs := probe.collectFirstIndexTotalMs + indexMs
                }
              else
                { probe with
                  indexFirstSamples := probe.indexFirstSamples + 1
                  indexFirstIndexTotalMs := probe.indexFirstIndexTotalMs + indexMs
                  indexFirstCollectTotalMs := probe.indexFirstCollectTotalMs + collectMs
                }
            let probe := { probe with collectFirstNext := !collectFirst }
            rs := { rs with phaseProbe := probe }
            let syncEnd ← IO.monoNanosNow
            let executeStart ← IO.monoNanosNow
            let (batchStats, c') ← CanvasM.run c do
              let batchStats ← Afferent.Widget.executeCommandsBatchedWithStats rs.assets.fontPack.registry commands
              Afferent.Widget.renderCustomWidgets measuredWidget layouts
              pure batchStats
            let executeEnd ← IO.monoNanosNow
            rs.frameScratch.checkinCollect {
              commands := commands.shrink 0
              deferredOverlay := collectDeferredOverlayScratch
            }
            rs.frameScratch.checkinHit hitTestScratch
            let canvasSwapStart ← IO.monoNanosNow
            c := c'
            let canvasSwapEnd ← IO.monoNanosNow
            let endFrameStart ← IO.monoNanosNow
            c ← c.endFrame
            let endFrameEnd ← IO.monoNanosNow
            let stateSwapStart ← IO.monoNanosNow
            state := .running rs
            let stateSwapEnd ← IO.monoNanosNow
            let livenessHoldObserved := keepAliveOption deferredLayoutTemps
            let usageEnd ← Std.Internal.IO.Process.getResourceUsage
            let processInfoEnd ← FFI.Runtime.getProcessInfo
            let frameEndNs := stateSwapEnd
            let nsDiffMs := fun (startNs endNs : Nat) =>
              if endNs >= startNs then
                (endNs - startNs).toFloat / 1000000.0
              else
                0.0
            let intDeltaFloat := fun (startInt endInt : Int) =>
              if endInt >= startInt then
                (Int.toNat (endInt - startInt)).toFloat
              else
                0.0
            let natDelta := fun (startNat endNat : Nat) =>
              if endNat >= startNat then
                endNat - startNat
              else
                0
            let bytesToKb := fun (bytes : Nat) =>
              bytes.toFloat / 1024.0
            let beginFrameMs := (beginFrameEndNs - beginFrameStartNs).toFloat / 1000000.0
            let preInputMs := (inputStart - beginFrameEndNs).toFloat / 1000000.0
            let inputMs := (inputEnd - inputStart).toFloat / 1000000.0
            let reactivePropagateMs := (reactivePropagateEnd - reactiveStart).toFloat / 1000000.0
            let reactiveRenderMs := (reactiveEnd - reactivePropagateEnd).toFloat / 1000000.0
            let reactiveMs := (reactiveEnd - reactiveStart).toFloat / 1000000.0
            let sizeMs := (sizeEnd - sizeStart).toFloat / 1000000.0
            let buildMs := (buildEnd - buildStart).toFloat / 1000000.0
            let layoutMs := (layoutEnd - layoutStart).toFloat / 1000000.0
            let nameSyncMs := (nameSyncEnd - nameSyncStart).toFloat / 1000000.0
            let syncMs := (syncEnd - syncStart).toFloat / 1000000.0
            let syncOverheadMs :=
              if syncMs >= nameSyncMs then
                syncMs - nameSyncMs
              else
                0.0
            let executeMs := (executeEnd - executeStart).toFloat / 1000000.0
            let canvasSwapMs := (canvasSwapEnd - canvasSwapStart).toFloat / 1000000.0
            let endFrameMs := (endFrameEnd - endFrameStart).toFloat / 1000000.0
            let stateSwapMs := (stateSwapEnd - stateSwapStart).toFloat / 1000000.0
            let cpuUserMsDelta := intDeltaFloat usageStart.cpuUserTime.val usageEnd.cpuUserTime.val
            let cpuSystemMsDelta := intDeltaFloat usageStart.cpuSystemTime.val usageEnd.cpuSystemTime.val
            let processRssDeltaKb := bytesToKb (natDelta processInfoStart.currentRssBytes processInfoEnd.currentRssBytes)
            let processCommitDeltaKb := bytesToKb (natDelta processInfoStart.currentCommitBytes processInfoEnd.currentCommitBytes)
            let processCurrentRssKb := bytesToKb processInfoEnd.currentRssBytes
            let processPeakRssKb := bytesToKb processInfoEnd.peakRssBytes
            let processCurrentCommitKb := bytesToKb processInfoEnd.currentCommitBytes
            let processPeakCommitKb := bytesToKb processInfoEnd.peakCommitBytes
            let processPageFaultsDelta := natDelta processInfoStart.pageFaults processInfoEnd.pageFaults
            let gapAfterLayoutMs := nsDiffMs layoutEnd indexCollectStartNs
            let gapBeforeSyncMs := nsDiffMs indexCollectEndNs syncStart
            let gapBeforeExecuteMs := nsDiffMs syncEnd executeStart
            let gapBeforeCanvasSwapMs := nsDiffMs executeEnd canvasSwapStart
            let gapBeforeEndFrameMs := nsDiffMs canvasSwapEnd endFrameStart
            let gapBeforeStateSwapMs := nsDiffMs endFrameEnd stateSwapStart
            let indexCollectEnvelopeMs := nsDiffMs indexCollectStartNs indexCollectEndNs
            let indexCollectOverheadMs :=
              if indexCollectEnvelopeMs >= indexMs + collectMs then
                indexCollectEnvelopeMs - (indexMs + collectMs)
              else
                0.0
            let boundaryGapTotalMs :=
              gapAfterLayoutMs + gapBeforeSyncMs + gapBeforeExecuteMs + gapBeforeCanvasSwapMs + gapBeforeEndFrameMs + gapBeforeStateSwapMs
            let voluntaryCtxSwitchesDelta :=
              if usageEnd.voluntaryContextSwitches >= usageStart.voluntaryContextSwitches then
                usageEnd.voluntaryContextSwitches - usageStart.voluntaryContextSwitches
              else
                0
            let involuntaryCtxSwitchesDelta :=
              if usageEnd.involuntaryContextSwitches >= usageStart.involuntaryContextSwitches then
                usageEnd.involuntaryContextSwitches - usageStart.involuntaryContextSwitches
              else
                0
            let minorPageFaultsDelta :=
              if usageEnd.minorPageFaults >= usageStart.minorPageFaults then
                usageEnd.minorPageFaults - usageStart.minorPageFaults
              else
                0
            let majorPageFaultsDelta :=
              if usageEnd.majorPageFaults >= usageStart.majorPageFaults then
                usageEnd.majorPageFaults - usageStart.majorPageFaults
              else
                0
            let frameMs := (frameEndNs - frameStartNs).toFloat / 1000000.0
            let fps := if frameMs > 0.0 then 1000.0 / frameMs else 0.0
            let accountedMs :=
              beginFrameMs + preInputMs + inputMs + reactiveMs + sizeMs + buildMs + layoutMs + indexMs + collectMs + nameSyncMs + syncOverheadMs + executeMs + canvasSwapMs + stateSwapMs + endFrameMs
            let unaccountedMs := frameMs - accountedMs
            let residualUnaccountedMs := frameMs - (accountedMs + boundaryGapTotalMs + indexCollectOverheadMs)
            let probe := rs.phaseProbe
            let probe :=
              if livenessHoldObserved then
                { probe with
                  livenessHoldSamples := probe.livenessHoldSamples + 1
                  livenessHoldAfterLayoutTotalMs := probe.livenessHoldAfterLayoutTotalMs + gapAfterLayoutMs
                  livenessHoldBeforeSyncTotalMs := probe.livenessHoldBeforeSyncTotalMs + gapBeforeSyncMs
                }
              else
                { probe with
                  livenessNoHoldSamples := probe.livenessNoHoldSamples + 1
                  livenessNoHoldAfterLayoutTotalMs := probe.livenessNoHoldAfterLayoutTotalMs + gapAfterLayoutMs
                  livenessNoHoldBeforeSyncTotalMs := probe.livenessNoHoldBeforeSyncTotalMs + gapBeforeSyncMs
                }
            let probe := { probe with livenessHoldNext := !livenessHoldObserved }
            rs := { rs with phaseProbe := probe }
            let layoutCount := layouts.layouts.size
            -- Layout entries are one-per-widget for measured trees; avoid rebuilding all IDs.
            let widgetCount := layoutCount
            let drawCalls := batchStats.batchedCalls + batchStats.individualCalls
            let indexWhenFirstAvgMs :=
              if rs.phaseProbe.indexFirstSamples == 0 then
                0.0
              else
                rs.phaseProbe.indexFirstIndexTotalMs / rs.phaseProbe.indexFirstSamples.toFloat
            let indexWhenSecondAvgMs :=
              if rs.phaseProbe.collectFirstSamples == 0 then
                0.0
              else
                rs.phaseProbe.collectFirstIndexTotalMs / rs.phaseProbe.collectFirstSamples.toFloat
            let collectWhenFirstAvgMs :=
              if rs.phaseProbe.collectFirstSamples == 0 then
                0.0
              else
                rs.phaseProbe.collectFirstCollectTotalMs / rs.phaseProbe.collectFirstSamples.toFloat
            let collectWhenSecondAvgMs :=
              if rs.phaseProbe.indexFirstSamples == 0 then
                0.0
              else
                rs.phaseProbe.indexFirstCollectTotalMs / rs.phaseProbe.indexFirstSamples.toFloat
            let indexSecondPenaltyMs := indexWhenSecondAvgMs - indexWhenFirstAvgMs
            let collectSecondPenaltyMs := collectWhenSecondAvgMs - collectWhenFirstAvgMs
            let livenessHoldAfterLayoutAvgMs :=
              if rs.phaseProbe.livenessHoldSamples == 0 then
                0.0
              else
                rs.phaseProbe.livenessHoldAfterLayoutTotalMs / rs.phaseProbe.livenessHoldSamples.toFloat
            let livenessNoHoldAfterLayoutAvgMs :=
              if rs.phaseProbe.livenessNoHoldSamples == 0 then
                0.0
              else
                rs.phaseProbe.livenessNoHoldAfterLayoutTotalMs / rs.phaseProbe.livenessNoHoldSamples.toFloat
            let livenessHoldBeforeSyncAvgMs :=
              if rs.phaseProbe.livenessHoldSamples == 0 then
                0.0
              else
                rs.phaseProbe.livenessHoldBeforeSyncTotalMs / rs.phaseProbe.livenessHoldSamples.toFloat
            let livenessNoHoldBeforeSyncAvgMs :=
              if rs.phaseProbe.livenessNoHoldSamples == 0 then
                0.0
              else
                rs.phaseProbe.livenessNoHoldBeforeSyncTotalMs / rs.phaseProbe.livenessNoHoldSamples.toFloat
            statsRef.set {
              frameMs := frameMs
              fps := fps
              beginFrameMs := beginFrameMs
              preInputMs := preInputMs
              inputMs := inputMs
              reactiveMs := reactiveMs
              reactivePropagateMs := reactivePropagateMs
              reactiveRenderMs := reactiveRenderMs
              sizeMs := sizeMs
              buildMs := buildMs
              layoutMs := layoutMs
              indexMs := indexMs
              collectMs := collectMs
              nameSyncMs := nameSyncMs
              syncOverheadMs := syncOverheadMs
              executeMs := executeMs
              canvasSwapMs := canvasSwapMs
              stateSwapMs := stateSwapMs
              endFrameMs := endFrameMs
              cpuUserMsDelta := cpuUserMsDelta
              cpuSystemMsDelta := cpuSystemMsDelta
              processRssDeltaKb := processRssDeltaKb
              processCommitDeltaKb := processCommitDeltaKb
              processCurrentRssKb := processCurrentRssKb
              processPeakRssKb := processPeakRssKb
              processCurrentCommitKb := processCurrentCommitKb
              processPeakCommitKb := processPeakCommitKb
              processPageFaultsDelta := processPageFaultsDelta
              gapAfterLayoutMs := gapAfterLayoutMs
              gapBeforeSyncMs := gapBeforeSyncMs
              gapBeforeExecuteMs := gapBeforeExecuteMs
              gapBeforeCanvasSwapMs := gapBeforeCanvasSwapMs
              gapBeforeEndFrameMs := gapBeforeEndFrameMs
              gapBeforeStateSwapMs := gapBeforeStateSwapMs
              indexCollectEnvelopeMs := indexCollectEnvelopeMs
              indexCollectOverheadMs := indexCollectOverheadMs
              boundaryGapTotalMs := boundaryGapTotalMs
              residualUnaccountedMs := residualUnaccountedMs
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
              linesBatched := batchStats.linesBatched
              textsBatched := batchStats.textsBatched
              flattenMs := batchStats.timeFlattenMs
              coalesceMs := batchStats.timeCoalesceMs
              batchLoopMs := batchStats.timeBatchLoopMs
              drawCallMs := batchStats.timeDrawCallsMs
              cacheHits := cacheHits
              cacheMisses := cacheMisses
              voluntaryCtxSwitchesDelta := voluntaryCtxSwitchesDelta
              involuntaryCtxSwitchesDelta := involuntaryCtxSwitchesDelta
              minorPageFaultsDelta := minorPageFaultsDelta
              majorPageFaultsDelta := majorPageFaultsDelta
              widgetCount := widgetCount
              layoutCount := layoutCount
              probeCollectFirstThisFrame := collectFirst
              probeIndexFirstSamples := rs.phaseProbe.indexFirstSamples
              probeCollectFirstSamples := rs.phaseProbe.collectFirstSamples
              probeIndexWhenFirstAvgMs := indexWhenFirstAvgMs
              probeIndexWhenSecondAvgMs := indexWhenSecondAvgMs
              probeCollectWhenFirstAvgMs := collectWhenFirstAvgMs
              probeCollectWhenSecondAvgMs := collectWhenSecondAvgMs
              probeIndexSecondPenaltyMs := indexSecondPenaltyMs
              probeCollectSecondPenaltyMs := collectSecondPenaltyMs
              probeLivenessHoldThisFrame := livenessHoldObserved
              probeLivenessHoldSamples := rs.phaseProbe.livenessHoldSamples
              probeLivenessNoHoldSamples := rs.phaseProbe.livenessNoHoldSamples
              probeLivenessHoldAfterLayoutAvgMs := livenessHoldAfterLayoutAvgMs
              probeLivenessNoHoldAfterLayoutAvgMs := livenessNoHoldAfterLayoutAvgMs
              probeLivenessHoldBeforeSyncAvgMs := livenessHoldBeforeSyncAvgMs
              probeLivenessNoHoldBeforeSyncAvgMs := livenessNoHoldBeforeSyncAvgMs
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
