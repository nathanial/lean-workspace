/-
  Canopy NodeEditor Widget
  ComfyUI-style node graph editor with draggable nodes and panning.
-/
import Reactive
import Afferent.UI.Canopy.Core
import Afferent.UI.Canopy.Theme
import Afferent.UI.Canopy.Reactive.Component

namespace Afferent.Canopy

open Afferent.Arbor hiding Event
open Reactive Reactive.Host
open Afferent.Canopy.Reactive
open Trellis

/-- A single port on a node (input or output). -/
structure NodePort where
  label : String
  color : Color := Color.fromRgb8 86 212 120
deriving Repr, BEq, Inhabited

/-- A node card rendered in the editor canvas. -/
structure NodeEditorNode where
  title : String
  subtitle : String := ""
  position : Point := Point.zero
  width : Float := 260
  accent : Color := Color.fromRgb8 104 114 255
  inputs : Array NodePort := #[]
  outputs : Array NodePort := #[]
deriving Repr, BEq, Inhabited

/-- A connection from one node output port to another node input port. -/
structure NodeConnection where
  fromNode : Nat
  fromOutput : Nat
  toNode : Nat
  toInput : Nat
  color : Option Color := none
deriving Repr, BEq, Inhabited

/-- Complete graph model for the node editor. -/
structure NodeEditorModel where
  nodes : Array NodeEditorNode := #[]
  connections : Array NodeConnection := #[]
deriving Repr, BEq, Inhabited

/-- Visual and interaction configuration for NodeEditor. -/
structure NodeEditorConfig where
  width : Float := 980
  height : Float := 640
  fillWidth : Bool := true
  fillHeight : Bool := true
  initialCamera : Point := Point.zero

  cornerRadius : Float := 10
  backgroundColor : Color := Color.fromRgb8 24 26 32
  borderColor : Color := Color.fromRgb8 46 49 62

  gridSize : Float := 26
  showGrid : Bool := true
  showMajorGrid : Bool := true
  majorGridEvery : Nat := 4
  gridColor : Color := (Color.fromRgb8 76 80 92).withAlpha 0.18
  majorGridColor : Color := (Color.fromRgb8 95 100 118).withAlpha 0.28

  headerHeight : Float := 34
  rowHeight : Float := 26
  bodyPaddingY : Float := 8
  nodePaddingX : Float := 10
  nodeCornerRadius : Float := 10
  portRadius : Float := 4

  connectionColor : Color := (Color.fromRgb8 189 213 198).withAlpha 0.8
  connectionWidth : Float := 2.2
  socketRadius : Float := 3

deriving Repr, Inhabited

namespace NodeEditorConfig

def default : NodeEditorConfig := {}

end NodeEditorConfig

/-- Result from `nodeEditor`. -/
structure NodeEditorResult where
  /-- Fires when a node is selected via left click. -/
  onNodeSelect : Reactive.Event Spider Nat
  /-- Current selected node index. -/
  selectedNode : Reactive.Dynamic Spider (Option Nat)
  /-- Current graph model (node positions update while dragging). -/
  model : Reactive.Dynamic Spider NodeEditorModel
  /-- Current camera offset used for panning. -/
  cameraOffset : Reactive.Dynamic Spider Point

namespace NodeEditor

structure NodeDrag where
  nodeIdx : Nat
  pointerStart : Point
  nodeStart : Point
deriving Repr, BEq, Inhabited

structure PanDrag where
  pointerStart : Point
  cameraStart : Point
deriving Repr, BEq, Inhabited

inductive DragMode where
  | none
  | node (drag : NodeDrag)
  | pan (drag : PanDrag)
deriving Repr, BEq, Inhabited

structure State where
  model : NodeEditorModel
  selectedNode : Option Nat := none
  hoveredNode : Option Nat := none
  camera : Point := Point.zero
  dragMode : DragMode := .none
deriving Repr, BEq, Inhabited

