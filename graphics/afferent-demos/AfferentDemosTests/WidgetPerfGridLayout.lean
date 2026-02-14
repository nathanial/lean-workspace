/-
  WidgetPerf Grid Layout Tests
  Reproduces empty row/column slot behavior in low-count grids.
-/
import Crucible
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Perf.Widget.App
import Trellis

namespace AfferentDemosTests.WidgetPerfGridLayout

open Crucible
open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Demos.WidgetPerf
open Trellis

private structure TestAssets where
  registry : FontRegistry
  fontCanopy : Font
  fontCanopySmall : Font
  theme : Theme

private def loadTestAssets : IO TestAssets := do
  let fontCanopy ← Font.load "/System/Library/Fonts/Monaco.ttf" 14
  let fontCanopySmall ← Font.load "/System/Library/Fonts/Monaco.ttf" 10
  let (reg1, canopyId) := FontRegistry.empty.register fontCanopy "canopy"
  let (reg2, canopySmallId) := reg1.register fontCanopySmall "canopySmall"
  let registry := reg2.setDefault fontCanopy
  let theme : Theme := { Theme.dark with font := canopyId, smallFont := canopySmallId }
  pure { registry, fontCanopy, fontCanopySmall, theme }

private def destroyTestAssets (assets : TestAssets) : IO Unit := do
  Font.destroy assets.fontCanopy
  Font.destroy assets.fontCanopySmall

private def widgetGridRender (wtype : WidgetType) (instanceCount : Nat) : ReactiveM ComponentRender := do
  let (_, render) ← runWidget do
    renderWidgetGrid wtype instanceCount
  pure render

private def buildWidgetTree (wtype : WidgetType) (instanceCount : Nat) : IO Widget := do
  let assets ← loadTestAssets
  let spiderEnv ← Reactive.Host.SpiderEnv.new Reactive.Host.defaultErrorHandler
  try
    let widget ← (do
      let (events, _inputs) ← Afferent.Canopy.Reactive.createInputs
        assets.registry assets.theme (some assets.fontCanopy)
      let render ← ReactiveM.run events (widgetGridRender wtype instanceCount)
      let builder ← SpiderM.liftIO render
      pure (Afferent.Arbor.buildFrom 0 builder)
    ).run spiderEnv
    pure widget
  finally
    spiderEnv.currentScope.dispose
    destroyTestAssets assets

private def buildWidgetTreeInScrollConfig (wtype : WidgetType) (instanceCount : Nat)
    (rootW rootH scrollW scrollH : Float) : IO Widget := do
  let assets ← loadTestAssets
  let spiderEnv ← Reactive.Host.SpiderEnv.new Reactive.Host.defaultErrorHandler
  try
    let widget ← (do
      let (events, _inputs) ← Afferent.Canopy.Reactive.createInputs
        assets.registry assets.theme (some assets.fontCanopy)
      let render ← ReactiveM.run events do
        let (_, render) ← runWidget do
          let rootStyle : BoxStyle := {
            width := .length rootW
            height := .length rootH
          }
          column' (gap := 0) (style := rootStyle) do
            let cfg : ScrollContainerConfig := {
              width := scrollW
              height := scrollH
              verticalScroll := true
              horizontalScroll := false
              fillWidth := true
              fillHeight := true
              scrollbarVisibility := .always
            }
            let (_, _) ← scrollContainer cfg do
              renderWidgetGrid wtype instanceCount
            pure ()
        pure render
      let builder ← SpiderM.liftIO render
      pure (Afferent.Arbor.buildFrom 0 builder)
    ).run spiderEnv
    pure widget
  finally
    spiderEnv.currentScope.dispose
    destroyTestAssets assets

private def buildWidgetTreeInScroll (wtype : WidgetType) (instanceCount : Nat)
    (viewportW viewportH : Float := 1800) : IO Widget := do
  let rootW := viewportW
  let rootH := viewportH
  let scrollW := viewportW
  let scrollH := viewportH
  buildWidgetTreeInScrollConfig wtype instanceCount rootW rootH scrollW scrollH

