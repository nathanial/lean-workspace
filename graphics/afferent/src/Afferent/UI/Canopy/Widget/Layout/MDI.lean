/-
  Canopy MDI Widget
  Multi-document interface container with draggable, resizable, snappable windows.
-/
import Reactive
import Std.Data.HashMap
import Afferent.UI.Canopy.Core
import Afferent.UI.Canopy.Theme
import Afferent.UI.Canopy.Reactive.Component

namespace Afferent.Canopy

open Afferent.Arbor hiding Event
open Reactive Reactive.Host
open Afferent.Canopy.Reactive
open Trellis

/-- Logical rectangle for MDI window geometry. -/
structure MDIRect where
  x : Float
  y : Float
  width : Float
  height : Float
deriving Repr, BEq, Inhabited

namespace MDIRect

/-- Right edge of the rectangle. -/
def right (r : MDIRect) : Float :=
  r.x + r.width

/-- Bottom edge of the rectangle. -/
def bottom (r : MDIRect) : Float :=
  r.y + r.height

/-- Convert a Trellis layout rect into MDI rect representation. -/
def ofLayoutRect (r : Trellis.LayoutRect) : MDIRect :=
  { x := r.x, y := r.y, width := r.width, height := r.height }

/-- Convert MDI rect to Trellis layout rect representation. -/
def toLayoutRect (r : MDIRect) : Trellis.LayoutRect :=
  { x := r.x, y := r.y, width := r.width, height := r.height }

/-- Check whether a point lies inside the rectangle. -/
def contains (r : MDIRect) (px py : Float) : Bool :=
  px >= r.x && px <= r.right && py >= r.y && py <= r.bottom

/-- Approximate rectangle equality for float-geometry decisions. -/
def approxEq (a b : MDIRect) (eps : Float := 0.5) : Bool :=
  Float.abs (a.x - b.x) <= eps &&
  Float.abs (a.y - b.y) <= eps &&
  Float.abs (a.width - b.width) <= eps &&
  Float.abs (a.height - b.height) <= eps

end MDIRect

/-- Resize handles for a window frame. -/
inductive MDIResizeHandle where
  | north
  | south
  | east
  | west
  | northEast
  | northWest
  | southEast
  | southWest
deriving Repr, BEq, Inhabited

/-- Snap destinations for window placement. -/
inductive MDISnapTarget where
  | left
  | right
  | top
  | bottom
  | topLeft
  | topRight
  | bottomLeft
  | bottomRight
  | maximize
deriving Repr, BEq, Inhabited

/-- Configurable static window definition for the MDI host. -/
structure MDIWindowSpec where
  id : Nat
  title : String
  rect : MDIRect
  minWidth : Float := 180.0
  minHeight : Float := 120.0
  movable : Bool := true
  resizable : Bool := true
  content : WidgetM Unit

/-- Runtime geometry and interaction state for a single MDI window. -/
structure MDIWindowState where
  id : Nat
  title : String
  rect : MDIRect
  minWidth : Float := 180.0
  minHeight : Float := 120.0
  movable : Bool := true
  resizable : Bool := true
deriving Repr, BEq, Inhabited

/-- MDI host configuration. -/
structure MDIConfig where
  width : Option Float := none
  height : Option Float := none
  fillWidth : Bool := true
  fillHeight : Bool := true
  titlebarHeight : Float := 28.0
  edgeHandleSize : Float := 6.0
  cornerHandleSize : Float := 12.0
  snapThreshold : Float := 26.0
  minWindowWidth : Float := 180.0
  minWindowHeight : Float := 120.0
  showSnapPreview : Bool := true
  clampToHost : Bool := true
  hostBackground : Option Color := none
deriving Repr, Inhabited

namespace MDIConfig

/-- Default MDI host configuration. -/
def default : MDIConfig := {}

end MDIConfig

/-- Result values exposed by the MDI widget. -/
structure MDIResult where
  activeWindow : Reactive.Dynamic Spider (Option Nat)
  windows : Reactive.Dynamic Spider (Array MDIWindowState)
  onWindowMove : Reactive.Event Spider (Nat × MDIRect)
  onWindowResize : Reactive.Event Spider (Nat × MDIRect)
  onWindowSnap : Reactive.Event Spider (Nat × MDISnapTarget)

namespace MDI

