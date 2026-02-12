/-
  WidgetTreePerfStress
  Stress benchmarks for deep and dynamic widget trees that emulate demo-scale complexity.
-/
import Crucible
import Reactive
import Afferent
import Afferent.UI.Arbor
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Perf.Widget.App
import Trellis

namespace AfferentDemosTests.WidgetTreePerfStress

open Crucible
open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Demos.WidgetPerf
open Trellis

private structure StressConfig where
  warmupFrames : Nat := 2
  sampleFrames : Nat := 8
  screenW : Float := 2200.0
  screenH : Float := 1400.0
  dt : Float := 1.0 / 60.0
deriving Inhabited

private structure StressAccum where
  frames : Nat := 0
  updateMs : Float := 0
  buildMs : Float := 0
  measureMs : Float := 0
  layoutMs : Float := 0
  hitIndexMs : Float := 0
  collectMs : Float := 0
deriving Inhabited

private structure StressResult where
  frames : Nat
  widgetCount : Nat
  layoutNodeCount : Nat
  targetCount : Nat
  updateMs : Float
  buildMs : Float
  measureMs : Float
  layoutMs : Float
  hitIndexMs : Float
  collectMs : Float
deriving Inhabited

private structure StressAssets where
  fontRegistry : FontRegistry
  fontCanopy : Font
  fontCanopySmall : Font
  theme : Theme

private structure StressApp where
  render : ComponentRender
  inputs : ReactiveInputs
  componentRegistry : ComponentRegistry
  spiderEnv : Reactive.Host.SpiderEnv
  shutdown : IO Unit

private def nanosToMs (n : Nat) : Float :=
  n.toFloat / 1000000.0

private def deltaMs (start stop : Nat) : Float :=
  nanosToMs (stop - start)

private def avg (sum : Float) (frames : Nat) : Float :=
  if frames == 0 then 0 else sum / frames.toFloat

private def fmtMs (v : Float) : String :=
  let scaled := (v * 10.0).toUInt32.toFloat / 10.0
  s!"{scaled}"

private def StressResult.totalMs (r : StressResult) : Float :=
  r.updateMs + r.buildMs + r.measureMs + r.layoutMs + r.hitIndexMs + r.collectMs

private def StressResult.format (label : String) (r : StressResult) : String :=
  s!"{label}: frames={r.frames}, widgets={r.widgetCount}, nodes={r.layoutNodeCount}, targets={r.targetCount}, " ++
  s!"update={fmtMs r.updateMs}ms, build={fmtMs r.buildMs}ms, measure={fmtMs r.measureMs}ms, " ++
  s!"layout={fmtMs r.layoutMs}ms, hitIndex={fmtMs r.hitIndexMs}ms, collect={fmtMs r.collectMs}ms, " ++
  s!"total={fmtMs r.totalMs}ms"

private def StressAccum.add (acc : StressAccum)
    (update build measure layout hitIndex collect : Float) : StressAccum :=
  { acc with
    frames := acc.frames + 1
    updateMs := acc.updateMs + update
    buildMs := acc.buildMs + build
    measureMs := acc.measureMs + measure
    layoutMs := acc.layoutMs + layout
    hitIndexMs := acc.hitIndexMs + hitIndex
    collectMs := acc.collectMs + collect
  }

private def loadStressAssets : IO StressAssets := do
  let fontCanopy ← Font.load "/System/Library/Fonts/Monaco.ttf" 14
  let fontCanopySmall ← Font.load "/System/Library/Fonts/Monaco.ttf" 10
  let (reg1, canopyId) := FontRegistry.empty.register fontCanopy "canopy"
  let (reg2, canopySmallId) := reg1.register fontCanopySmall "canopySmall"
  let fontRegistry := reg2.setDefault fontCanopy
  let theme : Theme := { Theme.dark with font := canopyId, smallFont := canopySmallId }
  pure { fontRegistry, fontCanopy, fontCanopySmall, theme }

private def destroyStressAssets (assets : StressAssets) : IO Unit := do
  Font.destroy assets.fontCanopy
  Font.destroy assets.fontCanopySmall

