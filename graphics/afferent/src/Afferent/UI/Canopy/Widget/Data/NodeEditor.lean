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

/-- Logical type identifier for node ports. -/
abbrev NodePortTypeId := String

namespace NodePortTypeId

def any : NodePortTypeId := "any"
def model : NodePortTypeId := "model"
def clip : NodePortTypeId := "clip"
def vae : NodePortTypeId := "vae"
def conditioning : NodePortTypeId := "conditioning"
def latent : NodePortTypeId := "latent"
def image : NodePortTypeId := "image"
def mask : NodePortTypeId := "mask"

/-- Default accent color for a port type. -/
def defaultColor (typeId : NodePortTypeId) : Color :=
  match typeId with
  | "model" => Color.fromRgb8 94 223 130
  | "clip" => Color.fromRgb8 142 199 255
  | "vae" => Color.fromRgb8 245 197 94
  | "conditioning" => Color.fromRgb8 94 223 130
  | "latent" => Color.fromRgb8 245 197 94
  | "image" => Color.fromRgb8 100 236 167
  | "mask" => Color.fromRgb8 110 167 255
  | _ => Color.fromRgb8 94 223 130

/-- Output type can connect to input type if either side is wildcard or both types match. -/
def isCompatible (outputType inputType : NodePortTypeId) : Bool :=
  outputType == any || inputType == any || outputType == inputType

end NodePortTypeId

/-- A single port on a node (input or output). -/
structure NodePort where
  label : String
  typeId : NodePortTypeId := NodePortTypeId.any
  color : Option Color := none
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

/-- Result from validating a single connection against a graph model. -/
structure NodeConnectionValidation where
  isValid : Bool
  reason : Option String := none
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
  invalidConnectionColor : Color := (Color.fromRgb8 246 113 113).withAlpha 0.95
  invalidConnectionWidth : Float := 2.8
  wirePreviewColor : Color := (Color.fromRgb8 199 233 212).withAlpha 0.92
  wirePreviewWidth : Float := 2.4
  hoverConnectionWidthBoost : Float := 0.8
  selectedConnectionWidthBoost : Float := 1.6
  portHitRadius : Float := 12
  edgeHitRadius : Float := 10
  socketRadius : Float := 3

deriving Repr, Inhabited

namespace NodeEditorConfig

def default : NodeEditorConfig := {}

end NodeEditorConfig

namespace NodeEditorModel

def validateConnection (model : NodeEditorModel) (conn : NodeConnection) : NodeConnectionValidation :=
  match model.nodes[conn.fromNode]?, model.nodes[conn.toNode]? with
  | none, _ => { isValid := false, reason := some s!"missing source node {conn.fromNode}" }
  | _, none => { isValid := false, reason := some s!"missing destination node {conn.toNode}" }
  | some src, some dst =>
    match src.outputs[conn.fromOutput]?, dst.inputs[conn.toInput]? with
    | none, _ => { isValid := false, reason := some s!"missing source output {conn.fromOutput}" }
    | _, none => { isValid := false, reason := some s!"missing destination input {conn.toInput}" }
    | some outPort, some inPort =>
      if NodePortTypeId.isCompatible outPort.typeId inPort.typeId then
        { isValid := true, reason := none }
      else
        {
          isValid := false
          reason := some s!"incompatible port types ({outPort.typeId} -> {inPort.typeId})"
        }

def validateConnections (model : NodeEditorModel) : Array NodeConnectionValidation :=
  model.connections.map (validateConnection model)

def canConnect (model : NodeEditorModel) (conn : NodeConnection) : Bool :=
  (validateConnection model conn).isValid

def addConnectionIfValid (model : NodeEditorModel) (conn : NodeConnection) : NodeEditorModel :=
  if canConnect model conn then
    { model with connections := model.connections.push conn }
  else
    model

end NodeEditorModel

/-- Optional interactive body content to mount inside a specific node. -/
structure NodeEditorBody where
  nodeIdx : Nat
  /-- Optional minimum height reserved for this body area. -/
  minHeight : Float := 0
  content : WidgetM Unit

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

inductive PortSide where
  | input
  | output
deriving Repr, BEq, Inhabited

structure PortRef where
  nodeIdx : Nat
  portIdx : Nat
  side : PortSide
deriving Repr, BEq, Inhabited

structure NodeDrag where
  nodeIdx : Nat
  pointerStart : Point
  nodeStart : Point
deriving Repr, BEq, Inhabited

structure PanDrag where
  pointerStart : Point
  cameraStart : Point
deriving Repr, BEq, Inhabited

structure WireDrag where
  fromNode : Nat
  fromOutput : Nat
  pointer : Point
  removedConnection : Option NodeConnection := none