/-- Find the array index for a window id. -/
def windowIndexById (windows : Array MDIWindowState) (windowId : Nat) : Option Nat :=
  windows.findIdx? (fun w => w.id == windowId)

/-- Fetch a window by id. -/
def windowById? (windows : Array MDIWindowState) (windowId : Nat) : Option MDIWindowState := do
  let idx ← windowIndexById windows windowId
  windows[idx]?

/-- Update a specific window by id. -/
def updateWindowById (windows : Array MDIWindowState) (windowId : Nat)
    (f : MDIWindowState → MDIWindowState) : Array MDIWindowState :=
  match windowIndexById windows windowId with
  | some idx =>
      match windows[idx]? with
      | some w => windows.set! idx (f w)
      | none => windows
  | none => windows

/-- Bring a window to front by moving it to the end of z-order. -/
def bringToFront (zOrder : Array Nat) (windowId : Nat) : Array Nat :=
  if zOrder.any (· == windowId) then
    (zOrder.filter (· != windowId)).push windowId
  else
    zOrder

/-- Materialize windows in z-order. -/
def orderedWindows (windows : Array MDIWindowState) (zOrder : Array Nat) : Array MDIWindowState :=
  zOrder.foldl (init := #[]) fun acc windowId =>
    match windowById? windows windowId with
    | some w => acc.push w
    | none => acc

/-- Return the topmost window id that satisfies a hit predicate. -/
def topmostWindowBy (zOrder : Array Nat) (pred : Nat → Bool) : Option Nat :=
  zOrder.reverse.findSome? fun windowId =>
    if pred windowId then some windowId else none

/-- Return the topmost window id at a point using window rect overlap and z-order. -/
def topmostWindowAtPoint (windows : Array MDIWindowState) (zOrder : Array Nat)
    (x y : Float) : Option Nat :=
  topmostWindowBy zOrder fun windowId =>
    match windowById? windows windowId with
    | some window => window.rect.contains x y
    | none => false

/-- Lookup a widget content rect from component and layout maps. -/
def widgetRectFromLayouts (componentId : ComponentId)
    (componentMap : Std.HashMap ComponentId WidgetId)
    (layouts : Trellis.LayoutResult) : Option MDIRect := do
  let wid ← componentMap.get? componentId
  let layout ← layouts.get wid
  pure (MDIRect.ofLayoutRect layout.contentRect)

/-- Convert an absolute host rect to host-local coordinates (origin at 0,0). -/
def hostRectLocal (host : MDIRect) : MDIRect :=
  { x := 0, y := 0, width := host.width, height := host.height }

/-- Convert absolute pointer coordinates into host-local coordinates. -/
def pointInHostLocal (host : MDIRect) (x y : Float) : Float × Float :=
  (x - host.x, y - host.y)

/-- Clamp a rectangle so it remains entirely inside host bounds. -/
def clampRectToHost (rect host : MDIRect) : MDIRect :=
  let width := min rect.width host.width
  let height := min rect.height host.height
  let maxX := host.x + host.width - width
  let maxY := host.y + host.height - height
  let x := max host.x (min maxX rect.x)
  let y := max host.y (min maxY rect.y)
  { x, y, width, height }

/-- Apply pointer delta to move a rectangle. -/
def movedRect (startRect : MDIRect) (startX startY x y : Float) : MDIRect :=
  {
    startRect with
    x := startRect.x + (x - startX)
    y := startRect.y + (y - startY)
  }

/-- Compute moved rectangle for drag update, optionally clamped to host. -/
def moveRectForDrag (startRect : MDIRect) (startX startY x y : Float)
    (hostRect? : Option MDIRect) (clampToHost : Bool) : MDIRect :=
  let moved := movedRect startRect startX startY x y
  if clampToHost then
    match hostRect? with
    | some host => clampRectToHost moved host
    | none => moved
  else
    moved

/-- Detect active resize handle at a pointer position. -/
def resizeHandleAtPoint? (rect : MDIRect) (x y : Float) (config : MDIConfig)
    : Option MDIResizeHandle :=
  if !rect.contains x y then
    none
  else
    let distLeft := x - rect.x
    let distRight := rect.right - x
    let distTop := y - rect.y
    let distBottom := rect.bottom - y
    let nearLeftCorner := distLeft <= config.cornerHandleSize
    let nearRightCorner := distRight <= config.cornerHandleSize
    let nearTopCorner := distTop <= config.cornerHandleSize
    let nearBottomCorner := distBottom <= config.cornerHandleSize
    let nearLeftEdge := distLeft <= config.edgeHandleSize
    let nearRightEdge := distRight <= config.edgeHandleSize
    let nearTopEdge := distTop <= config.edgeHandleSize
    let nearBottomEdge := distBottom <= config.edgeHandleSize
    if nearLeftCorner && nearTopCorner then
      some .northWest
    else if nearRightCorner && nearTopCorner then
      some .northEast
    else if nearLeftCorner && nearBottomCorner then
      some .southWest
    else if nearRightCorner && nearBottomCorner then
      some .southEast
    else if nearTopEdge then
      some .north
    else if nearBottomEdge then
      some .south
    else if nearLeftEdge then
      some .west
    else if nearRightEdge then
      some .east
    else
      none

/-- Apply resize delta for a given handle with min-size enforcement. -/
def resizedRect (handle : MDIResizeHandle) (startRect : MDIRect)
    (startX startY x y minWidth minHeight : Float) : MDIRect := Id.run do
  let dx := x - startX
  let dy := y - startY
  let mut newX := startRect.x
  let mut newY := startRect.y
  let mut newW := startRect.width
  let mut newH := startRect.height

  match handle with
  | .north =>
      newY := startRect.y + dy
      newH := startRect.height - dy
  | .south =>
      newH := startRect.height + dy
  | .east =>
      newW := startRect.width + dx
  | .west =>
      newX := startRect.x + dx
      newW := startRect.width - dx
  | .northEast =>
      newY := startRect.y + dy
      newH := startRect.height - dy
      newW := startRect.width + dx
  | .northWest =>
      newY := startRect.y + dy
      newH := startRect.height - dy
      newX := startRect.x + dx
      newW := startRect.width - dx
  | .southEast =>
      newH := startRect.height + dy
      newW := startRect.width + dx
  | .southWest =>
      newH := startRect.height + dy
      newX := startRect.x + dx
      newW := startRect.width - dx

  let anchorsWest :=
    handle == .west || handle == .northWest || handle == .southWest
  let anchorsNorth :=
    handle == .north || handle == .northWest || handle == .northEast

  if newW < minWidth then
    if anchorsWest then
      newX := startRect.right - minWidth
    newW := minWidth

  if newH < minHeight then
    if anchorsNorth then
      newY := startRect.bottom - minHeight
    newH := minHeight

  if newW < 1.0 then
    newW := 1.0
  if newH < 1.0 then
    newH := 1.0

  pure {
    x := newX
    y := newY
    width := newW
    height := newH
  }

/-- Compute resized rectangle for drag update, optionally clamped to host. -/
def resizeRectForDrag (handle : MDIResizeHandle) (startRect : MDIRect)
    (startX startY x y minWidth minHeight : Float)
    (hostRect? : Option MDIRect) (clampToHost : Bool) : MDIRect :=
  let resized := resizedRect handle startRect startX startY x y minWidth minHeight
  if clampToHost then
    match hostRect? with
    | some host => clampRectToHost resized host
    | none => resized
  else
    resized

/-- Compute snap target from pointer location in host coordinates. -/
def snapTargetAtPoint (host : MDIRect) (x y threshold : Float) : Option MDISnapTarget :=
  let nearLeft := x <= host.x + threshold
  let nearRight := x >= host.right - threshold
  let nearTop := y <= host.y + threshold
  let nearBottom := y >= host.bottom - threshold
  let maximizeBand := y <= host.y + threshold * 0.5

  if nearLeft && nearTop then
    some .topLeft
  else if nearRight && nearTop then
    some .topRight
  else if nearLeft && nearBottom then
    some .bottomLeft
  else if nearRight && nearBottom then
    some .bottomRight
  else if maximizeBand then
    some .maximize
  else if nearLeft then
    some .left
  else if nearRight then
    some .right
  else if nearTop then
    some .top
  else if nearBottom then
    some .bottom
  else
    none

/-- Compute snapped rectangle for a target in host bounds. -/
def snapRect (host : MDIRect) (target : MDISnapTarget) : MDIRect :=
  let halfW := host.width / 2.0
  let halfH := host.height / 2.0
  match target with
  | .left =>
      { x := host.x, y := host.y, width := halfW, height := host.height }
  | .right =>
      { x := host.x + halfW, y := host.y, width := halfW, height := host.height }
  | .top =>
      { x := host.x, y := host.y, width := host.width, height := halfH }
  | .bottom =>
      { x := host.x, y := host.y + halfH, width := host.width, height := halfH }
  | .topLeft =>
      { x := host.x, y := host.y, width := halfW, height := halfH }
  | .topRight =>
      { x := host.x + halfW, y := host.y, width := halfW, height := halfH }
  | .bottomLeft =>
      { x := host.x, y := host.y + halfH, width := halfW, height := halfH }
  | .bottomRight =>
      { x := host.x + halfW, y := host.y + halfH, width := halfW, height := halfH }
  | .maximize =>
      host

/-- Commit snap target on drag release and update maximize restore state. -/
def commitSnapRelease (windowId : Nat) (windowRect host : MDIRect) (target : MDISnapTarget)
    (savedMaxRects : Std.HashMap Nat MDIRect) : MDIRect × Std.HashMap Nat MDIRect :=
  if target == .maximize then
    if MDIRect.approxEq windowRect host then
      match savedMaxRects.get? windowId with
      | some savedRect => (savedRect, savedMaxRects.erase windowId)
      | none => (snapRect host .maximize, savedMaxRects)
    else
      (snapRect host .maximize, savedMaxRects.insert windowId windowRect)
  else
    (snapRect host target, savedMaxRects.erase windowId)

end MDI

private structure MDIWindowRuntime where
  id : Nat
  rootName : ComponentId
  titlebarName : ComponentId
  contentRenders : Array ComponentRender

private structure MDIMoveDrag where
  windowId : Nat
  startX : Float
  startY : Float
  startRect : MDIRect
deriving Repr, BEq, Inhabited

private structure MDIResizeDrag where
  windowId : Nat
  handle : MDIResizeHandle
  startX : Float
  startY : Float
  startRect : MDIRect
deriving Repr, BEq, Inhabited

private inductive MDIDragMode where
  | none
  | move (drag : MDIMoveDrag)
  | resize (drag : MDIResizeDrag)
deriving Repr, BEq, Inhabited

private structure MDIState where
  windows : Array MDIWindowState := #[]
  zOrder : Array Nat := #[]
  activeWindow : Option Nat := none
  dragMode : MDIDragMode := .none
  snapPreview : Option (Nat × MDISnapTarget) := none
  hostRect : Option MDIRect := none
  savedMaxRects : Std.HashMap Nat MDIRect := {}
deriving Repr, Inhabited

private inductive MDIRenderEntry where
  | window (state : MDIWindowState) (isActive : Bool) (isDragging : Bool)
  | preview (rect : MDIRect)
deriving Repr, BEq

private def MDIRenderEntry.key (entry : MDIRenderEntry) : Nat :=
  match entry with
  | .window winState _ _ => winState.id + 1
  | .preview _ => 0

private inductive MDIInputEvent where
  | click (data : ClickData)
  | hover (data : HoverData)
  | mouseUp (data : MouseButtonData)

private def MDIState.activateWindow (s : MDIState) (windowId : Nat) : MDIState :=
  {
    s with
    activeWindow := some windowId
    zOrder := MDI.bringToFront s.zOrder windowId
  }

private def MDIState.setHostRect (s : MDIState) (hostRect? : Option MDIRect) : MDIState :=
  match hostRect? with
  | some hostRect => { s with hostRect := some hostRect }
  | none => s

private def MDIState.renderEntries (state : MDIState) (config : MDIConfig) : Array MDIRenderEntry :=
  Id.run do
    let ordered := MDI.orderedWindows state.windows state.zOrder
    let mut entries : Array MDIRenderEntry := #[]
    for window in ordered do
      let isActive := state.activeWindow == some window.id
      let isDragging :=
        match state.dragMode with
        | .move drag => drag.windowId == window.id
        | .resize drag => drag.windowId == window.id
        | .none => false
      entries := entries.push (.window window isActive isDragging)
    if config.showSnapPreview then
      match state.snapPreview, state.hostRect with
      | some (_, target), some host =>
          entries := entries.push (.preview (MDI.snapRect (MDI.hostRectLocal host) target))
      | _, _ =>
          pure ()
    pure entries

private def snapPreviewVisual (rect : MDIRect) (theme : Theme) : WidgetBuilder := do
  let previewWid ← freshId
  let previewStyle : BoxStyle := {
    position := .absolute
    left := some rect.x
    top := some rect.y
    width := .length rect.width
    height := .length rect.height
    backgroundColor := some (theme.primary.background.withAlpha 0.14)
    borderColor := some (theme.primary.borderFocused.withAlpha 0.9)
    borderWidth := 2.0
    cornerRadius := theme.cornerRadius
    layer := .overlay
  }
  pure (.rect previewWid none previewStyle)

private def mdiWindowVisual (rootName titlebarName : ComponentId)
    (window : MDIWindowState) (isActive isDragging : Bool)
    (config : MDIConfig) (theme : Theme)
    (contentWidgets : Array WidgetBuilder) : WidgetBuilder := do
  let borderColor :=
    if isActive then theme.primary.borderFocused
    else theme.panel.border
  let titleBg :=
    if isDragging then theme.primary.background.withAlpha 0.35
    else if isActive then theme.primary.background.withAlpha 0.2
    else theme.panel.backgroundHover.withAlpha 0.65

  let windowStyle : BoxStyle := {
    position := .absolute
    left := some window.rect.x
    top := some window.rect.y
    width := .length window.rect.width
    height := .length window.rect.height
    minWidth := some window.minWidth
    minHeight := some window.minHeight
    backgroundColor := some theme.panel.background
    borderColor := some borderColor
    borderWidth := if isActive then 2.0 else 1.0
    cornerRadius := theme.cornerRadius
  }

  let titleStyle : BoxStyle := {
    backgroundColor := some titleBg
    borderColor := some (theme.panel.border.withAlpha 0.75)
    borderWidth := 0
    minHeight := some config.titlebarHeight
    maxHeight := some config.titlebarHeight
    padding := EdgeInsets.symmetric 10 4
  }

  let titleText ← text' window.title theme.smallFont theme.text .left

  let titlebarWid ← freshId
  let titlebarProps : FlexContainer := {
    direction := .row
    justifyContent := .spaceBetween
    alignItems := .center
  }
  let titlebar : Widget := Widget.flexC titlebarWid titlebarName titlebarProps titleStyle #[titleText]

  let contentWid ← freshId
  let contentStyle : BoxStyle := {
    padding := EdgeInsets.uniform 8
    width := .percent 1.0
    height := .percent 1.0
    flexItem := some (FlexItem.growing 1)
  }
  let contentProps : FlexContainer := {
    direction := .column
    gap := 6
  }
  let contentChildren ← contentWidgets.mapM fun builder => builder
  let content : Widget := .flex contentWid none contentProps contentStyle contentChildren

  let rootWid ← freshId
  let rootProps : FlexContainer := {
    direction := .column
    gap := 0
  }
  pure (Widget.flexC rootWid rootName rootProps windowStyle #[titlebar, content])

private def mdiVisual (hostName : ComponentId) (config : MDIConfig) (theme : Theme)
    (windowBuilders : Array WidgetBuilder) : WidgetBuilder := do
  let bgColor := config.hostBackground.getD (theme.panel.background.withAlpha 0.35)
  let hostStyle : BoxStyle := {
    backgroundColor := some bgColor
    borderColor := some theme.panel.border
    borderWidth := 1
    cornerRadius := theme.cornerRadius
    width := if config.fillWidth then .percent 1.0 else .auto
    height := if config.fillHeight then .percent 1.0 else .auto
    minWidth := config.width
    minHeight := config.height
    maxWidth := if config.fillWidth then none else config.width
    maxHeight := if config.fillHeight then none else config.height
    flexItem := if config.fillWidth || config.fillHeight then some (FlexItem.growing 1) else none
  }

  let childWidgets ← windowBuilders.mapM fun builder => builder

  let hostWid ← freshId
  let hostProps : FlexContainer := {
    direction := .column
    gap := 0
  }
  pure (Widget.flexC hostWid hostName hostProps hostStyle childWidgets)

/-- Create a reactive MDI widget with draggable, resizable, snappable windows. -/
def mdi (config : MDIConfig := {}) (windowSpecs : Array MDIWindowSpec) : WidgetM MDIResult := do
  let theme ← getThemeW
  let hostName ← registerComponentW (isInteractive := false)

  let mut runtimes : Array MDIWindowRuntime := #[]
  let mut initialWindows : Array MDIWindowState := #[]
  for spec in windowSpecs do
    let rootName ← registerComponentW
    let titlebarName ← registerComponentW
    let (_, contentRenders) ← runWidgetChildren spec.content
    runtimes := runtimes.push {
      id := spec.id
      rootName := rootName
      titlebarName := titlebarName
      contentRenders := contentRenders
    }
    initialWindows := initialWindows.push {
      id := spec.id
      title := spec.title
      rect := spec.rect
      minWidth := max config.minWindowWidth spec.minWidth
      minHeight := max config.minWindowHeight spec.minHeight
      movable := spec.movable
      resizable := spec.resizable
    }

  let runtimeById : Std.HashMap Nat MDIWindowRuntime :=
    runtimes.foldl (init := {}) fun m runtime => m.insert runtime.id runtime

  let allClicks ← useAllClicks
  let allHovers ← useAllHovers
  let allMouseUp ← useAllMouseUp

  let (moveEvent, fireMove) ← Reactive.newTriggerEvent (t := Spider) (a := Nat × MDIRect)
  let (resizeEvent, fireResize) ← Reactive.newTriggerEvent (t := Spider) (a := Nat × MDIRect)
  let (snapEvent, fireSnap) ← Reactive.newTriggerEvent (t := Spider) (a := Nat × MDISnapTarget)

  let liftSpider {α : Type} : SpiderM α → WidgetM α := fun m => StateT.lift (liftM m)
  let clickEvents ← liftSpider (Event.mapM MDIInputEvent.click allClicks)
  let hoverEvents ← liftSpider (Event.mapM MDIInputEvent.hover allHovers)
  let mouseUpEvents ← liftSpider (Event.mapM MDIInputEvent.mouseUp allMouseUp)
  let allInputEvents ← liftSpider (Event.leftmostM [clickEvents, hoverEvents, mouseUpEvents])

  let initialState : MDIState := {
    windows := initialWindows
    zOrder := initialWindows.map (·.id)
  }

  let stateDyn ← Reactive.foldDynM
    (fun event state => do
      match event with
      | .click data =>
        let hostRect? := MDI.widgetRectFromLayouts hostName data.componentMap data.layouts
        let state := state.setHostRect hostRect?
        if data.click.button != 0 then
          pure { state with dragMode := .none, snapPreview := none }
        else
          let clickedWindow? :=
            MDI.topmostWindowBy state.zOrder fun windowId =>
              match runtimeById.get? windowId with
              | some runtime => hitWidget data runtime.rootName
              | none => false
          match clickedWindow? with
          | some windowId =>
            let state' := state.activateWindow windowId
            match MDI.windowById? state'.windows windowId with
            | some window =>
              let (clickX, clickY) :=
                match state'.hostRect with
                | some host => MDI.pointInHostLocal host data.click.x data.click.y
                | none => (data.click.x, data.click.y)
              let handle? :=
                if window.resizable then
                  MDI.resizeHandleAtPoint? window.rect clickX clickY config
                else
                  none
              match handle? with
              | some handle =>
                pure {
                  state' with
                  dragMode := .resize {
                    windowId := windowId
                    handle := handle
                    startX := data.click.x
                    startY := data.click.y
                    startRect := window.rect
                  }
                  snapPreview := none
                }
              | none =>
                let titlebarHit :=
                  match runtimeById.get? windowId with
                  | some runtime => hitWidget data runtime.titlebarName
                  | none => false
                if titlebarHit && window.movable then
                  pure {
                    state' with
                    dragMode := .move {
                      windowId := windowId
                      startX := data.click.x
                      startY := data.click.y
                      startRect := window.rect
                    }
                    snapPreview := none
                  }
                else
                  pure { state' with dragMode := .none, snapPreview := none }
            | none =>
              pure { state' with dragMode := .none, snapPreview := none }
          | none =>
            if hitWidget data hostName then
              pure { state with activeWindow := none, dragMode := .none, snapPreview := none }
            else
              pure state

      | .hover data =>
        let hostRect? := MDI.widgetRectFromLayouts hostName data.componentMap data.layouts
        let state := state.setHostRect hostRect?
        match state.dragMode with
        | .none =>
          pure state
        | .move drag =>
          match MDI.windowById? state.windows drag.windowId with
          | none =>
              pure { state with dragMode := .none, snapPreview := none }
          | some window =>
              let hostLocal? := state.hostRect.map MDI.hostRectLocal
              let moved := MDI.moveRectForDrag
                drag.startRect drag.startX drag.startY data.x data.y
                hostLocal? config.clampToHost
              if moved != window.rect then
                SpiderM.liftIO (fireMove (drag.windowId, moved))
              let windows := MDI.updateWindowById state.windows drag.windowId (fun w => { w with rect := moved })
              let snapTarget? :=
                if config.showSnapPreview then
                  match state.hostRect with
                  | some host => MDI.snapTargetAtPoint host data.x data.y config.snapThreshold
                  | none => none
                else
                  none
              pure {
                state with
                windows := windows
                snapPreview := snapTarget?.map (fun target => (drag.windowId, target))
              }
        | .resize drag =>
          match MDI.windowById? state.windows drag.windowId with
          | none =>
              pure { state with dragMode := .none, snapPreview := none }
          | some window =>
              let minW := max config.minWindowWidth window.minWidth
              let minH := max config.minWindowHeight window.minHeight
              let hostLocal? := state.hostRect.map MDI.hostRectLocal
              let resized := MDI.resizeRectForDrag drag.handle drag.startRect drag.startX drag.startY
                data.x data.y minW minH hostLocal? config.clampToHost
              if resized != window.rect then
                SpiderM.liftIO (fireResize (drag.windowId, resized))
              let windows := MDI.updateWindowById state.windows drag.windowId (fun w => { w with rect := resized })
              pure {
                state with
                windows := windows
                snapPreview := none
              }

      | .mouseUp data =>
        let hostRect? := MDI.widgetRectFromLayouts hostName data.componentMap data.layouts
        let state := state.setHostRect hostRect?
        match state.dragMode with
        | .none =>
            pure { state with snapPreview := none }
        | .resize _ =>
            pure { state with dragMode := .none, snapPreview := none }
        | .move drag =>
            let snapTarget? :=
              match state.snapPreview with
              | some (windowId, target) => if windowId == drag.windowId then some target else none
              | none => none
            match snapTarget?, state.hostRect, MDI.windowById? state.windows drag.windowId with
            | some target, some host, some window =>
                let hostLocal := MDI.hostRectLocal host
                let (nextRect, nextSaved) := MDI.commitSnapRelease
                  drag.windowId window.rect hostLocal target state.savedMaxRects
                SpiderM.liftIO (fireSnap (drag.windowId, target))
                SpiderM.liftIO (fireMove (drag.windowId, nextRect))
                let windows := MDI.updateWindowById state.windows drag.windowId (fun w => { w with rect := nextRect })
                pure {
                  state with
                  windows := windows
                  savedMaxRects := nextSaved
                  dragMode := .none
                  snapPreview := none
                }
            | _, _, _ =>
                pure { state with dragMode := .none, snapPreview := none }
    )
    initialState
    allInputEvents

  let activeDyn ← Dynamic.mapM (fun s => s.activeWindow) stateDyn
  let windowsDyn ← Dynamic.mapM (fun s => MDI.orderedWindows s.windows s.zOrder) stateDyn
  let renderEntriesDyn ← Dynamic.mapM (fun s => s.renderEntries config) stateDyn

  let buildEntry : MDIRenderEntry → WidgetM Unit := fun entry => do
    match entry with
    | .preview rect =>
        emit (snapPreviewVisual rect theme)
    | .window window isActive isDragging =>
        match runtimeById.get? window.id with
        | none =>
            emit (spacer 0 0)
        | some runtime =>
            let render : ComponentRender := {
              materialize := do
                let contentWidgets ← ComponentRender.materializeAll runtime.contentRenders
                pure <| mdiWindowVisual runtime.rootName runtime.titlebarName
                  window isActive isDragging config theme contentWidgets
              version := do
                let versions ← runtime.contentRenders.mapM (fun r => r.version)
                let mut h : Nat := 2166136261
                for v in versions do
                  h := h * 16777619 + v + 1
                pure h
              alwaysDynamic := runtime.contentRenders.any (fun r => r.alwaysDynamic)
            }
            emitRender render

  let combineEntries : Array WidgetBuilder → WidgetBuilder := fun builders =>
    mdiVisual hostName config theme builders

  let _ ← dynWidgetKeyedListWith renderEntriesDyn MDIRenderEntry.key (· != ·)
    buildEntry (combine := combineEntries)

  pure {
    activeWindow := activeDyn
    windows := windowsDyn
    onWindowMove := moveEvent
    onWindowResize := resizeEvent
    onWindowSnap := snapEvent
  }

end Afferent.Canopy