private def initStressApp (assets : StressAssets)
    (buildRender : ReactiveM ComponentRender) : IO StressApp := do
  let spiderEnv ← Reactive.Host.SpiderEnv.new Reactive.Host.defaultErrorHandler
  let (render, inputs, componentRegistry) ← (do
    let (events, inputs) ← Afferent.Canopy.Reactive.createInputs
      assets.fontRegistry assets.theme (some assets.fontCanopy)
    let render ← ReactiveM.run events buildRender
    pure (render, inputs, events.registry)
  ).run spiderEnv
  spiderEnv.postBuildTrigger ()
  pure {
    render
    inputs
    componentRegistry
    spiderEnv
    shutdown := spiderEnv.currentScope.dispose
  }

private def stressWidgetTypes : Array WidgetType := #[
  .label, .caption, .panel,
  .button, .checkbox, .switch,
  .dropdown, .stepper
]

private def renderStressWidget (nodeIdx : Nat) : WidgetM Unit := do
  let wtype := stressWidgetTypes.getD (nodeIdx % stressWidgetTypes.size) .label
  renderWidget wtype nodeIdx

private def deepGridRows (base : Nat) (rows cols : Nat) : WidgetM Unit := do
  for row in [:rows] do
    row' (gap := 6) (style := { width := .percent 1.0 }) do
      for col in [:cols] do
        let idx := base + row * cols + col
        renderStressWidget idx

private def staticDeepTreeRender : ReactiveM ComponentRender := do
  let (_, render) ← runWidget do
    let rootStyle : BoxStyle := {
      backgroundColor := some (Color.gray 0.08)
      padding := EdgeInsets.uniform 12
      width := .percent 1.0
      height := .percent 1.0
      flexItem := some (FlexItem.growing 1)
    }
    column' (gap := 8) (style := rootStyle) do
      heading1' "Widget Tree Stress: Static Deep Tree"
      caption' "Large nested network with thousands of nodes."
      let contentStyle : BoxStyle := {
        flexItem := some (FlexItem.growing 1)
        width := .percent 1.0
        height := .percent 1.0
      }
      column' (gap := 8) (style := contentStyle) do
        for secIdx in [:10] do
          outlinedPanel' 4 do
            heading3' s!"Section {secIdx}"
            deepGridRows (secIdx * 1000) 10 10
  pure render

private def sectionVariantA (secIdx mode : Nat) : WidgetM Unit := do
  outlinedPanel' 4 do
    heading3' s!"A/Section {secIdx} mode={mode}"
    deepGridRows ((secIdx + 1) * 700 + mode * 31) 6 8

private def sectionVariantB (secIdx mode : Nat) : WidgetM Unit := do
  outlinedPanel' 4 do
    heading3' s!"B/Section {secIdx} mode={mode}"
    for row in [:8] do
      column' (gap := 6) (style := { width := .percent 1.0 }) do
        for col in [:6] do
          let idx := (secIdx + 1) * 1700 + row * 61 + col + mode * 13
          renderStressWidget idx

private def dynamicSwapRender : ReactiveM ComponentRender := do
  let (_, render) ← runWidget do
    let frames ← useAnimationFrame
    let tickDyn ← Reactive.foldDyn (fun (_ : Float) n => n + 1) (0 : Nat) frames
    let sectionStateDyn ← Dynamic.mapM (fun n =>
      Id.run do
        let activeSection := n % 8
        let activeBucket := n % 4
        let phaseTick := (n / 4) % 2
        let modeTick := (n / 4) % 3
        let mut sections : Array (Nat × Nat × Nat) := #[]
        for secIdx in [:8] do
          let phase := if secIdx == activeSection then phaseTick else secIdx % 2
          let localMode := if secIdx % 4 == activeBucket then (modeTick + secIdx) % 3 else secIdx % 3
          sections := sections.push (secIdx, phase, localMode)
        sections
    ) tickDyn

    let rootStyle : BoxStyle := {
      backgroundColor := some (Color.gray 0.08)
      padding := EdgeInsets.uniform 12
      width := .percent 1.0
      height := .percent 1.0
      flexItem := some (FlexItem.growing 1)
    }
    column' (gap := 8) (style := rootStyle) do
      heading1' "Widget Tree Stress: Dynamic Subtree Swap"
      caption' "Keyed incremental sections with sparse per-frame churn."
      let contentStyle : BoxStyle := {
        flexItem := some (FlexItem.growing 1)
        width := .percent 1.0
        height := .percent 1.0
      }
      column' (gap := 8) (style := contentStyle) do
        let sectionCombine : Array WidgetBuilder → WidgetBuilder :=
          fun builders => Afferent.Arbor.column (gap := 8) (style := { width := .percent 1.0 }) builders
        let sectionKey : (Nat × Nat × Nat) → Nat := fun item => item.1
        let sectionBuilder : (Nat × Nat × Nat) → WidgetM Unit := fun item => do
          let secIdx := item.1
          let phase := item.2.1
          let localMode := item.2.2
          if phase == 0 then
            sectionVariantA secIdx localMode
          else
            sectionVariantB secIdx localMode
        let _ ← dynWidgetKeyedList sectionStateDyn sectionKey sectionBuilder (combine := sectionCombine)
        pure ()
      pure ()
  pure render