private partial def firstGridProps? (widget : Widget) : Option Trellis.GridContainer :=
  match widget with
  | .grid _ _ props _ _ _ => some props
  | .flex _ _ _ _ children _ =>
    children.foldl (fun found child =>
      match found with
      | some _ => found
      | none => firstGridProps? child
    ) none
  | .scroll _ _ _ _ _ _ _ child _ =>
    firstGridProps? child
  | _ => none

private def gridSlotCount (props : Trellis.GridContainer) : Nat :=
  props.templateRows.tracks.size * props.templateColumns.tracks.size

private def requireGridProps (widget : Widget) : IO Trellis.GridContainer := do
  match firstGridProps? widget with
  | some props => pure props
  | none => throw <| IO.userError "No grid container found in widget tree"

private partial def firstScrollData? (widget : Widget) : Option (Float × Float × Widget) :=
  match widget with
  | .scroll _ _ _ _ contentW contentH _ child _ => some (contentW, contentH, child)
  | .flex _ _ _ _ children _ =>
    children.foldl (fun found child =>
      match found with
      | some _ => found
      | none => firstScrollData? child
    ) none
  | .grid _ _ _ _ children _ =>
    children.foldl (fun found child =>
      match found with
      | some _ => found
      | none => firstScrollData? child
    ) none
  | _ => none

private partial def customIds (widget : Widget) : Array WidgetId :=
  match widget with
  | .custom id _ _ _ _ => #[id]
  | .flex _ _ _ _ children _ =>
    children.foldl (fun acc child => acc ++ customIds child) #[]
  | .grid _ _ _ _ children _ =>
    children.foldl (fun acc child => acc ++ customIds child) #[]
  | .scroll _ _ _ _ _ _ _ child _ =>
    customIds child
  | _ => #[]

private def buildWidgetPerfBarChartTabLikeTree
    (instanceCount : Nat := 10)
    (rootW rootH windowW windowH : Float := 1800) : IO Widget := do
  let assets ← loadTestAssets
  let spiderEnv ← Reactive.Host.SpiderEnv.new Reactive.Host.defaultErrorHandler
  try
    let widget ← (do
      let (events, _inputs) ← Afferent.Canopy.Reactive.createInputs
        assets.registry assets.theme (some assets.fontCanopy)
      let render ← ReactiveM.run events do
        let (_, render) ← runWidget do
          let rootStyle : BoxStyle := {
            backgroundColor := some (Color.gray 0.1)
            padding := EdgeInsets.uniform 16
            width := .length rootW
            height := .length rootH
            flexItem := some (FlexItem.growing 1)
          }
          column' (gap := 16) (style := rootStyle) do
            heading1' "Widget Performance Test"
            caption' "Select a widget type and instance count"
            let contentRowStyle : BoxStyle := {
              flexItem := some (FlexItem.growing 1)
              width := .percent 1.0
              height := .percent 1.0
            }
            flexRow' { FlexContainer.row 16 with alignItems := .stretch }
                (style := contentRowStyle) do
              let leftPanelStyle : BoxStyle := {
                minWidth := some 220
                flexItem := some (FlexItem.fixed 220)
                height := .percent 1.0
              }
              column' (gap := 8) (style := leftPanelStyle) do
                caption' "Widget type:"
                caption' "Bar Chart"
                caption' "Instance count:"
                caption' s!"{instanceCount}"
                pure ()
              let rightPanelStyle : BoxStyle := {
                flexItem := some (FlexItem.growing 1)
                width := .percent 1.0
                height := .percent 1.0
              }
              column' (gap := 0) (style := rightPanelStyle) do
                if shouldUseGridScroll .barChart instanceCount windowH then
                  let cfg : ScrollContainerConfig := {
                    width := windowW
                    height := windowH
                    verticalScroll := true
                    horizontalScroll := false
                    fillWidth := true
                    fillHeight := true
                    scrollbarVisibility := .always
                  }
                  let (_, _) ← scrollContainer cfg do
                    renderWidgetGrid .barChart instanceCount (fillRows := false)
                  pure ()
                else
                  renderWidgetGrid .barChart instanceCount (fillRows := true)
        pure render
      let builder ← SpiderM.liftIO render
      pure (Afferent.Arbor.buildFrom 0 builder)
    ).run spiderEnv
    pure widget
  finally
    spiderEnv.currentScope.dispose
    destroyTestAssets assets