deriving Repr, BEq, Inhabited

inductive DragMode where
  | none
  | node (drag : NodeDrag)
  | pan (drag : PanDrag)
  | wire (drag : WireDrag)
deriving Repr, BEq, Inhabited

structure State where
  model : NodeEditorModel
  selectedNode : Option Nat := none
  selectedConnection : Option Nat := none
  hoveredNode : Option Nat := none
  hoveredConnection : Option Nat := none
  hoveredPort : Option PortRef := none
  camera : Point := Point.zero
  dragMode : DragMode := .none
deriving Repr, BEq, Inhabited

inductive InputEvent where
  | click (data : ClickData)
  | hover (data : HoverData)
  | hoverNode (node : Option Nat)
  | key (data : KeyData)
  | mouseUp (data : MouseButtonData)

structure PortRenderFlags where
  isHovered : Bool := false
  isWireSource : Bool := false
  isWireCompatibleTarget : Bool := false
  isWireIncompatibleHover : Bool := false
deriving Repr, BEq, Inhabited

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

private def topHitComponentId? (data : ClickData) : Option ComponentId :=
  match data.hitPath.back? with
  | none => none
  | some topMost =>
      data.componentMap.toList.findSome? fun (componentId, widgetId) =>
        if widgetId == topMost then some componentId else none

private def portColor (port : NodePort) : Color :=
  port.color.getD (NodePortTypeId.defaultColor port.typeId)

private def clampPortRowIdx (node : NodeEditorNode) (idx : Nat) : Nat :=
  min idx (portRows node - 1)

private def connectionDefaultColor (config : NodeEditorConfig) (src : NodeEditorNode)
    (fromOutput : Nat) : Color :=
  match src.outputs[fromOutput]? with
  | some output => portColor output
  | none => config.connectionColor

private def sqr (x : Float) : Float := x * x

private def distanceSq (a b : Point) : Float :=
  sqr (a.x - b.x) + sqr (a.y - b.y)