private def fanoutDynamicRender : ReactiveM ComponentRender := do
  let (_, render) ← runWidget do
    let frames ← useAnimationFrame
    let tickDyn ← Reactive.foldDyn (fun (_ : Float) n => n + 1) (0 : Nat) frames

    let rootStyle : BoxStyle := {
      backgroundColor := some (Color.gray 0.08)
      padding := EdgeInsets.uniform 12
      width := .percent 1.0
      height := .percent 1.0
      flexItem := some (FlexItem.growing 1)
    }
    column' (gap := 8) (style := rootStyle) do
      heading1' "Widget Tree Stress: Fanout dynWidget Grid"
      caption' "Hundreds of dynWidget leaves updating in lockstep."
      for row in [:18] do
        row' (gap := 6) (style := { width := .percent 1.0 }) do
          for col in [:18] do
            let slot := row * 18 + col
            let slotDyn ← Dynamic.mapM (fun n => (n + slot) % 4) tickDyn
            let _ ← dynWidget slotDyn fun localMode => do
              let nodeIdx := slot * 1000 + localMode * 17
              renderStressWidget nodeIdx
            pure ()
  pure render

private def runStress (render : ComponentRender) (inputs : ReactiveInputs)
    (fontRegistry : FontRegistry) (componentRegistry : ComponentRegistry)
    (config : StressConfig) : IO StressResult := do
  let totalFrames := config.warmupFrames + config.sampleFrames
  let mut widgetCount : Nat := 0
  let mut layoutNodeCount : Nat := 0
  let mut targetCount : Nat := 0
  let mut accum : StressAccum := {}

  for frameIdx in [0:totalFrames] do
    let tUpdate0 ← IO.monoNanosNow
    inputs.fireAnimationFrame config.dt
    let builder ← render
    let tUpdate1 ← IO.monoNanosNow

    let tBuild0 ← IO.monoNanosNow
    let widget := Afferent.Arbor.buildFrom 0 builder
    let tBuild1 ← IO.monoNanosNow

    let tMeasure0 ← IO.monoNanosNow
    let measureResult ← Afferent.runWithFonts fontRegistry
      (Afferent.Arbor.measureWidget widget config.screenW config.screenH)
    let tMeasure1 ← IO.monoNanosNow

    let tLayout0 ← IO.monoNanosNow
    let layouts := Trellis.layout measureResult.node config.screenW config.screenH
    let nodeCount := layouts.layouts.size
    let tLayout1 ← IO.monoNanosNow

    let tHitIndex0 ← IO.monoNanosNow
    let hitIndex := Afferent.Arbor.buildHitTestIndex measureResult.widget layouts
    let tHitIndex1 ← IO.monoNanosNow

    let tCollect0 ← IO.monoNanosNow
    let _ := Afferent.Arbor.collectCommands measureResult.widget layouts
    let tCollect1 ← IO.monoNanosNow

    if widgetCount == 0 then
      widgetCount := measureResult.widget.widgetCount
    if layoutNodeCount == 0 then
      layoutNodeCount := nodeCount
    if targetCount == 0 then
      let componentIds ← componentRegistry.interactiveIds.get
      let mapped := componentIds.foldl (init := 0) fun acc componentId =>
        if hitIndex.componentMap.contains componentId then acc + 1 else acc
      targetCount := mapped

    if frameIdx >= config.warmupFrames then
      accum := accum.add
        (deltaMs tUpdate0 tUpdate1)
        (deltaMs tBuild0 tBuild1)
        (deltaMs tMeasure0 tMeasure1)
        (deltaMs tLayout0 tLayout1)
        (deltaMs tHitIndex0 tHitIndex1)
        (deltaMs tCollect0 tCollect1)

  let frames := accum.frames
  pure {
    frames
    widgetCount
    layoutNodeCount
    targetCount
    updateMs := avg accum.updateMs frames
    buildMs := avg accum.buildMs frames
    measureMs := avg accum.measureMs frames
    layoutMs := avg accum.layoutMs frames
    hitIndexMs := avg accum.hitIndexMs frames
    collectMs := avg accum.collectMs frames
  }

