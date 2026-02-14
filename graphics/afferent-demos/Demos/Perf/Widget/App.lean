/-
  WidgetPerf - Diagnostic page to isolate widget performance.
  Select a widget type and instance count from the left panel.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import AfferentProgressBars.Canopy.Widget.Display.ProgressBar
import AfferentSpinners.Canopy.Widget.Display.Spinner
import AfferentCharts.Canopy.Widget.Charts
import Demos.Core.Demo

open Reactive Reactive.Host
open Afferent CanvasM
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

namespace Demos.WidgetPerf

private def widgetGridColumns : Nat := 20
private def defaultWidgetInstanceCount : Nat := 10
private def widgetInstanceOptions : Array Nat := #[1, 10, 100, 1000, 2000, 10000]
private def widgetInstanceOptionLabels : Array String := widgetInstanceOptions.map toString
private def widgetGridGap : Float := 6
private def defaultWidgetInstanceIndex : Nat :=
  (widgetInstanceOptions.findIdx? (· == defaultWidgetInstanceCount)).getD 0

private def gridRowCount (instanceCount columns : Nat) : Nat :=
  if instanceCount == 0 then 0 else (instanceCount + columns - 1) / columns

/-- Clamp panel dimensions to a positive usable range. -/
private def clampPanelDims (width height : Float) : Float × Float :=
  (max 1.0 width, max 1.0 height)

/-- Resolve a named component's content size from a layout snapshot. -/
private def componentContentDims?
    (name : ComponentId)
    (componentMap : Std.HashMap ComponentId WidgetId)
    (layouts : Trellis.LayoutResult) : Option (Float × Float) := do
  let wid ← componentMap.get? name
  let layout ← layouts.get wid
  pure (clampPanelDims layout.contentRect.width layout.contentRect.height)

/-- Clamp invalid aspect hints to a sane fallback. -/
private def normalizeAspectHint (aspectHint : Float) : Float :=
  if aspectHint.isNaN || aspectHint <= 0 then 1.0 else aspectHint

/-- Choose grid dimensions bounded by `maxColumns`, preferring a column/row ratio
    close to the provided viewport aspect ratio while still minimizing slack. -/
private def chooseGridDims (instanceCount maxColumns : Nat) (aspectHint : Float := 1.0) : Nat × Nat :=
  if instanceCount == 0 then
    (0, 0)
  else
    let targetAspect := normalizeAspectHint aspectHint
    let maxCols := Nat.max 1 (Nat.min maxColumns instanceCount)
    let eps := 0.000001
    let step := fun best cols =>
      let rows := gridRowCount instanceCount cols
      let slots := rows * cols
      let slack := slots - instanceCount
      let ratio := (Float.ofNat cols) / (Float.ofNat (Nat.max 1 rows))
      let aspectError := Float.abs (ratio - targetAspect)
      let (bestCols, bestRows, bestAspectError, bestSlack) := best
      let betterAspect := aspectError + eps < bestAspectError
      let sameAspect := Float.abs (aspectError - bestAspectError) <= eps
      if betterAspect || (sameAspect && (slack < bestSlack || (slack == bestSlack && cols > bestCols))) then
        (cols, rows, aspectError, slack)
      else
        (bestCols, bestRows, bestAspectError, bestSlack)
    let candidates := (List.range maxCols).map (· + 1)
    let initialRows := gridRowCount instanceCount 1
    let initialRatio := (Float.ofNat 1) / (Float.ofNat (Nat.max 1 initialRows))
    let initialAspectError := Float.abs (initialRatio - targetAspect)
    let initialSlack := initialRows - instanceCount
    let (cols, rows, _, _) := candidates.foldl step (1, initialRows, initialAspectError, initialSlack)
    (cols, rows)

/-- Widget types we can test. -/
inductive WidgetType
  -- Simple
  | label | caption | spacer | panel
  -- Controls
  | button | checkbox | switch | radioGroup
  | slider | stepper | progressBar | progressIndeterminate
  | dropdown
  -- Spinners (standard)
  | spinnerCircleDots | spinnerRing | spinnerBouncingDots
  | spinnerBars | spinnerDualRing
  -- Spinners (creative)
  | spinnerOrbit | spinnerPulse | spinnerHelix | spinnerWave | spinnerSpiral
  | spinnerClock | spinnerPendulum | spinnerRipple | spinnerHeartbeat | spinnerGears
  -- Charts
  | barChart | lineChart | areaChart
  | pieChart | donutChart
  | scatterPlot | horizontalBarChart | bubbleChart
  | histogram | boxPlot | heatmap
  | stackedBarChart | groupedBarChart | stackedAreaChart
  | radarChart | candlestickChart | waterfallChart
  | gaugeChart | funnelChart | treemapChart | sankeyDiagram
  -- Mixed
  | mixed