private def measureAndLayout (widget : Widget) (viewportW viewportH : Float := 1800)
    : IO (MeasureResult × Trellis.LayoutResult) := do
  let assets ← loadTestAssets
  try
    let measured ← Afferent.runWithFonts assets.registry
      (Afferent.Arbor.measureWidget widget viewportW viewportH)
    let layouts := Trellis.layout measured.node viewportW viewportH
    pure (measured, layouts)
  finally
    destroyTestAssets assets

private def assertNoTrailingEmptyRows (label : String) (instanceCount : Nat) (props : Trellis.GridContainer) : IO Unit := do
  let rows := props.templateRows.tracks.size
  let cols := props.templateColumns.tracks.size
  let slots := gridSlotCount props
  ensure (instanceCount == 0 || cols > 0)
    s!"{label}: expected positive column count for non-empty grid (count={instanceCount}, cols={cols})"
  ensure (slots >= instanceCount)
    s!"{label}: slot count under-allocated (count={instanceCount}, rows={rows}, cols={cols}, slots={slots})"
  let slack := slots - instanceCount
  ensure (slack < cols || instanceCount == 0)
    s!"{label}: found at least one fully empty trailing row (count={instanceCount}, rows={rows}, cols={cols}, slots={slots}, slack={slack})"

private def minCustomHeight (widget : Widget) (layouts : Trellis.LayoutResult) : IO Float := do
  let ids := customIds widget
  ensure (ids.size > 0) "Expected at least one custom node"
  let mut minH : Float := 1e9
  for cid in ids do
    match layouts.get cid with
    | some layout =>
      if layout.borderRect.height < minH then
        minH := layout.borderRect.height
    | none => pure ()
  pure minH

testSuite "WidgetPerf Grid Layout"

test "label grid uses exact slot count for low instance count" := do
  let instanceCount := 10
  let widget ← buildWidgetTree .label instanceCount
  let props ← requireGridProps widget
  let rows := props.templateRows.tracks.size
  let cols := props.templateColumns.tracks.size
  rows ≡ 1
  cols ≡ 10
  gridSlotCount props ≡ instanceCount

test "mixed grid should not allocate empty track slots (repro)" := do
  let instanceCount := 10
  let widget ← buildWidgetTree .mixed instanceCount
  let props ← requireGridProps widget
  let slots := gridSlotCount props
  ensure (slots == instanceCount)
    s!"Expected mixed grid to allocate exactly {instanceCount} slots, got {slots} (rows={props.templateRows.tracks.size}, cols={props.templateColumns.tracks.size})"

test "mixed grid should avoid trailing empty rows (repro)" := do
  let instanceCount := 48
  let widget ← buildWidgetTree .mixed instanceCount
  let props ← requireGridProps widget
  let slots := gridSlotCount props
  ensure (slots == instanceCount)
    s!"Expected mixed grid to allocate exactly {instanceCount} slots, got {slots} (rows={props.templateRows.tracks.size}, cols={props.templateColumns.tracks.size})"

test "label grid has no trailing empty rows across representative counts" := do
  for instanceCount in [1, 2, 3, 10, 11, 17, 19, 20, 21, 48, 99, 100, 101, 1000, 2000, 10000] do
    let widget ← buildWidgetTree .label instanceCount
    let props ← requireGridProps widget
    assertNoTrailingEmptyRows "label" instanceCount props