testSuite "WidgetTree Perf Stress"

test "static deep tree benchmark (thousands of nodes)" := do
  let assets ← loadStressAssets
  let app ← initStressApp assets staticDeepTreeRender
  try
    let config : StressConfig := { warmupFrames := 2, sampleFrames := 6 }
    let result ← runStress app.render app.inputs assets.fontRegistry app.componentRegistry config
    IO.println (StressResult.format "static deep tree" result)

    ensure (result.widgetCount >= 2500)
      s!"Expected at least 2500 widgets, got {result.widgetCount}"
    ensure (result.layoutNodeCount >= 2500)
      s!"Expected at least 2500 layout nodes, got {result.layoutNodeCount}"
  finally
    app.shutdown
    destroyStressAssets assets

test "nested dynWidget subtree swap benchmark" := do
  let dynMetrics ← Afferent.Canopy.Reactive.enableDynWidgetMetrics
  let assets ← loadStressAssets
  let app ← initStressApp assets dynamicSwapRender
  try
    DynWidgetMetrics.reset dynMetrics
    let config : StressConfig := { warmupFrames := 2, sampleFrames := 8 }
    let result ← runStress app.render app.inputs assets.fontRegistry app.componentRegistry config
    let dynSnap ← DynWidgetMetrics.snapshot dynMetrics
    IO.println (StressResult.format "dynamic subtree swap" result)
    IO.println s!"dynWidget rebuilds: count={dynSnap.rebuildCount}, total={fmtMs (nanosToMs dynSnap.rebuildNanos)}ms"

    ensure (result.widgetCount >= 1200)
      s!"Expected at least 1200 widgets, got {result.widgetCount}"
    ensure (dynSnap.rebuildCount >= config.sampleFrames)
      s!"Expected dynWidget rebuilds >= {config.sampleFrames}, got {dynSnap.rebuildCount}"
  finally
    app.shutdown
    Afferent.Canopy.Reactive.disableDynWidgetMetrics
    destroyStressAssets assets

test "fanout dynWidget benchmark (hundreds of dynamic leaves)" := do
  let dynMetrics ← Afferent.Canopy.Reactive.enableDynWidgetMetrics
  let assets ← loadStressAssets
  let app ← initStressApp assets fanoutDynamicRender
  try
    DynWidgetMetrics.reset dynMetrics
    let config : StressConfig := { warmupFrames := 2, sampleFrames := 8 }
    let result ← runStress app.render app.inputs assets.fontRegistry app.componentRegistry config
    let dynSnap ← DynWidgetMetrics.snapshot dynMetrics
    IO.println (StressResult.format "fanout dynWidget grid" result)
    IO.println s!"dynWidget rebuilds: count={dynSnap.rebuildCount}, total={fmtMs (nanosToMs dynSnap.rebuildNanos)}ms"

    ensure (result.widgetCount >= 800)
      s!"Expected at least 800 widgets, got {result.widgetCount}"
    ensure (result.targetCount >= 70)
      s!"Expected at least 70 interactive targets, got {result.targetCount}"
    ensure (dynSnap.rebuildCount >= config.sampleFrames)
      s!"Expected dynWidget rebuilds >= {config.sampleFrames}, got {dynSnap.rebuildCount}"
  finally
    app.shutdown
    Afferent.Canopy.Reactive.disableDynWidgetMetrics
    destroyStressAssets assets

end AfferentDemosTests.WidgetTreePerfStress