deriving BEq, Repr

def WidgetType.name : WidgetType → String
  | .label => "Label"
  | .caption => "Caption"
  | .spacer => "Spacer"
  | .panel => "Panel"
  | .button => "Button"
  | .checkbox => "Checkbox"
  | .switch => "Switch"
  | .radioGroup => "Radio Group"
  | .slider => "Slider"
  | .stepper => "Stepper"
  | .progressBar => "Progress Bar"
  | .progressIndeterminate => "Progress (Indeterminate)"
  | .dropdown => "Dropdown"
  -- Spinners (standard)
  | .spinnerCircleDots => "Spinner: Circle Dots"
  | .spinnerRing => "Spinner: Ring"
  | .spinnerBouncingDots => "Spinner: Bouncing Dots"
  | .spinnerBars => "Spinner: Bars"
  | .spinnerDualRing => "Spinner: Dual Ring"
  -- Spinners (creative)
  | .spinnerOrbit => "Spinner: Orbit"
  | .spinnerPulse => "Spinner: Pulse"
  | .spinnerHelix => "Spinner: Helix"
  | .spinnerWave => "Spinner: Wave"
  | .spinnerSpiral => "Spinner: Spiral"
  | .spinnerClock => "Spinner: Clock"
  | .spinnerPendulum => "Spinner: Pendulum"
  | .spinnerRipple => "Spinner: Ripple"
  | .spinnerHeartbeat => "Spinner: Heartbeat"
  | .spinnerGears => "Spinner: Gears"
  -- Charts
  | .barChart => "Bar Chart"
  | .lineChart => "Line Chart"
  | .areaChart => "Area Chart"
  | .pieChart => "Pie Chart"
  | .donutChart => "Donut Chart"
  | .scatterPlot => "Scatter Plot"
  | .horizontalBarChart => "Horizontal Bar"
  | .bubbleChart => "Bubble Chart"
  | .histogram => "Histogram"
  | .boxPlot => "Box Plot"
  | .heatmap => "Heatmap"
  | .stackedBarChart => "Stacked Bar"
  | .groupedBarChart => "Grouped Bar"
  | .stackedAreaChart => "Stacked Area"
  | .radarChart => "Radar Chart"
  | .candlestickChart => "Candlestick"
  | .waterfallChart => "Waterfall"
  | .gaugeChart => "Gauge"
  | .funnelChart => "Funnel"
  | .treemapChart => "Treemap"
  | .sankeyDiagram => "Sankey"
  | .mixed => "Mixed (All)"

/-- All widget types except mixed (the renderable set for the mixed grid). -/
def renderableWidgetTypes : Array WidgetType := #[
  .label, .caption, .spacer, .panel,
  .button, .checkbox, .switch, .radioGroup,
  .slider, .stepper, .progressBar, .progressIndeterminate,
  .dropdown,
  -- Spinners (standard)
  .spinnerCircleDots, .spinnerRing, .spinnerBouncingDots,
  .spinnerBars, .spinnerDualRing,
  -- Spinners (creative)
  .spinnerOrbit, .spinnerPulse, .spinnerHelix, .spinnerWave, .spinnerSpiral,
  .spinnerClock, .spinnerPendulum, .spinnerRipple, .spinnerHeartbeat, .spinnerGears,
  -- Charts
  .barChart, .lineChart, .areaChart,
  .pieChart, .donutChart,
  .scatterPlot, .horizontalBarChart, .bubbleChart,
  .histogram, .boxPlot, .heatmap,
  .stackedBarChart, .groupedBarChart, .stackedAreaChart,
  .radarChart, .candlestickChart, .waterfallChart,
  .gaugeChart, .funnelChart, .treemapChart, .sankeyDiagram
]