inductive InputEvent where
  | click (data : ClickData)
  | hover (data : HoverData)
  | hoverNode (node : Option Nat)
  | mouseUp

private def floatMod (x m : Float) : Float :=
  if m <= 0 then 0
  else
    let q := Float.floor (x / m)
    x - q * m

private def portRows (node : NodeEditorNode) : Nat :=
  max 1 (max node.inputs.size node.outputs.size)

private def nodeHeight (node : NodeEditorNode) (config : NodeEditorConfig) : Float :=
  config.headerHeight + config.bodyPaddingY * 2 + (portRows node).toFloat * config.rowHeight

private def inputPortPos (node : NodeEditorNode) (portIdx : Nat)
    (origin : Point) (camera : Point) (config : NodeEditorConfig) : Point :=
  let x := origin.x + node.position.x + camera.x + config.nodePaddingX
  let y := origin.y + node.position.y + camera.y + config.headerHeight + config.bodyPaddingY +
    (portIdx.toFloat + 0.5) * config.rowHeight
  Point.mk' x y

private def outputPortPos (node : NodeEditorNode) (portIdx : Nat)
    (origin : Point) (camera : Point) (config : NodeEditorConfig) : Point :=
  let x := origin.x + node.position.x + camera.x + node.width - config.nodePaddingX
  let y := origin.y + node.position.y + camera.y + config.headerHeight + config.bodyPaddingY +
    (portIdx.toFloat + 0.5) * config.rowHeight
  Point.mk' x y

private def connectionPath (p0 p3 : Point) : Afferent.Path :=
  let dx := max 44.0 (Float.abs (p3.x - p0.x) * 0.5)
  let cp1 := Point.mk' (p0.x + dx) p0.y
  let cp2 := Point.mk' (p3.x - dx) p3.y
  Afferent.Path.empty
    |>.moveTo p0
    |>.bezierCurveTo cp1 cp2 p3

private def updateNodePosition (model : NodeEditorModel) (idx : Nat) (newPos : Point) : NodeEditorModel :=
  if idx < model.nodes.size then
    let node := model.nodes[idx]!
    let updated := { node with position := newPos }
    { model with nodes := model.nodes.set! idx updated }
  else
    model

private def findClickedNode (nodeNameFn : Nat → ComponentId) (nodeCount : Nat)
    (data : ClickData) : Option Nat :=
  (List.range nodeCount).findSome? fun i =>
    if hitWidget data (nodeNameFn i) then some i else none