private def componentContentOrigin? (componentId : ComponentId)
    (componentMap : Std.HashMap ComponentId WidgetId)
    (layouts : Trellis.LayoutResult) : Option Point := do
  let wid ← componentMap.get? componentId
  let layout ← layouts.get wid
  let rect := layout.contentRect
  some (Point.mk' rect.x rect.y)

private def canvasOriginFromClick? (canvasName : ComponentId) (data : ClickData) : Option Point :=
  componentContentOrigin? canvasName data.componentMap data.layouts

private def canvasOriginFromHover? (canvasName : ComponentId) (data : HoverData) : Option Point :=
  componentContentOrigin? canvasName data.componentMap data.layouts

private def canvasOriginFromMouseUp? (canvasName : ComponentId) (data : MouseButtonData) : Option Point :=
  componentContentOrigin? canvasName data.componentMap data.layouts

private def portRefPos? (model : NodeEditorModel) (camera origin : Point) (config : NodeEditorConfig)
    (portRef : PortRef) : Option Point :=
  match model.nodes[portRef.nodeIdx]? with
  | none => none
  | some node =>
    match portRef.side with
    | .input =>
      let row := clampPortRowIdx node portRef.portIdx
      some (inputPortPos node row origin camera config)
    | .output =>
      let row := clampPortRowIdx node portRef.portIdx
      some (outputPortPos node row origin camera config)

private def findNearestPort (model : NodeEditorModel) (camera origin pointer : Point)
    (config : NodeEditorConfig) (maxDistance : Float) (accept : PortRef → Bool) : Option PortRef :=
  Id.run do
    let mut best : Option (PortRef × Float) := none
    for nodeIdx in [:model.nodes.size] do
      let node := model.nodes[nodeIdx]!
      for portIdx in [:node.inputs.size] do
        let portRef : PortRef := { nodeIdx, portIdx, side := .input }
        if accept portRef then
          let pos := inputPortPos node portIdx origin camera config
          let d2 := distanceSq pos pointer
          match best with
          | some (_, bestD2) =>
            if d2 < bestD2 then
              best := some (portRef, d2)
          | none =>
            best := some (portRef, d2)
      for portIdx in [:node.outputs.size] do
        let portRef : PortRef := { nodeIdx, portIdx, side := .output }
        if accept portRef then
          let pos := outputPortPos node portIdx origin camera config
          let d2 := distanceSq pos pointer
          match best with
          | some (_, bestD2) =>
            if d2 < bestD2 then
              best := some (portRef, d2)
          | none =>
            best := some (portRef, d2)
    match best with
    | some (portRef, d2) =>
      if d2 <= sqr maxDistance then some portRef else none
    | none => none

private def bezierControls (p0 p3 : Point) : Point × Point :=
  let dx := max 44.0 (Float.abs (p3.x - p0.x) * 0.5)
  let cp1 := Point.mk' (p0.x + dx) p0.y
  let cp2 := Point.mk' (p3.x - dx) p3.y
  (cp1, cp2)

private def bezierPoint (p0 cp1 cp2 p3 : Point) (t : Float) : Point :=
  let u := 1.0 - t
  let tt := t * t
  let uu := u * u
  let uuu := uu * u
  let ttt := tt * t
  let x := uuu * p0.x + 3.0 * uu * t * cp1.x + 3.0 * u * tt * cp2.x + ttt * p3.x
  let y := uuu * p0.y + 3.0 * uu * t * cp1.y + 3.0 * u * tt * cp2.y + ttt * p3.y
  Point.mk' x y

private def pointToSegmentDistanceSq (p a b : Point) : Float :=
  let abx := b.x - a.x
  let aby := b.y - a.y
  let apx := p.x - a.x
  let apy := p.y - a.y
  let denom := abx * abx + aby * aby
  if denom <= 1e-6 then
    distanceSq p a
  else
    let t := max 0.0 (min 1.0 ((apx * abx + apy * aby) / denom))
    let proj := Point.mk' (a.x + t * abx) (a.y + t * aby)
    distanceSq p proj

private def bezierDistanceSq (pointer p0 p3 : Point) : Float :=
  Id.run do
    let (cp1, cp2) := bezierControls p0 p3
    let samples := 18
    let mut minD2 := 1e30
    let mut prev := p0
    for i in [1:samples+1] do
      let t := i.toFloat / samples.toFloat
      let cur := bezierPoint p0 cp1 cp2 p3 t
      let d2 := pointToSegmentDistanceSq pointer prev cur
      if d2 < minD2 then
        minD2 := d2
      prev := cur
    minD2

private def connectionEndpoints? (model : NodeEditorModel) (camera origin : Point)
    (config : NodeEditorConfig) (conn : NodeConnection) : Option (Point × Point) := do
  let src ← model.nodes[conn.fromNode]?
  let dst ← model.nodes[conn.toNode]?
  let fromPos := outputPortPos src (clampPortRowIdx src conn.fromOutput) origin camera config
  let toPos := inputPortPos dst (clampPortRowIdx dst conn.toInput) origin camera config
  some (fromPos, toPos)

private def findNearestConnectionIdx (model : NodeEditorModel) (camera origin pointer : Point)
    (config : NodeEditorConfig) (maxDistance : Float) : Option Nat :=
  Id.run do
    let mut best : Option (Nat × Float) := none
    for connIdx in [:model.connections.size] do
      let conn := model.connections[connIdx]!
      match connectionEndpoints? model camera origin config conn with
      | none => ()
      | some (p0, p3) =>
        let d2 := bezierDistanceSq pointer p0 p3
        match best with
        | some (_, bestD2) =>
          if d2 < bestD2 then
            best := some (connIdx, d2)
        | none =>
          best := some (connIdx, d2)
    match best with
    | some (connIdx, d2) =>
      if d2 <= sqr maxDistance then some connIdx else none
    | none => none

private def removeConnectionAt (model : NodeEditorModel) (idx : Nat) : NodeEditorModel × Option NodeConnection :=
  if idx < model.connections.size then
    let removed := model.connections[idx]!
    let updated := { model with connections := model.connections.eraseIdxIfInBounds idx }
    (updated, some removed)
  else
    (model, none)

private def restoreRemovedConnection (model : NodeEditorModel) (removed : Option NodeConnection) : NodeEditorModel :=
  match removed with
  | none => model
  | some conn => { model with connections := model.connections.push conn }

private def sameConnectionEndpoints (a b : NodeConnection) : Bool :=
  a.fromNode == b.fromNode &&
    a.fromOutput == b.fromOutput &&
    a.toNode == b.toNode &&
    a.toInput == b.toInput

private def modelHasEquivalentConnection (model : NodeEditorModel) (conn : NodeConnection) : Bool :=
  model.connections.any (fun existing => sameConnectionEndpoints existing conn)

private def findIncomingConnectionIdx (model : NodeEditorModel) (target : PortRef) : Option Nat :=
  model.connections.findIdx? fun conn =>
    conn.toNode == target.nodeIdx && conn.toInput == target.portIdx

private def findOutgoingConnectionIdx (model : NodeEditorModel) (source : PortRef) : Option Nat :=
  model.connections.findIdx? fun conn =>
    conn.fromNode == source.nodeIdx && conn.fromOutput == source.portIdx

private def validInputPortForWire? (model : NodeEditorModel) (drag : WireDrag)
    (candidate : PortRef) : Option PortRef := do
  if candidate.side != .input then
    none
  else
    let sourceConn : NodeConnection := {
      fromNode := drag.fromNode
      fromOutput := drag.fromOutput
      toNode := candidate.nodeIdx
      toInput := candidate.portIdx
      color := none
    }
    if NodeEditorModel.canConnect model sourceConn then some candidate else none

private def portIsWireSource (dragMode : DragMode) (portRef : PortRef) : Bool :=
  match dragMode with
  | .wire drag =>
    portRef.side == PortSide.output &&
      portRef.nodeIdx == drag.fromNode &&
      portRef.portIdx == drag.fromOutput
  | _ => false

private def portIsWireCompatibleTarget (model : NodeEditorModel) (dragMode : DragMode)
    (portRef : PortRef) : Bool :=
  match dragMode with
  | .wire drag =>
    match validInputPortForWire? model drag portRef with
    | some _ => true
    | none => false
  | _ => false

private def renderFlagsForPortRef (state : State) (portRef? : Option PortRef) : PortRenderFlags :=
  match portRef? with
  | none => {}
  | some portRef =>
    let isHovered := state.hoveredPort == some portRef
    let isWireSource := portIsWireSource state.dragMode portRef
    let isWireCompatibleTarget := portIsWireCompatibleTarget state.model state.dragMode portRef
    let isWireIncompatibleHover :=
      isHovered &&
        match state.dragMode with
        | .wire _ =>
          portRef.side == PortSide.input && !isWireCompatibleTarget
        | _ =>
          false
    {
      isHovered
      isWireSource
      isWireCompatibleTarget
      isWireIncompatibleHover
    }

private def connectionPath (p0 p3 : Point) : Afferent.Path :=
  let (cp1, cp2) := bezierControls p0 p3
  Afferent.Path.empty
    |>.moveTo p0
    |>.bezierCurveTo cp1 cp2 p3

/-- Background canvas spec (grid + bezier links). -/
def canvasSpec (state : State) (config : NodeEditorConfig) : CustomSpec := {
  measure := fun availableW availableH =>
    let width := if config.fillWidth && availableW > 0 then availableW else config.width
    let height := if config.fillHeight && availableH > 0 then availableH else config.height
    (width, height)
  collect := fun layout =>
    let rect := layout.contentRect
    let majorEvery := max 1 config.majorGridEvery
    let gridStep := max 8.0 config.gridSize
    let origin := Point.mk' rect.x rect.y
    let model := state.model
    let camera := state.camera
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

        for connIdx in [:model.connections.size] do
          let conn := model.connections[connIdx]!
          match model.nodes[conn.fromNode]?, model.nodes[conn.toNode]? with
          | some src, some dst =>
            let fromRow := clampPortRowIdx src conn.fromOutput
            let toRow := clampPortRowIdx dst conn.toInput
            let fromPos := outputPortPos src fromRow origin camera config
            let toPos := inputPortPos dst toRow origin camera config
            let path := connectionPath fromPos toPos
            let validation := NodeEditorModel.validateConnection model conn
            let defaultColor := connectionDefaultColor config src conn.fromOutput
            let validColor := conn.color.getD defaultColor
            let baseColor :=
              if validation.isValid then validColor else config.invalidConnectionColor
            let isHovered := state.hoveredConnection == some connIdx
            let isSelected := state.selectedConnection == some connIdx
            let lineColor :=
              if isSelected then
                Color.lerp baseColor Color.white 0.28
              else if isHovered then
                Color.lerp baseColor Color.white 0.16
              else
                baseColor
            let baseLineWidth :=
              if validation.isValid then config.connectionWidth else config.invalidConnectionWidth
            let lineWidth :=
              baseLineWidth +
                (if isHovered then config.hoverConnectionWidthBoost else 0) +
                (if isSelected then config.selectedConnectionWidthBoost else 0)
            let socketRadius :=
              config.socketRadius + (if isHovered || isSelected then 1.1 else 0)
            RenderM.strokePath path lineColor lineWidth
            RenderM.fillCircle fromPos socketRadius (lineColor.withAlpha 0.95)
            RenderM.fillCircle toPos socketRadius (lineColor.withAlpha 0.95)
          | _, _ =>
            pure ()

        match state.dragMode with
        | .wire drag =>
          match model.nodes[drag.fromNode]? with
          | none => pure ()
          | some src =>
            let fromPos := outputPortPos src (clampPortRowIdx src drag.fromOutput) origin camera config
            let snappedTarget : Option Point :=
              match state.hoveredPort with
              | some hoveredPort =>
                match validInputPortForWire? model drag hoveredPort with
                | some portRef => portRefPos? model camera origin config portRef
                | none => none
              | none => none
            let toPos := snappedTarget.getD drag.pointer
            let previewPath := connectionPath fromPos toPos
            let sourceColor := connectionDefaultColor config src drag.fromOutput
            let previewColor := Color.lerp sourceColor config.wirePreviewColor 0.2
            let previewWidth :=
              config.wirePreviewWidth + (if snappedTarget.isSome then 0.4 else 0)
            RenderM.strokePath previewPath previewColor previewWidth
            RenderM.fillCircle fromPos (config.socketRadius + 1.2) (previewColor.withAlpha 0.95)
            RenderM.fillCircle toPos (config.socketRadius + 0.9) (previewColor.withAlpha 0.92)
        | _ =>
          pure ()
  -- Connection geometry depends on drag/pan state and must redraw every frame.
  skipCache := true
}

private def portDot (baseColor : Color) (radius : Float) (flags : PortRenderFlags) : WidgetBuilder := do
  let isHot :=
    flags.isHovered || flags.isWireSource || flags.isWireCompatibleTarget || flags.isWireIncompatibleHover
  let diameter := radius * 2
  let dotColor :=
    if flags.isWireIncompatibleHover then
      Color.fromRgb8 246 113 113
    else if flags.isWireCompatibleTarget then
      Color.lerp baseColor Color.white 0.34
    else if flags.isWireSource || flags.isHovered then
      Color.lerp baseColor Color.white 0.22
    else
      baseColor
  let wid ← freshId
  let style : BoxStyle := {
    backgroundColor := some dotColor
    minWidth := some diameter
    maxWidth := some diameter
    minHeight := some diameter
    maxHeight := some diameter
    cornerRadius := diameter / 2
    borderColor := some ((Color.lerp dotColor Color.white 0.45).withAlpha (if isHot then 0.9 else 0.0))
    borderWidth := if isHot then 1 else 0
  }
  pure (.rect wid none style)

private def nodeRowVisual (inputPort : Option NodePort) (outputPort : Option NodePort)
    (inputFlags outputFlags : PortRenderFlags)
    (theme : Theme) (config : NodeEditorConfig) : WidgetBuilder := do
  let dotSize := config.portRadius * 2

  let inDot ←
    match inputPort with
    | some p => portDot (portColor p) config.portRadius inputFlags
    | none => spacer dotSize 1

  let outDot ←
    match outputPort with
    | some p => portDot (portColor p) config.portRadius outputFlags
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
    (nodeIdx : Nat) (state : State) (isSelected isHovered : Bool) (camera : Point)
    (theme : Theme) (config : NodeEditorConfig)
    (bodyWidgets : Array WidgetBuilder) (bodyMinHeight : Float := 0) : WidgetBuilder := do
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
    minHeight := some (nodeHeight node config + bodyMinHeight)
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
    let inputRef : Option PortRef :=
      if i < node.inputs.size then some { nodeIdx, portIdx := i, side := .input } else none
    let outputRef : Option PortRef :=
      if i < node.outputs.size then some { nodeIdx, portIdx := i, side := .output } else none
    let inputFlags := renderFlagsForPortRef state inputRef
    let outputFlags := renderFlagsForPortRef state outputRef
    let row ← nodeRowVisual (node.inputs[i]?) (node.outputs[i]?) inputFlags outputFlags theme config
    rows := rows.push row

  if !bodyWidgets.isEmpty then
    let bodyChildren ← bodyWidgets.mapM fun child => child
    let bodyWid ← freshId
    let bodyProps : FlexContainer := {
      direction := .column
      gap := 6
    }
    let bodyStyle : BoxStyle := {
      padding := EdgeInsets.symmetric config.nodePaddingX 8
      minHeight := some (max 0 bodyMinHeight)
      width := .percent 1.0
    }
    rows := rows.push (.flex bodyWid none bodyProps bodyStyle bodyChildren)

  let wid ← freshId
  let props : FlexContainer := {
    direction := .column
    gap := 0
  }
  pure (Widget.flexC wid name props cardStyle rows)

/-- Build the full node editor visual tree. -/
def nodeEditorVisual (rootName canvasName : ComponentId)
    (nodeNameFn : Nat → ComponentId)
    (state : State) (theme : Theme) (config : NodeEditorConfig)
    (nodeBodyWidgets : Array (Array WidgetBuilder)) (nodeBodyMinHeights : Array Float) : WidgetBuilder := do
  let canvas ← namedCustom canvasName (canvasSpec state config) {
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
    let bodyWidgets := nodeBodyWidgets.getD i #[]
    let bodyMinHeight := nodeBodyMinHeights.getD i 0
    let widget ← nodeVisual (nodeNameFn i) node i state isSelected isHovered state.camera
      theme config bodyWidgets bodyMinHeight
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

private def hoveredPortAtPointer (state : State) (origin? : Option Point)
    (pointer : Point) (config : NodeEditorConfig) : Option PortRef :=
  match origin? with
  | none => none
  | some origin =>
    let accept : PortRef → Bool :=
      match state.dragMode with
      | .wire _ => fun portRef => portRef.side == PortSide.input
      | _ => fun _ => true
    findNearestPort state.model state.camera origin pointer config config.portHitRadius accept

private def hoveredConnectionAtPointer (state : State) (origin? : Option Point)
    (pointer : Point) (config : NodeEditorConfig) : Option Nat :=
  match origin? with
  | none => none
  | some origin =>
    match state.dragMode with
    | .wire _ => none
    | _ =>
      findNearestConnectionIdx state.model state.camera origin pointer config config.edgeHitRadius

private def startWireDragFromOutput (state : State) (pointer : Point)
    (outputRef : PortRef) : State :=
  let selectedConnectionMatch :=
    match state.selectedConnection with
    | some connIdx =>
      match state.model.connections[connIdx]? with
      | some conn =>
        if conn.fromNode == outputRef.nodeIdx && conn.fromOutput == outputRef.portIdx then
          some connIdx
        else
          none
      | none =>
        none
    | none =>
      none
  let (nextModel, removedConnection) :=
    match selectedConnectionMatch with
    | some connIdx =>
      removeConnectionAt state.model connIdx
    | none =>
      (state.model, none)
  {
    state with
      model := nextModel
      selectedNode := some outputRef.nodeIdx
      selectedConnection := none
      hoveredConnection := none
      hoveredPort := some outputRef
      dragMode := .wire {
        fromNode := outputRef.nodeIdx
        fromOutput := outputRef.portIdx
        pointer := pointer
        removedConnection := removedConnection
      }
  }

private def startWireDragFromInput (state : State) (pointer : Point)
    (inputRef : PortRef) : Option State := do
  let connIdx ← findIncomingConnectionIdx state.model inputRef
  let conn ← state.model.connections[connIdx]?
  let (nextModel, removedConnection) := removeConnectionAt state.model connIdx
  some {
    state with
      model := nextModel
      selectedNode := some inputRef.nodeIdx
      selectedConnection := none
      hoveredConnection := none
      hoveredPort := some inputRef
      dragMode := .wire {
        fromNode := conn.fromNode
        fromOutput := conn.fromOutput
        pointer := pointer
        removedConnection := removedConnection
      }
  }

private def finalizeWireDrag (state : State) (pointer : Point) (origin? : Option Point)
    (config : NodeEditorConfig) : State :=
  match state.dragMode with
  | .wire drag =>
    let targetInput? :=
      match origin? with
      | none => none
      | some origin =>
        let nearest := findNearestPort state.model state.camera origin pointer config config.portHitRadius
          (fun portRef => portRef.side == PortSide.input)
        match nearest with
        | none => none
        | some candidate => validInputPortForWire? state.model drag candidate
    let candidateConn : Option NodeConnection :=
      targetInput?.map fun (target : PortRef) => {
        fromNode := drag.fromNode
        fromOutput := drag.fromOutput
        toNode := target.nodeIdx
        toInput := target.portIdx
        color := drag.removedConnection.bind (fun removed => removed.color)
      }
    let (nextModel, nextSelectedConnection) :=
      match candidateConn with
      | some conn =>
        if NodeEditorModel.canConnect state.model conn then
          if modelHasEquivalentConnection state.model conn then
            let selected := state.model.connections.findIdx? (fun existing => sameConnectionEndpoints existing conn)
            (state.model, selected)
          else
            let appended := { state.model with connections := state.model.connections.push conn }
            (appended, some (appended.connections.size - 1))
        else
          (restoreRemovedConnection state.model drag.removedConnection, none)
      | none =>
        (restoreRemovedConnection state.model drag.removedConnection, none)
    {
      state with
        model := nextModel
        selectedConnection := nextSelectedConnection
        hoveredConnection := none
        dragMode := .none
    }
  | _ =>
    { state with dragMode := .none }

end NodeEditor

/-- Create a ComfyUI-style reactive node editor.
    Interactions:
    - Left click + drag from output port: create wire to compatible input port
    - Left click + drag from connected input port: reconnect existing wire endpoint
    - Left click on wire: select wire
    - Right/middle click on wire: delete wire
    - Delete/backspace on selected wire: delete wire
    - Left click + drag on node: move node
    - Left click on canvas: clear selection
    - Right/middle click + drag on canvas: pan camera
-/
def nodeEditor (initialModel : NodeEditorModel)
    (config : NodeEditorConfig := {})
    (bodies : Array NodeEditorBody := #[]) : WidgetM NodeEditorResult := do
  let theme ← getThemeW

  let mut bodyRenders : Array (Array ComponentRender) :=
    Array.replicate initialModel.nodes.size #[]
  let mut bodyMinHeights : Array Float :=
    Array.replicate initialModel.nodes.size 0
  for body in bodies do
    if body.nodeIdx < initialModel.nodes.size then
      let (_, renders) ← runWidgetChildren body.content
      bodyRenders := bodyRenders.set! body.nodeIdx renders
      bodyMinHeights := bodyMinHeights.set! body.nodeIdx (max 0 body.minHeight)

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
  let allKeys ← useKeyboard

  let hoverTargets := nodeNames.mapIdx fun i name => (name, i)
  let hoverNodeChanges ← StateT.lift (hoverEventForTargets hoverTargets)

  let (selectTrigger, fireSelect) ← Reactive.newTriggerEvent (t := Spider) (a := Nat)

  let liftSpider {α : Type} : SpiderM α → WidgetM α := fun m => StateT.lift (liftM m)
  let clickEvents ← liftSpider (Event.mapM NodeEditor.InputEvent.click allClicks)
  let hoverEvents ← liftSpider (Event.mapM NodeEditor.InputEvent.hover allHovers)
  let hoverNodeEvents ← liftSpider (Event.mapM NodeEditor.InputEvent.hoverNode hoverNodeChanges)
  let keyEvents ← liftSpider (Event.mapM NodeEditor.InputEvent.key allKeys)
  let mouseUpEvents ← liftSpider (Event.mapM NodeEditor.InputEvent.mouseUp allMouseUp)
  let allInputEvents ←
    liftSpider (Event.leftmostM [clickEvents, hoverEvents, hoverNodeEvents, keyEvents, mouseUpEvents])

  let initialState : NodeEditor.State := {
    model := initialModel
    selectedNode := none
    selectedConnection := none
    hoveredNode := none
    hoveredConnection := none
    hoveredPort := none
    camera := config.initialCamera
    dragMode := .none
  }

  let stateDyn ← Reactive.foldDynM
    (fun event state => do
      match event with
      | .hoverNode hovered =>
        pure { state with hoveredNode := hovered }

      | .mouseUp data =>
        let pointer := Point.mk' data.x data.y
        let origin? := NodeEditor.canvasOriginFromMouseUp? canvasName data
        let released := NodeEditor.finalizeWireDrag state pointer origin? config
        let hoveredPort := NodeEditor.hoveredPortAtPointer released origin? pointer config
        let hoveredConnection := NodeEditor.hoveredConnectionAtPointer released origin? pointer config
        pure { released with hoveredPort, hoveredConnection }

      | .key data =>
        if data.focusedWidget.isSome then
          pure state
        else
          match data.event.key, state.selectedConnection with
          | .delete, some connIdx
          | .backspace, some connIdx =>
            let (updatedModel, _) := NodeEditor.removeConnectionAt state.model connIdx
            pure { state with model := updatedModel, selectedConnection := none, hoveredConnection := none }
          | _, _ =>
            pure state

      | .hover data =>
        let pointer : Point := Point.mk' data.x data.y
        let origin? := NodeEditor.canvasOriginFromHover? canvasName data
        let progressed :=
          match state.dragMode with
          | .none =>
            state
          | .node drag =>
            let dx := pointer.x - drag.pointerStart.x
            let dy := pointer.y - drag.pointerStart.y
            let newPos := Point.mk' (drag.nodeStart.x + dx) (drag.nodeStart.y + dy)
            let updated := NodeEditor.updateNodePosition state.model drag.nodeIdx newPos
            { state with model := updated }
          | .pan drag =>
            let dx := pointer.x - drag.pointerStart.x
            let dy := pointer.y - drag.pointerStart.y
            let nextCamera := Point.mk' (drag.cameraStart.x + dx) (drag.cameraStart.y + dy)
            { state with camera := nextCamera }
          | .wire drag =>
            { state with dragMode := .wire { drag with pointer := pointer } }
        let hoveredPort := NodeEditor.hoveredPortAtPointer progressed origin? pointer config
        let hoveredConnection := NodeEditor.hoveredConnectionAtPointer progressed origin? pointer config
        pure { progressed with hoveredPort, hoveredConnection }

      | .click data =>
        let pointer := Point.mk' data.click.x data.click.y
        let origin? := NodeEditor.canvasOriginFromClick? canvasName data
        let clickedPort? :=
          match origin? with
          | none => none
          | some origin =>
            NodeEditor.findNearestPort state.model state.camera origin pointer config config.portHitRadius
              (fun _ => true)
        let clickedConnection? :=
          match origin? with
          | none => none
          | some origin =>
            NodeEditor.findNearestConnectionIdx state.model state.camera origin pointer config config.edgeHitRadius

        match data.click.button with
        | 0 =>
          match clickedPort? with
          | some portRef =>
            match portRef.side with
            | .output =>
              SpiderM.liftIO (fireSelect portRef.nodeIdx)
              pure (NodeEditor.startWireDragFromOutput state pointer portRef)
            | .input =>
              match NodeEditor.startWireDragFromInput state pointer portRef with
              | some reconnectState =>
                SpiderM.liftIO (fireSelect portRef.nodeIdx)
                pure reconnectState
              | none =>
                let clickedNode := NodeEditor.findClickedNode nodeNameFn nodeNames.size data
                match clickedNode with
                | some idx =>
                  let rootComponent := nodeNameFn idx
                  let topComponent := NodeEditor.topHitComponentId? data
                  let shouldStartNodeDrag :=
                    match topComponent with
                    | none => true
                    | some componentId => componentId == rootComponent
                  SpiderM.liftIO (fireSelect idx)
                  let dragMode :=
                    if shouldStartNodeDrag then
                      let node := state.model.nodes.getD idx default
                      .node {
                        nodeIdx := idx
                        pointerStart := Point.mk' data.click.x data.click.y
                        nodeStart := node.position
                      }
                    else
                      .none
                  pure { state with selectedNode := some idx, selectedConnection := none, dragMode }
                | none =>
                  match clickedConnection? with
                  | some connIdx =>
                    pure { state with selectedNode := none, selectedConnection := some connIdx, dragMode := .none }
                  | none =>
                    if hitWidget data canvasName then
                      pure { state with selectedNode := none, selectedConnection := none, dragMode := .none }
                    else
                      pure state
          | none =>
            match clickedConnection? with
            | some connIdx =>
              pure { state with selectedNode := none, selectedConnection := some connIdx, dragMode := .none }
            | none =>
              let clickedNode := NodeEditor.findClickedNode nodeNameFn nodeNames.size data
              match clickedNode with
              | some idx =>
                let rootComponent := nodeNameFn idx
                let topComponent := NodeEditor.topHitComponentId? data
                let shouldStartNodeDrag :=
                  match topComponent with
                  | none => true
                  | some componentId => componentId == rootComponent
                SpiderM.liftIO (fireSelect idx)
                let dragMode :=
                  if shouldStartNodeDrag then
                    let node := state.model.nodes.getD idx default
                    .node {
                      nodeIdx := idx
                      pointerStart := Point.mk' data.click.x data.click.y
                      nodeStart := node.position
                    }
                  else
                    .none
                pure { state with selectedNode := some idx, selectedConnection := none, dragMode }
              | none =>
                if hitWidget data canvasName then
                  pure { state with selectedNode := none, selectedConnection := none, dragMode := .none }
                else
                  pure state
        | 1 | 2 =>
          match clickedConnection? with
          | some connIdx =>
            let (updatedModel, _) := NodeEditor.removeConnectionAt state.model connIdx
            pure { state with model := updatedModel, selectedConnection := none, hoveredConnection := none }
          | none =>
            if hitWidget data canvasName then
              let dragMode : NodeEditor.DragMode :=
                .pan { pointerStart := pointer, cameraStart := state.camera }
              pure { state with dragMode, selectedConnection := none }
            else
              pure state
        | _ =>
          pure state
    )
    initialState
    allInputEvents

  let selectedDyn ← Dynamic.mapM (fun s => s.selectedNode) stateDyn
  let modelDyn ← Dynamic.mapM (fun s => s.model) stateDyn
  let cameraDyn ← Dynamic.mapM (fun s => s.camera) stateDyn

  let _ ← dynWidget stateDyn fun state => do
    emitDynamic do
      let mut bodyWidgetsByNode : Array (Array WidgetBuilder) :=
        Array.replicate bodyRenders.size #[]
      for i in [:bodyRenders.size] do
        let renders := bodyRenders.getD i #[]
        let widgets ← ComponentRender.materializeAll renders
        bodyWidgetsByNode := bodyWidgetsByNode.set! i widgets
      pure (NodeEditor.nodeEditorVisual rootName canvasName nodeNameFn state theme config
        bodyWidgetsByNode bodyMinHeights)

  pure {
    onNodeSelect := selectTrigger
    selectedNode := selectedDyn
    model := modelDyn
    cameraOffset := cameraDyn
  }

end Afferent.Canopy