def allWidgetTypes : Array WidgetType := #[
  .label, .caption, .spacer, .panel,
  .button, .checkbox, .switch, .radioGroup,
  .slider, .stepper, .progressBar, .progressIndeterminate,
  .dropdown,
  -- Spinners (standard)
  .spinnerCircleDots, .spinnerRing, .spinnerBouncingDots,
  .spinnerBars, .spinnerDualRing,
  -- Spinners (creative)
  .spinnerOrbit, .spinnerPulse, .spinnerHelix, .spinnerWave, .spinnerSpiral,
  .spinnerClock, .spinnerPendulum, .spinnerRipple, .spinnerHeartbeat, .spinnerGears,
  -- Charts
  .barChart, .lineChart, .areaChart,
  .pieChart, .donutChart,
  .scatterPlot, .horizontalBarChart, .bubbleChart,
  .histogram, .boxPlot, .heatmap,
  .stackedBarChart, .groupedBarChart, .stackedAreaChart,
  .radarChart, .candlestickChart, .waterfallChart,
  .gaugeChart, .funnelChart, .treemapChart, .sankeyDiagram,
  -- Mixed
  .mixed
]

def widgetTypeNames : Array String := allWidgetTypes.map WidgetType.name

/-- Sample data for charts. -/
def sampleBarData : Array Float := #[42.0, 78.0, 56.0, 91.0]
def sampleBarLabels : Array String := #["Q1", "Q2", "Q3", "Q4"]

def sampleSankeyData : SankeyDiagram.Data :=
  let nodes : Array SankeyDiagram.Node := #[
    { id := "a", label := "A", column := 0 },
    { id := "b", label := "B", column := 0 },
    { id := "c", label := "C", column := 1 },
    { id := "d", label := "D", column := 2 },
    { id := "e", label := "E", column := 2 }
  ]
  let links : Array SankeyDiagram.Link := #[
    { source := "a", target := "c", value := 50 },
    { source := "b", target := "c", value := 30 },
    { source := "c", target := "d", value := 45 },
    { source := "c", target := "e", value := 35 }
  ]
  { nodes, links }