/-- Background canvas spec (grid + bezier links). -/
def canvasSpec (model : NodeEditorModel) (camera : Point)
    (config : NodeEditorConfig) : CustomSpec := {
  measure := fun availableW availableH =>
    let width := if config.fillWidth && availableW > 0 then availableW else config.width
    let height := if config.fillHeight && availableH > 0 then availableH else config.height
    (width, height)
  collect := fun layout =>
    let rect := layout.contentRect
    let majorEvery := max 1 config.majorGridEvery
    let gridStep := max 8.0 config.gridSize
    let origin := Point.mk' rect.x rect.y
    RenderM.build do
      RenderM.withClip (Rect.mk' rect.x rect.y rect.width rect.height) do
        RenderM.fillRect (Rect.mk' rect.x rect.y rect.width rect.height) config.backgroundColor 0

        if config.showGrid then
          let offsetX := floatMod camera.x gridStep
          let offsetY := floatMod camera.y gridStep

          let verticalCount := (Float.ceil (rect.width / gridStep)).toUInt32.toNat + 3
          let horizontalCount := (Float.ceil (rect.height / gridStep)).toUInt32.toNat + 3

          let startX := rect.x - gridStep + offsetX
          let startY := rect.y - gridStep + offsetY

          for i in [:verticalCount] do
            let x := startX + i.toFloat * gridStep
            let isMajor := config.showMajorGrid && (i % majorEvery == 0)
            let lineColor := if isMajor then config.majorGridColor else config.gridColor
            let lineWidth := if isMajor then 1.2 else 1.0
            RenderM.fillRect (Rect.mk' x rect.y lineWidth rect.height) lineColor 0

          for i in [:horizontalCount] do
            let y := startY + i.toFloat * gridStep
            let isMajor := config.showMajorGrid && (i % majorEvery == 0)
            let lineColor := if isMajor then config.majorGridColor else config.gridColor
            let lineWidth := if isMajor then 1.2 else 1.0
            RenderM.fillRect (Rect.mk' rect.x y rect.width lineWidth) lineColor 0

        for conn in model.connections do
          match model.nodes[conn.fromNode]?, model.nodes[conn.toNode]? with
          | some src, some dst =>
            let fromPos := outputPortPos src conn.fromOutput origin camera config
            let toPos := inputPortPos dst conn.toInput origin camera config
            let path := connectionPath fromPos toPos
            let lineColor := conn.color.getD config.connectionColor
            RenderM.strokePath path lineColor config.connectionWidth
            RenderM.fillCircle fromPos config.socketRadius (lineColor.withAlpha 0.95)
            RenderM.fillCircle toPos config.socketRadius (lineColor.withAlpha 0.95)
          | _, _ =>
            pure ()
  -- Connection geometry depends on drag/pan state and must redraw every frame.
  skipCache := true
}

private def portDot (color : Color) (radius : Float) : WidgetBuilder := do
  let diameter := radius * 2
  let wid ← freshId
  let style : BoxStyle := {
    backgroundColor := some color
    minWidth := some diameter
    maxWidth := some diameter
    minHeight := some diameter
    maxHeight := some diameter
    cornerRadius := radius
  }
  pure (.rect wid none style)

private def nodeRowVisual (inputPort : Option NodePort) (outputPort : Option NodePort)
    (theme : Theme) (config : NodeEditorConfig) : WidgetBuilder := do
  let dotSize := config.portRadius * 2

  let inDot ←
    match inputPort with
    | some p => portDot p.color config.portRadius
    | none => spacer dotSize 1

  let outDot ←
    match outputPort with
    | some p => portDot p.color config.portRadius
    | none => spacer dotSize 1

  let inLabel ←
    match inputPort with
    | some p => text' p.label theme.smallFont theme.textMuted .left
    | none => spacer 2 1

  let outLabel ←
    match outputPort with
    | some p => text' p.label theme.smallFont theme.textMuted .right
    | none => spacer 2 1

  let leftGroup ← row (gap := 6) (style := {}) #[pure inDot, pure inLabel]
  let rightGroup ← row (gap := 6) (style := {}) #[pure outLabel, pure outDot]

  rowSpaceBetween 0 {
      minHeight := some config.rowHeight
      padding := EdgeInsets.symmetric config.nodePaddingX 2
    } #[pure leftGroup, pure rightGroup]

private def nodeVisual (name : ComponentId) (node : NodeEditorNode)
    (isSelected isHovered : Bool) (camera : Point)
    (theme : Theme) (config : NodeEditorConfig) : WidgetBuilder := do
  let bgColor := Color.fromRgb8 42 45 52
  let borderColor :=
    if isSelected then theme.primary.borderFocused
    else if isHovered then theme.input.borderFocused.withAlpha 0.8
    else Color.fromRgb8 70 75 87

  let cardStyle : BoxStyle := {
    backgroundColor := some bgColor
    borderColor := some borderColor
    borderWidth := if isSelected then 2 else 1
    cornerRadius := config.nodeCornerRadius
    minWidth := some node.width
    maxWidth := some node.width
    minHeight := some (nodeHeight node config)
    maxHeight := some (nodeHeight node config)
    position := .absolute
    left := some (node.position.x + camera.x)
    top := some (node.position.y + camera.y)
  }

  let headerBg := node.accent.withAlpha (if isSelected then 0.42 else 0.3)
  let headerText := if node.subtitle.isEmpty then "NODE" else node.subtitle.toUpper

  let titleText ← text' node.title theme.font theme.text .left
  let subtitleText ← text' headerText theme.smallFont (node.accent.withAlpha 0.92) .right
  let headerRow ← rowSpaceBetween 0 {
      backgroundColor := some headerBg
      borderColor := some (node.accent.withAlpha 0.6)
      borderWidth := 0
      cornerRadius := config.nodeCornerRadius
      minHeight := some config.headerHeight
      padding := EdgeInsets.symmetric config.nodePaddingX 6
    } #[pure titleText, pure subtitleText]

  let rowCount := portRows node
  let mut rows : Array Widget := #[headerRow]
  for i in [:rowCount] do
    let row ← nodeRowVisual (node.inputs[i]?) (node.outputs[i]?) theme config
    rows := rows.push row

  let wid ← freshId
  let props : FlexContainer := {
    direction := .column
    gap := 0
  }
  pure (Widget.flexC wid name props cardStyle rows)

/-- Build the full node editor visual tree. -/
def nodeEditorVisual (rootName canvasName : ComponentId)
    (nodeNameFn : Nat → ComponentId)
    (state : State) (theme : Theme) (config : NodeEditorConfig) : WidgetBuilder := do
  let canvas ← namedCustom canvasName (canvasSpec state.model state.camera config) {
    width := if config.fillWidth then .percent 1.0 else .auto
    height := if config.fillHeight then .percent 1.0 else .auto
    minWidth := some config.width
    minHeight := some config.height
    maxWidth := if config.fillWidth then none else some config.width
    maxHeight := if config.fillHeight then none else some config.height
    cornerRadius := config.cornerRadius
    flexItem := if config.fillWidth || config.fillHeight then some (FlexItem.growing 1) else none
  }

  let mut nodeWidgets : Array Widget := #[]
  for i in [:state.model.nodes.size] do
    let node := state.model.nodes[i]!
    let isSelected := state.selectedNode == some i
    let isHovered := state.hoveredNode == some i
    let widget ← nodeVisual (nodeNameFn i) node isSelected isHovered state.camera theme config
    nodeWidgets := nodeWidgets.push widget

  let containerStyle : BoxStyle := {
    backgroundColor := some config.backgroundColor
    borderColor := some config.borderColor
    borderWidth := 1
    cornerRadius := config.cornerRadius
    width := if config.fillWidth then .percent 1.0 else .auto
    height := if config.fillHeight then .percent 1.0 else .auto
    minWidth := some config.width
    minHeight := some config.height
    maxWidth := if config.fillWidth then none else some config.width
    maxHeight := if config.fillHeight then none else some config.height
    flexItem := if config.fillWidth || config.fillHeight then some (FlexItem.growing 1) else none
  }

  let wid ← freshId
  let props : FlexContainer := {
    direction := .column
    gap := 0
  }
  pure (Widget.flexC wid rootName props containerStyle (#[canvas] ++ nodeWidgets))

end NodeEditor

/-- Create a ComfyUI-style reactive node editor.
    Interactions:
    - Left click + drag on node: move node
    - Left click on canvas: clear selection
    - Right/middle click + drag on canvas: pan camera
-/
def nodeEditor (initialModel : NodeEditorModel)
    (config : NodeEditorConfig := {}) : WidgetM NodeEditorResult := do
  let theme ← getThemeW

  let rootName ← registerComponentW (isInteractive := false)
  let canvasName ← registerComponentW

  let mut nodeNames : Array ComponentId := #[]
  for _ in [:initialModel.nodes.size] do
    let name ← registerComponentW
    nodeNames := nodeNames.push name
  let nodeNameFn (i : Nat) : ComponentId := nodeNames.getD i 0

  let allClicks ← useAllClicks
  let allHovers ← useAllHovers
  let allMouseUp ← useAllMouseUp

  let hoverTargets := nodeNames.mapIdx fun i name => (name, i)
  let hoverNodeChanges ← StateT.lift (hoverEventForTargets hoverTargets)

  let (selectTrigger, fireSelect) ← Reactive.newTriggerEvent (t := Spider) (a := Nat)

  let liftSpider {α : Type} : SpiderM α → WidgetM α := fun m => StateT.lift (liftM m)
  let clickEvents ← liftSpider (Event.mapM NodeEditor.InputEvent.click allClicks)
  let hoverEvents ← liftSpider (Event.mapM NodeEditor.InputEvent.hover allHovers)
  let hoverNodeEvents ← liftSpider (Event.mapM NodeEditor.InputEvent.hoverNode hoverNodeChanges)
  let mouseUpEvents ← liftSpider (Event.mapM (fun _ => NodeEditor.InputEvent.mouseUp) allMouseUp)
  let allInputEvents ← liftSpider (Event.leftmostM [clickEvents, hoverEvents, hoverNodeEvents, mouseUpEvents])

  let initialState : NodeEditor.State := {
    model := initialModel
    selectedNode := none
    hoveredNode := none
    camera := config.initialCamera
    dragMode := .none
  }

  let stateDyn ← Reactive.foldDynM
    (fun event state => do
      match event with
      | .hoverNode hovered =>
        pure { state with hoveredNode := hovered }

      | .mouseUp =>
        pure { state with dragMode := .none }

      | .hover data =>
        let pointer : Point := Point.mk' data.x data.y
        match state.dragMode with
        | .none =>
          pure state
        | .node drag =>
          let dx := pointer.x - drag.pointerStart.x
          let dy := pointer.y - drag.pointerStart.y
          let newPos := Point.mk' (drag.nodeStart.x + dx) (drag.nodeStart.y + dy)
          let updated := NodeEditor.updateNodePosition state.model drag.nodeIdx newPos
          pure { state with model := updated }
        | .pan drag =>
          let dx := pointer.x - drag.pointerStart.x
          let dy := pointer.y - drag.pointerStart.y
          let nextCamera := Point.mk' (drag.cameraStart.x + dx) (drag.cameraStart.y + dy)
          pure { state with camera := nextCamera }

      | .click data =>
        let clickedNode := NodeEditor.findClickedNode nodeNameFn nodeNames.size data
        match clickedNode with
        | some idx =>
          if data.click.button == 0 then
            SpiderM.liftIO (fireSelect idx)
          let dragMode :=
            if data.click.button == 0 then
              let node := state.model.nodes.getD idx default
              .node {
                nodeIdx := idx
                pointerStart := Point.mk' data.click.x data.click.y
                nodeStart := node.position
              }
            else
              state.dragMode
          pure { state with selectedNode := some idx, dragMode }
        | none =>
          if hitWidget data canvasName then
            if data.click.button == 1 || data.click.button == 2 then
              let pointer := Point.mk' data.click.x data.click.y
              let dragMode : NodeEditor.DragMode :=
                .pan { pointerStart := pointer, cameraStart := state.camera }
              pure { state with dragMode }
            else if data.click.button == 0 then
              pure { state with selectedNode := none, dragMode := .none }
            else
              pure state
          else
            pure state
    )
    initialState
    allInputEvents

  let selectedDyn ← Dynamic.mapM (fun s => s.selectedNode) stateDyn
  let modelDyn ← Dynamic.mapM (fun s => s.model) stateDyn
  let cameraDyn ← Dynamic.mapM (fun s => s.camera) stateDyn

  let _ ← dynWidget stateDyn fun state => do
    emit do
      pure (NodeEditor.nodeEditorVisual rootName canvasName nodeNameFn state theme config)

  pure {
    onNodeSelect := selectTrigger
    selectedNode := selectedDyn
    model := modelDyn
    cameraOffset := cameraDyn
  }

end Afferent.Canopy