test "mixed grid has no trailing empty rows across representative counts" := do
  for instanceCount in [1, 2, 3, 10, 11, 17, 19, 20, 21, 48, 99, 100, 101, 1000, 2000, 10000] do
    let widget ← buildWidgetTree .mixed instanceCount
    let props ← requireGridProps widget
    assertNoTrailingEmptyRows "mixed" instanceCount props

test "scroll content height is close to actual child layout height (label, low count)" := do
  let viewportW := 1800.0
  let viewportH := 1200.0
  let widget ← buildWidgetTreeInScroll .label 10 viewportW viewportH
  let measuredAndLayouts ← measureAndLayout widget viewportW viewportH
  let layouts := measuredAndLayouts.2
  let (contentW, contentH, child) ←
    match firstScrollData? widget with
    | some data => pure data
    | none => throw <| IO.userError "No scroll widget found in tree"
  let childLayout ←
    match layouts.get child.id with
    | some layout => pure layout
    | none => throw <| IO.userError "Scroll child layout not found"
  let childH := childLayout.borderRect.height
  let slack := contentH - max viewportH childH
  ensure (contentW >= viewportW)
    s!"Expected scroll content width >= viewport ({contentW} < {viewportW})"
  ensure (slack <= 64)
    s!"Unexpected scroll content height slack (contentH={contentH}, viewportH={viewportH}, childH={childH}, slack={slack})"

test "scroll content height is close to actual child layout height (heatmap, low count)" := do
  let viewportW := 1800.0
  let viewportH := 1200.0
  let widget ← buildWidgetTreeInScroll .heatmap 10 viewportW viewportH
  let measuredAndLayouts ← measureAndLayout widget viewportW viewportH
  let layouts := measuredAndLayouts.2
  let (contentW, contentH, child) ←
    match firstScrollData? widget with
    | some data => pure data
    | none => throw <| IO.userError "No scroll widget found in tree"
  let childLayout ←
    match layouts.get child.id with
    | some layout => pure layout
    | none => throw <| IO.userError "Scroll child layout not found"
  let childH := childLayout.borderRect.height
  let slack := contentH - max viewportH childH
  ensure (contentW >= viewportW)
    s!"Expected scroll content width >= viewport ({contentW} < {viewportW})"
  ensure (slack <= 64)
    s!"Unexpected scroll content height slack (contentH={contentH}, viewportH={viewportH}, childH={childH}, slack={slack})"

test "widget perf tab logic: bar chart x10 fills height with no phantom scroll" := do
  let rootW := 1800.0
  let rootH := 720.0
  let windowW := 1800.0
  let windowH := 1200.0
  let widget ← buildWidgetPerfBarChartTabLikeTree 10 rootW rootH windowW windowH
  let (_, layouts) ← measureAndLayout widget rootW rootH
  ensure (firstScrollData? widget |>.isNone)
    "Did not expect a scroll container for 10 instances"
  let minChartH ← minCustomHeight widget layouts
  ensure (minChartH >= 180.0)
    s!"Expected bar chart widgets to expand vertically (min chart height={minChartH})"

test "widget perf tab logic: bar chart x100 still fills height without phantom scroll" := do
  let rootW := 1800.0
  let rootH := 720.0
  let windowW := 1800.0
  let windowH := 1200.0
  let widget ← buildWidgetPerfBarChartTabLikeTree 100 rootW rootH windowW windowH
  let (_, layouts) ← measureAndLayout widget rootW rootH
  ensure (firstScrollData? widget |>.isNone)
    "Did not expect a scroll container for 100 instances when intrinsic content fits the viewport"
  let minChartH ← minCustomHeight widget layouts
  ensure (minChartH >= 90.0)
    s!"Expected bar chart widgets to stretch beyond intrinsic height for x100 (min chart height={minChartH})"

end AfferentDemosTests.WidgetPerfGridLayout