/-- Render a single widget of the given type in a grid cell. -/
def renderWidget (wtype : WidgetType) (index : Nat)
    (fillCellWidth : Bool := true) (fillCellHeight : Bool := true) : WidgetM Unit := do
  let cellStyle : BoxStyle := {
    width := if fillCellWidth then .percent 1.0 else .auto
    height := if fillCellHeight then .percent 1.0 else .auto
    flexItem := if fillCellWidth || fillCellHeight then some (FlexItem.growing 1) else none
  }
  column' (gap := 0) (style := cellStyle) do match wtype with
  -- Simple
  | .label => heading3' s!"Label {index}"
  | .caption => caption' s!"Caption {index}"
  | .spacer => spacer' 80 30
  | .panel =>
    outlinedPanel' 6 do
      caption' s!"Panel {index}"

  -- Controls
  | .button =>
    let _ ← button s!"Btn {index}" .primary
    pure ()
  | .checkbox =>
    let _ ← checkbox s!"Chk {index}" false
    pure ()
  | .switch =>
    let _ ← switch none false
    pure ()
  | .radioGroup =>
    let opts : Array RadioOption := #[{ label := "A", value := "a" }, { label := "B", value := "b" }]
    let _ ← radioGroup opts "a"
    pure ()
  | .slider =>
    let _ ← slider none 0.5
    pure ()
  | .stepper =>
    let config : StepperConfig := { min := 0, max := 10, step := 1, width := 80 }
    let _ ← stepper 5 config
    pure ()
  | .progressBar =>
    let _ ← AfferentProgressBars.Canopy.progressBar 0.65 .primary none false
    pure ()
  | .progressIndeterminate =>
    let _ ← AfferentProgressBars.Canopy.progressBarIndeterminate .primary none
    pure ()
  | .dropdown =>
    let opts := #["Apple", "Banana", "Cherry"]
    let _ ← dropdown opts 0
    pure ()

  -- Spinners (standard)
  | .spinnerCircleDots =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .circleDots, dims := { size := 50 } }
    pure ()
  | .spinnerRing =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .ring, dims := { size := 50 } }
    pure ()
  | .spinnerBouncingDots =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .bouncingDots, dims := { size := 50 } }
    pure ()
  | .spinnerBars =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .bars, dims := { size := 50 } }
    pure ()
  | .spinnerDualRing =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .dualRing, dims := { size := 50 } }
    pure ()

  -- Spinners (creative)
  | .spinnerOrbit =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .orbit, dims := { size := 50 } }
    pure ()
  | .spinnerPulse =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .pulse, dims := { size := 50 } }
    pure ()
  | .spinnerHelix =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .helix, dims := { size := 50 } }
    pure ()
  | .spinnerWave =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .wave, dims := { size := 50 } }
    pure ()
  | .spinnerSpiral =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .spiral, dims := { size := 50 } }
    pure ()
  | .spinnerClock =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .clock, dims := { size := 50 } }
    pure ()
  | .spinnerPendulum =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .pendulum, dims := { size := 50 } }
    pure ()
  | .spinnerRipple =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .ripple, dims := { size := 50 } }
    pure ()
  | .spinnerHeartbeat =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .heartbeat, dims := { size := 50 } }
    pure ()
  | .spinnerGears =>
    let _ ← AfferentSpinners.Canopy.spinner { variant := .gears, dims := { size := 50 } }
    pure ()

  -- Charts
  | .barChart =>
    let dims : BarChart.Dimensions := { width := 140, height := 80, marginLeft := 25 }
    let dataDyn ← Dynamic.pureM sampleBarData
    let _ ← barChart dataDyn sampleBarLabels (dims := dims)
    pure ()
  | .lineChart =>
    let dims : LineChart.Dimensions := { width := 140, height := 80, marginLeft := 25 }
    let dataDyn ← Dynamic.pureM sampleBarData
    let _ ← lineChart dataDyn sampleBarLabels (dims := dims)
    pure ()
  | .areaChart =>
    let dims : AreaChart.Dimensions := { width := 140, height := 80, marginLeft := 25 }
    let dataDyn ← Dynamic.pureM sampleBarData
    let _ ← areaChart dataDyn sampleBarLabels (dims := dims)
    pure ()
  | .pieChart =>
    let slices : Array PieChart.Slice := #[
      { value := 40.0, label := some "A" },
      { value := 30.0, label := some "B" },
      { value := 30.0, label := some "C" }
    ]
    let dims : PieChart.Dimensions := { width := 100, height := 80, radius := 30, showLabels := false }
    let slicesDyn ← Dynamic.pureM slices
    let _ ← pieChart slicesDyn dims
    pure ()
  | .donutChart =>
    let slices : Array DonutChart.Slice := #[
      { value := 40.0, label := some "A" },
      { value := 30.0, label := some "B" },
      { value := 30.0, label := some "C" }
    ]
    let dims : DonutChart.Dimensions := { width := 100, height := 80, outerRadius := 30, innerRadius := 18, showLabels := false }
    let slicesDyn ← Dynamic.pureM slices
    let _ ← donutChart slicesDyn dims
    pure ()
  | .scatterPlot =>
    let points : Array ScatterPlot.DataPoint := #[
      { x := 10, y := 20 }, { x := 30, y := 40 }, { x := 50, y := 30 },
      { x := 70, y := 60 }, { x := 90, y := 50 }
    ]
    let dims : ScatterPlot.Dimensions := { width := 140, height := 80, marginLeft := 25 }
    let pointsDyn ← Dynamic.pureM points
    let _ ← scatterPlot pointsDyn dims
    pure ()
  | .horizontalBarChart =>
    let dims : HorizontalBarChart.Dimensions := { width := 140, height := 80, marginLeft := 35 }
    let dataDyn ← Dynamic.pureM sampleBarData
    let _ ← horizontalBarChart dataDyn sampleBarLabels (dims := dims)
    pure ()
  | .bubbleChart =>
    let points : Array BubbleChart.DataPoint := #[
      { x := 20, y := 30, size := 5 }, { x := 50, y := 60, size := 8 }, { x := 80, y := 40, size := 6 }
    ]
    let dims : BubbleChart.Dimensions := { width := 140, height := 80, marginLeft := 25, minBubbleRadius := 3, maxBubbleRadius := 12 }
    let pointsDyn ← Dynamic.pureM points
    let _ ← bubbleChart pointsDyn dims
    pure ()
  | .histogram =>
    let data : Array Float := #[10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80]
    let dims : Histogram.Dimensions := { width := 140, height := 80, marginLeft := 25 }
    let dataDyn ← Dynamic.pureM data
    let _ ← histogram dataDyn (dims := dims)
    pure ()
  | .boxPlot =>
    let data := #[#[10.0, 20.0, 30.0, 40.0, 50.0], #[15.0, 25.0, 35.0, 45.0, 55.0]]
    let dims : BoxPlot.Dimensions := { width := 140, height := 80, marginLeft := 25, boxWidth := 25 }
    let dataDyn ← Dynamic.pureM data
    let _ ← boxPlotFromData dataDyn #["A", "B"] dims
    pure ()
  | .heatmap =>
    let values : Array (Array Float) := #[#[1.0, 0.5, 0.2], #[0.5, 1.0, 0.7], #[0.2, 0.7, 1.0]]
    let dims : Heatmap.Dimensions := { width := 100, height := 80, marginLeft := 15, marginTop := 15, showValues := false }
    let valuesDyn ← Dynamic.pureM values
    let _ ← correlationMatrix valuesDyn #["A", "B", "C"] dims
    pure ()
  | .stackedBarChart =>
    let data : StackedBarChart.Data := {
      categories := #["Q1", "Q2"]
      series := #[{ name := "A", values := #[30.0, 40.0] }, { name := "B", values := #[20.0, 30.0] }]
    }
    let dims : StackedBarChart.Dimensions := { width := 140, height := 80, marginLeft := 25 }
    let dataDyn ← Dynamic.pureM data
    let _ ← stackedBarChart dataDyn dims
    pure ()
  | .groupedBarChart =>
    let data : GroupedBarChart.Data := {
      categories := #["Q1", "Q2"]
      series := #[{ name := "A", values := #[30.0, 40.0] }, { name := "B", values := #[20.0, 30.0] }]
    }
    let dims : GroupedBarChart.Dimensions := { width := 140, height := 80, marginLeft := 25 }
    let dataDyn ← Dynamic.pureM data
    let _ ← groupedBarChart dataDyn dims
    pure ()
  | .stackedAreaChart =>
    let data : StackedAreaChart.Data := {
      labels := #["A", "B", "C"]
      series := #[{ name := "X", values := #[10.0, 20.0, 15.0] }, { name := "Y", values := #[20.0, 15.0, 25.0] }]
    }
    let dims : StackedAreaChart.Dimensions := { width := 140, height := 80, marginLeft := 25 }
    let dataDyn ← Dynamic.pureM data
    let _ ← stackedAreaChart dataDyn dims
    pure ()
  | .radarChart =>
    let data : RadarChart.Data := {
      axisLabels := #["A", "B", "C", "D", "E"]
      series := #[{ name := "X", values := #[80.0, 70.0, 90.0, 60.0, 75.0] }]
    }
    let dims : RadarChart.Dimensions := { width := 120, height := 100, radius := 40 }
    let dataDyn ← Dynamic.pureM data
    let _ ← radarChart dataDyn dims
    pure ()
  | .candlestickChart =>
    let candles : Array CandlestickChart.Candle := #[
      { openPrice := 100.0, highPrice := 105.0, lowPrice := 98.0, closePrice := 103.0, label := some "1" },
      { openPrice := 103.0, highPrice := 108.0, lowPrice := 101.0, closePrice := 106.0, label := some "2" },
      { openPrice := 106.0, highPrice := 110.0, lowPrice := 104.0, closePrice := 105.0, label := some "3" }
    ]
    let dims : CandlestickChart.Dimensions := { width := 140, height := 80, marginLeft := 30 }
    let dataDyn ← Dynamic.pureM ({ candles } : CandlestickChart.Data)
    let _ ← candlestickChart dataDyn (dims := dims)
    pure ()
  | .waterfallChart =>
    let bars : Array WaterfallChart.Bar := #[
      { label := "Start", value := 100.0, barType := .initial },
      { label := "Add", value := 30.0, barType := .increase },
      { label := "Sub", value := -20.0, barType := .decrease },
      { label := "End", value := 110.0, barType := .total }
    ]
    let dims : WaterfallChart.Dimensions := { width := 140, height := 80, marginLeft := 30 }
    let dataDyn ← Dynamic.pureM ({ bars } : WaterfallChart.Data)
    let _ ← waterfallChart dataDyn (dims := dims)
    pure ()
  | .gaugeChart =>
    let data : GaugeChart.Data := {
      value := 72.0, minValue := 0.0, maxValue := 100.0
      segments := #[
        { startFrac := 0.0, endFrac := 0.6, color := Color.rgba 0.20 0.69 0.35 1.0 },
        { startFrac := 0.6, endFrac := 0.8, color := Color.rgba 0.95 0.75 0.10 1.0 },
        { startFrac := 0.8, endFrac := 1.0, color := Color.rgba 0.90 0.25 0.20 1.0 }
      ]
    }
    let dims : GaugeChart.Dimensions := { width := 100, height := 70, radius := 30 }
    let dataDyn ← Dynamic.pureM data
    let _ ← gaugeChart dataDyn (dims := dims)
    pure ()
  | .funnelChart =>
    let stages : Array FunnelChart.Stage := #[
      { label := "A", value := 100.0 }, { label := "B", value := 60.0 }, { label := "C", value := 30.0 }
    ]
    let dims : FunnelChart.Dimensions := { width := 140, height := 80, marginRight := 45 }
    let dataDyn ← Dynamic.pureM ({ stages } : FunnelChart.Data)
    let _ ← funnelChart dataDyn dims
    pure ()
  | .treemapChart =>
    let nodes : Array TreemapChart.TreeNode := #[
      { label := "A", value := 40 }, { label := "B", value := 30 },
      { label := "C", value := 20 }, { label := "D", value := 10 }
    ]
    let dims : TreemapChart.Dimensions := { width := 120, height := 80 }
    let dataDyn ← Dynamic.pureM ({ nodes } : TreemapChart.Data)
    let _ ← treemapChart dataDyn dims
    pure ()
  | .sankeyDiagram =>
    let dims : SankeyDiagram.Dimensions := {
      width := 160, height := 80
      marginLeft := 5, marginRight := 40
      marginTop := 5, marginBottom := 5
      nodeWidth := 6
      showLabels := true
      showValues := false
    }
    let dataDyn ← Dynamic.pureM sampleSankeyData
    let _ ← sankeyDiagram dataDyn dims
    pure ()
  | .mixed =>
    -- Mixed is handled at the grid level, not individual widget level
    caption' s!"Mixed {index}"

/-- Create a custom grid container that collects children's renders. -/
def gridCustom' (props : Trellis.GridContainer) (style : Afferent.Arbor.BoxStyle := {})
    (children : WidgetM α) : WidgetM α := do
  let (result, childRenders) ← runWidgetChildren children
  let render ← SpiderM.liftIO <| ComponentRender.memoizedChildren
    (childrenIO := pure childRenders)
    (combine := fun widgets => Afferent.Arbor.gridCustom props style widgets)
  emitRender render
  pure result

/-- Create a named column container that collects children's renders. -/
def namedColumnCustom' (name : ComponentId) (gap : Float := 0)
    (style : Afferent.Arbor.BoxStyle := {})
    (children : WidgetM α) : WidgetM α := do
  let (result, childRenders) ← runWidgetChildren children
  let render ← SpiderM.liftIO <| ComponentRender.memoizedChildren
    (childrenIO := pure childRenders)
    (combine := fun widgets => Afferent.Arbor.namedColumn name gap style widgets)
  emitRender render
  pure result

/-- Render a mixed grid with the requested total instance count. -/
def renderMixedGrid (instanceCount : Nat) (fillRows : Bool := true)
    (fillColumns : Bool := true) (aspectHint : Float := 1.0)
    (viewportWidthHint : Float := 0.0) (viewportHeightHint : Float := 0.0) : WidgetM Unit := do
  let minWidthHint := if viewportWidthHint > 0 then some viewportWidthHint else none
  let minHeightHint := if viewportHeightHint > 0 then some viewportHeightHint else none
  let containerStyle : BoxStyle := {
    flexItem := some (FlexItem.growing 1)
    width := if fillColumns then .percent 1.0 else .auto
    height := if fillRows then .percent 1.0 else .auto
    minWidth := if fillColumns then minWidthHint else none
    minHeight := if fillRows then minHeightHint else none
  }
  let numTypes := renderableWidgetTypes.size
  let maxCols := Nat.min numTypes widgetGridColumns
  let (numCols, numRows) := chooseGridDims instanceCount maxCols aspectHint
  let rowTrack := if fillRows then Trellis.TrackSize.minContentFr 1 else Trellis.TrackSize.auto
  let colTrack := if fillColumns then Trellis.TrackSize.minContentFr 1 else Trellis.TrackSize.auto
  let rowTemplate := Array.replicate numRows rowTrack
  let colTemplate := Array.replicate numCols colTrack
  let gridProps : Trellis.GridContainer := {
    Trellis.GridContainer.withTemplate rowTemplate colTemplate 6 with
    alignContent := .stretch
  }
  column' (gap := 6) (style := containerStyle) do
    heading3' s!"Mixed Grid ({instanceCount} instances across {numTypes} widget types)"
    let gridStyle : BoxStyle := {
      flexItem := some (FlexItem.growing 1)
      width := if fillColumns then .percent 1.0 else .auto
      height := if fillRows then .percent 1.0 else .auto
      minWidth := if fillColumns then minWidthHint else none
      minHeight := if fillRows then minHeightHint else none
    }
    gridCustom' gridProps gridStyle do
      for row in [:numRows] do
        for col in [:numCols] do
          let index := row * numCols + col
          if index < instanceCount then
            let wtype := renderableWidgetTypes.getD (index % numTypes) .label
            renderWidget wtype index
              (fillCellWidth := fillColumns)
              (fillCellHeight := fillRows)
          else
            pure ()

/-- Render a grid of widgets for a given type. -/
def renderWidgetGrid (wtype : WidgetType) (instanceCount : Nat)
    (fillRows : Bool := true) (fillColumns : Bool := true)
    (aspectHint : Float := 1.0)
    (viewportWidthHint : Float := 0.0) (viewportHeightHint : Float := 0.0) : WidgetM Unit := do
  if wtype == .mixed then
    renderMixedGrid instanceCount fillRows fillColumns aspectHint viewportWidthHint viewportHeightHint
  else
    let minWidthHint := if viewportWidthHint > 0 then some viewportWidthHint else none
    let minHeightHint := if viewportHeightHint > 0 then some viewportHeightHint else none
    let containerStyle : BoxStyle := {
      flexItem := some (FlexItem.growing 1)
      width := if fillColumns then .percent 1.0 else .auto
      height := if fillRows then .percent 1.0 else .auto
      minWidth := if fillColumns then minWidthHint else none
      minHeight := if fillRows then minHeightHint else none
    }
    let (effectiveColumns, rowCount) := chooseGridDims instanceCount widgetGridColumns aspectHint
    let rowTrack := if fillRows then Trellis.TrackSize.minContentFr 1 else Trellis.TrackSize.auto
    let colTrack := if fillColumns then Trellis.TrackSize.minContentFr 1 else Trellis.TrackSize.auto
    let rowTemplate := Array.replicate rowCount rowTrack
    let colTemplate := Array.replicate effectiveColumns colTrack
    let gridProps : Trellis.GridContainer := {
      Trellis.GridContainer.withTemplate rowTemplate colTemplate 6 with
      alignContent := .stretch
    }
    column' (gap := 6) (style := containerStyle) do
      heading3' s!"Grid of {wtype.name} ({instanceCount} instances)"
      let gridStyle : BoxStyle := {
        flexItem := some (FlexItem.growing 1)
        width := if fillColumns then .percent 1.0 else .auto
        height := if fillRows then .percent 1.0 else .auto
        minWidth := if fillColumns then minWidthHint else none
        minHeight := if fillRows then minHeightHint else none
      }
      gridCustom' gridProps gridStyle do
        for index in [0:instanceCount] do
          renderWidget wtype index
            (fillCellWidth := fillColumns)
            (fillCellHeight := fillRows)

/-- Application state. -/
structure AppState where
  render : ComponentRender

/-- Create the widget performance test application. -/
def createApp (env : DemoEnv) : ReactiveM AppState := do
  -- Pre-create a Dynamic for the selected widget type
  let (selectionEvent, fireSelection) ← Reactive.newTriggerEvent (t := Spider) (a := Nat)
  let selectedType ← Reactive.holdDyn 0 selectionEvent
  let (instanceCountEvent, fireInstanceCount) ← Reactive.newTriggerEvent (t := Spider) (a := Nat)
  let selectedInstanceCountIndex ← Reactive.holdDyn defaultWidgetInstanceIndex instanceCountEvent
  let rightPanelName ← registerComponent false false

  let allClicks ← useAllClicks
  let allHovers ← useAllHovers
  let allScrolls ← useAllScrolls
  let rightPanelDimsFromClicks ← Event.mapMaybeM (fun data =>
    componentContentDims? rightPanelName data.componentMap data.layouts
    ) allClicks
  let rightPanelDimsFromHovers ← Event.mapMaybeM (fun data =>
    componentContentDims? rightPanelName data.componentMap data.layouts
    ) allHovers
  let rightPanelDimsFromScrolls ← Event.mapMaybeM (fun data =>
    componentContentDims? rightPanelName data.componentMap data.layouts
    ) allScrolls
  let rightPanelDimsEvent ← Event.mergeAllListM
    [rightPanelDimsFromClicks, rightPanelDimsFromHovers, rightPanelDimsFromScrolls]
  let initialPanelDims := clampPanelDims env.windowWidthF env.windowHeightF
  let rightPanelDims ← Reactive.holdDyn initialPanelDims rightPanelDimsEvent

  let (_, render) ← runWidget do
    let rootStyle : BoxStyle := {
      backgroundColor := some (Color.gray 0.1)
      padding := EdgeInsets.uniform 16
      width := .percent 1.0
      height := .percent 1.0
      flexItem := some (FlexItem.growing 1)
    }

    column' (gap := 16) (style := rootStyle) do
      heading1' "Widget Performance Test"
      caption' "Select a widget type and instance count"

      -- Main content row (fills remaining space)
      let contentRowStyle : BoxStyle := {
        flexItem := some (FlexItem.growing 1)
        width := .percent 1.0
        height := .percent 1.0
      }
      flexRow' { FlexContainer.row 16 with alignItems := .stretch }
          (style := contentRowStyle) do
        -- Left panel: widget selector (fixed width, fills height)
        let leftPanelStyle : BoxStyle := {
          minWidth := some 220
          flexItem := some (FlexItem.fixed 220)
          height := .percent 1.0
        }
        column' (gap := 8) (style := leftPanelStyle) do
          caption' "Widget type:"

          let result ← listBox widgetTypeNames { fillHeight := true }

          -- Wire selection to the external Dynamic
          let selAction ← Event.mapM (fun idx => fireSelection idx) result.onSelect
          performEvent_ selAction

          -- Show current selection
          let _ ← dynWidget selectedType (fun sel =>
            caption' s!"Selected: {widgetTypeNames.getD sel "none"}")
          caption' "Instance count:"
          let instanceResult ← dropdown widgetInstanceOptionLabels defaultWidgetInstanceIndex
          let instanceAction ← Event.mapM (fun idx => fireInstanceCount idx) instanceResult.onSelect
          performEvent_ instanceAction
          let _ ← dynWidget selectedInstanceCountIndex (fun idx =>
            caption' s!"Instances: {widgetInstanceOptions.getD idx defaultWidgetInstanceCount}")
          pure ()

        -- Right panel: Grid of selected widget type (fills remaining space)
        let rightPanelStyle : BoxStyle := {
          flexItem := some (FlexItem.growing 1)
          width := .percent 1.0
          height := .percent 1.0
        }
        namedColumnCustom' rightPanelName (gap := 0) (style := rightPanelStyle) do
          let renderConfig ← Dynamic.zipWithM
            (fun selIdx countIdx => (selIdx, countIdx))
            selectedType selectedInstanceCountIndex
          let renderWithPanelDims ← Dynamic.zipWithM
            (fun (selIdx, countIdx) panelDims => (selIdx, countIdx, panelDims))
            renderConfig rightPanelDims
          let _ ← dynWidget renderWithPanelDims (fun (selIdx, countIdx, panelDims) => do
            let (panelWidth, panelHeight) := panelDims
            let gridAspectHint := panelWidth / panelHeight
            let gridScrollConfig : ScrollContainerConfig := {
              width := panelWidth
              height := panelHeight
              verticalScroll := true
              horizontalScroll := true
              fillWidth := true
              fillHeight := true
              scrollbarVisibility := .always
            }
            let wtype := allWidgetTypes.getD selIdx .label
            let instanceCount := widgetInstanceOptions.getD countIdx defaultWidgetInstanceCount
            let (_, _) ← scrollContainer gridScrollConfig do
              renderWidgetGrid wtype instanceCount
                (fillRows := true) (fillColumns := true)
                (aspectHint := gridAspectHint)
                (viewportWidthHint := panelWidth)
                (viewportHeightHint := panelHeight)
            pure ())
          pure ()

  pure { render }

end Demos.WidgetPerf
