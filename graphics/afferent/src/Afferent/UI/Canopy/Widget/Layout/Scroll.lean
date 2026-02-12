/-
  Canopy ScrollContainer Widget
  Scrollable viewport for content that exceeds available space.
-/
import Reactive
import Afferent.UI.Canopy.Core
import Afferent.UI.Canopy.Theme
import Afferent.UI.Canopy.Reactive.Component
import Afferent.Graphics.Text.Measurer

namespace Afferent.Canopy

open Afferent.Arbor hiding Event
open Reactive Reactive.Host
open Afferent.Canopy.Reactive

/-- Scrollbar visibility mode. -/
inductive ScrollbarVisibility where
  /-- Always show scrollbars. -/
  | always
  /-- Show scrollbars only when hovering. -/
  | hover
  /-- Never show scrollbars (scroll via wheel only). -/
  | hidden
deriving Repr, BEq, Inhabited

/-- Configuration for scroll container. -/
structure ScrollContainerConfig where
  /-- Viewport width in pixels. -/
  width : Float := 300
  /-- Viewport height in pixels. -/
  height : Float := 200
  /-- Enable vertical scrolling. -/
  verticalScroll : Bool := true
  /-- Enable horizontal scrolling. -/
  horizontalScroll : Bool := false
  /-- Scroll sensitivity multiplier (pixels per scroll unit). -/
  scrollSpeed : Float := 20.0
  /-- Scrollbar visibility mode. -/
  scrollbarVisibility : ScrollbarVisibility := .always
  /-- Scrollbar track thickness in pixels. -/
  scrollbarThickness : Float := 8.0
  /-- Scrollbar thumb minimum length in pixels. -/
  scrollbarMinThumb : Float := 30.0
  /-- Scrollbar corner radius. -/
  scrollbarRadius : Float := 4.0
  /-- Fill available height instead of using fixed pixel height. -/
  fillHeight : Bool := false
  /-- Fill available width instead of using fixed pixel width. -/
  fillWidth : Bool := false
deriving Repr, Inhabited

namespace ScrollContainerConfig

def default : ScrollContainerConfig := {}

/-- Create a vertical-only scroll config. -/
def vertical (height : Float) : ScrollContainerConfig :=
  { height, verticalScroll := true, horizontalScroll := false }

/-- Create a horizontal-only scroll config. -/
def horizontal (width : Float) : ScrollContainerConfig :=
  { width, verticalScroll := false, horizontalScroll := true }

/-- Create a config for both directions. -/
def both (width height : Float) : ScrollContainerConfig :=
  { width, height, verticalScroll := true, horizontalScroll := true }

end ScrollContainerConfig

/-- State for scrollbar dragging. -/
structure ScrollbarDragState where
  /-- Whether we're currently dragging. -/
  isDragging : Bool := false
  /-- Y coordinate where drag started. -/
  dragStartY : Float := 0
  /-- Scroll offset when drag started. -/
  initialOffsetY : Float := 0
deriving Repr, BEq, Inhabited

/-- Result from scrollContainer widget. -/
structure ScrollContainerResult where
  /-- Current scroll state as a Dynamic. -/
  scrollState : Reactive.Dynamic Spider ScrollState

/-- Configuration for HTML-like document flow:
    static vertical stacking inside a scrollable viewport. -/
structure DocumentFlowConfig where
  /-- Initial/fallback viewport width in pixels. -/
  width : Float := 300
  /-- Initial/fallback viewport height in pixels. -/
  height : Float := 200
  /-- Vertical gap between stacked children. -/
  gap : Float := 0
  /-- Padding inside the document content column. -/
  padding : Float := 0
  /-- Fill available width instead of fixed width. -/
  fillWidth : Bool := true
  /-- Fill available height instead of fixed height. -/
  fillHeight : Bool := true
  /-- Scroll sensitivity multiplier. -/
  scrollSpeed : Float := 20.0
  /-- Scrollbar visibility mode. -/
  scrollbarVisibility : ScrollbarVisibility := .always
  /-- Scrollbar track thickness in pixels. -/
  scrollbarThickness : Float := 8.0
  /-- Scrollbar thumb minimum length in pixels. -/
  scrollbarMinThumb : Float := 30.0
  /-- Scrollbar corner radius. -/
  scrollbarRadius : Float := 4.0
deriving Repr, Inhabited

/-- Build scrollbar render config from theme and container config. -/
def buildScrollbarConfig (config : ScrollContainerConfig) (theme : Theme)
    : ScrollbarRenderConfig :=
  match config.scrollbarVisibility with
  | .hidden => ScrollbarRenderConfig.hidden
  | _ => {
    showVertical := config.verticalScroll
    showHorizontal := config.horizontalScroll
    thickness := config.scrollbarThickness
    minThumbLength := config.scrollbarMinThumb
    cornerRadius := config.scrollbarRadius
    trackColor := theme.scrollbar.track
    thumbColor := theme.scrollbar.thumb
  }

/-- Check if a point is within the vertical scrollbar track area.
    Returns Some (relativeY, trackHeight) if in scrollbar, None otherwise. -/
def isInVerticalScrollbar (config : ScrollContainerConfig)
    (scrollContainerLayout : Trellis.ComputedLayout)
    (mouseX mouseY : Float) : Option (Float × Float) :=
  if !config.verticalScroll || config.scrollbarVisibility == .hidden then
    none
  else
    let contentRect := scrollContainerLayout.contentRect
    let trackX := contentRect.x + contentRect.width - config.scrollbarThickness
    let trackY := contentRect.y
    let trackWidth := config.scrollbarThickness
    let trackHeight := contentRect.height
    -- Check if mouse is within the scrollbar track
    if mouseX >= trackX && mouseX <= trackX + trackWidth &&
       mouseY >= trackY && mouseY <= trackY + trackHeight then
      some (mouseY - trackY, trackHeight)
    else
      none

/-- Find this scroll container's computed layout by registered name. -/
def findWidgetLayoutByName (componentMap : Std.HashMap ComponentId WidgetId)
    (layouts : Trellis.LayoutResult)
    (name : ComponentId) : Option Trellis.ComputedLayout := do
  let widgetId ← componentMap.get? name
  layouts.get widgetId

/-- Calculate scroll offset from a relative Y position in the scrollbar track. -/
def scrollOffsetFromTrackPosition (relativeY trackHeight viewportH contentH : Float)
    (minThumb : Float) : Float :=
  let maxScrollY := contentH - viewportH
  if maxScrollY <= 0 then 0
  else
    -- Calculate thumb size
    let thumbRatio := viewportH / contentH
    let thumbHeight := max minThumb (trackHeight * thumbRatio)
    let thumbTravel := trackHeight - thumbHeight
    if thumbTravel <= 0 then 0
    else
      -- Convert track position to scroll offset
      -- The click position maps to the center of the thumb
      let thumbCenterY := relativeY
      let normalizedPos := (thumbCenterY - thumbHeight / 2) / thumbTravel
      let clampedPos := max 0 (min 1 normalizedPos)
      clampedPos * maxScrollY

/-- Build the visual representation of a scroll container. -/
def scrollContainerVisual (name : ComponentId) (config : ScrollContainerConfig) (theme : Theme)
    (scrollState : ScrollState) (contentWidth contentHeight : Float)
    (child : WidgetBuilder) : WidgetBuilder := do
  let style : BoxStyle := {
    -- Use percentage-based sizing when fill options are enabled
    width := if config.fillWidth then .percent 1.0 else .auto
    height := if config.fillHeight then .percent 1.0 else .auto
    minWidth := if config.fillWidth then none else some config.width
    minHeight := if config.fillHeight then none else some config.height
    maxWidth := if config.fillWidth then none else some config.width
    maxHeight := if config.fillHeight then none else some config.height
    flexItem := if config.fillHeight || config.fillWidth
                then some (Trellis.FlexItem.growing 1)
                else none
  }
  let scrollbarConfig := buildScrollbarConfig config theme
  namedScroll name style contentWidth contentHeight scrollState scrollbarConfig child

/-- Combined state for scroll position and drag handling. -/
structure ScrollCombinedState where
  scroll : ScrollState := {}
  drag : ScrollbarDragState := {}
deriving Repr, BEq, Inhabited

/-- Event type for scroll container inputs.
    Note: click and hover carry ClickData/HoverData directly so we can read widgetIdRef
    inside foldDynM where we have IO access. -/
inductive ScrollInputEvent where
  | wheel (data : ScrollData)
  | click (data : ClickData)
  | hover (data : HoverData)
  | mouseUp

/-- Create a reactive scroll container using WidgetM.
    Wraps children in a scrollable viewport that responds to scroll wheel events
    and supports scrollbar dragging.

    - `config`: Scroll container configuration (dimensions, directions)
    - `children`: Child widgets to render inside the scrollable area

    Returns a tuple of the children's result and scroll container result.
-/
def scrollContainer (config : ScrollContainerConfig) (children : WidgetM α)
    : WidgetM (α × ScrollContainerResult) := do
  let theme ← getThemeW
  let fontRegistry ← getFontRegistry
  let name ← registerComponentW
  let scrollEvents ← useScroll name
  let allClicks ← useAllClicks
  let allHovers ← useAllHovers
  let allMouseUp ← useAllMouseUp

  -- Run children to get their renders
  let (result, childRenders) ← runWidgetChildren children
  let hashVersions := fun (versions : Array Nat) =>
    versions.foldl (init := 2166136261) fun acc v =>
      acc * 16777619 + v + 1

  -- Track content size via ref (updated each render)
  -- Initialize with large content height to allow scrolling before first render
  let contentSizeRef ← SpiderM.liftIO (IO.mkRef (config.width, config.height * 10.0))

  -- Convert events to unified ScrollInputEvent stream
  -- Note: we pass ClickData/HoverData directly and use findWidgetIdByName inside foldDynM
  -- to find our widget ID from the actual widget tree.
  -- All Event functions return SpiderM, so we lift to WidgetM via StateT.lift ∘ liftM.
  let liftSpider {α : Type} : SpiderM α → WidgetM α := fun m => StateT.lift (liftM m)
  let wheelEvents : Reactive.Event Spider ScrollInputEvent ←
    liftSpider (Event.mapM ScrollInputEvent.wheel scrollEvents)
  let clickEvents : Reactive.Event Spider ScrollInputEvent ←
    liftSpider (Event.mapM ScrollInputEvent.click allClicks)
  let hoverEvents : Reactive.Event Spider ScrollInputEvent ←
    liftSpider (Event.mapM ScrollInputEvent.hover allHovers)
  let mouseUpEvents : Reactive.Event Spider ScrollInputEvent ←
    liftSpider (Event.mapM (fun _ => ScrollInputEvent.mouseUp) allMouseUp)

  -- Merge all events
  let allInputEvents : Reactive.Event Spider ScrollInputEvent ←
    liftSpider (Event.leftmostM [wheelEvents, clickEvents, hoverEvents, mouseUpEvents])

  -- Fold all events into combined state
  let combinedState ← Reactive.foldDynM
    (fun (event : ScrollInputEvent) state => do
      let (contentW, contentH) ← SpiderM.liftIO contentSizeRef.get
      match event with
      | .wheel scrollData =>
        -- Handle scroll wheel
        let (viewportW, viewportH) :=
          match findWidgetLayoutByName scrollData.componentMap scrollData.layouts name with
          | some layout => (layout.contentRect.width, layout.contentRect.height)
          | none => (config.width, config.height)
        let baseScroll := state.scroll.clamp viewportW viewportH contentW contentH
        let dx := if config.horizontalScroll then -scrollData.scroll.deltaX * config.scrollSpeed else 0
        let dy := if config.verticalScroll then -scrollData.scroll.deltaY * config.scrollSpeed else 0
        let newScroll := baseScroll.scrollBy dx dy viewportW viewportH contentW contentH
        pure { state with scroll := newScroll }

      | .click clickData =>
        -- Check if click is in scrollbar area of this scroll container
        -- Find our widget ID by name from the actual widget tree
        match clickData.componentMap.get? name with
        | some widgetId =>
          let x := clickData.click.x
          let y := clickData.click.y
          let layouts := clickData.layouts
          match layouts.get widgetId with
          | some layout =>
            let viewportW := layout.contentRect.width
            let viewportH := layout.contentRect.height
            let baseScroll := state.scroll.clamp viewportW viewportH contentW contentH
            match isInVerticalScrollbar config layout x y with
            | some (relativeY, trackHeight) =>
              -- Click in scrollbar - calculate new position and start dragging
              let newOffsetY := scrollOffsetFromTrackPosition relativeY trackHeight
                                 viewportH contentH config.scrollbarMinThumb
              let newScroll :=
                ({ baseScroll with offsetY := newOffsetY }).clamp viewportW viewportH contentW contentH
              let newDrag := { isDragging := true, dragStartY := y, initialOffsetY := newOffsetY }
              pure { scroll := newScroll, drag := newDrag }
            | none =>
              -- Click outside scrollbar - stop any dragging
              pure { scroll := baseScroll, drag := {} }
          | none => pure state
        | none => pure state

      | .hover hoverData =>
        -- Update scroll position while dragging
        if state.drag.isDragging then
          -- Find our widget ID by name from the actual widget tree
          match hoverData.componentMap.get? name with
          | some widgetId =>
            let y := hoverData.y
            let layouts := hoverData.layouts
            match layouts.get widgetId with
            | some layout =>
              let contentRect := layout.contentRect
              let viewportW := contentRect.width
              let viewportH := contentRect.height
              let baseScroll := state.scroll.clamp viewportW viewportH contentW contentH
              let trackY := contentRect.y
              let trackHeight := contentRect.height
              let relativeY := y - trackY
              let newOffsetY := scrollOffsetFromTrackPosition relativeY trackHeight
                                 viewportH contentH config.scrollbarMinThumb
              let newScroll :=
                ({ baseScroll with offsetY := newOffsetY }).clamp viewportW viewportH contentW contentH
              pure { state with scroll := newScroll }
            | none => pure state
          | none => pure state
        else
          pure state

      | .mouseUp =>
        -- Stop dragging
        pure { state with drag := {} }
    )
    ({} : ScrollCombinedState)
    allInputEvents

  -- Extract just the scroll state for the result
  let scrollState ← Dynamic.mapM (fun s => s.scroll) combinedState

  -- Use dynWidget for efficient change-driven rebuilds
  let _ ← dynWidget combinedState fun state => do
    let render : ComponentRender := {
      materialize := do
        let widgets ← ComponentRender.materializeAll childRenders
        -- Build the child stack (fill width for vertical-only scroll).
        -- Use static flow defaults so children keep intrinsic size unless explicitly overridden.
        let childStyle : BoxStyle := if config.horizontalScroll then {} else { width := .percent 1.0 }
        let childBuilder := staticColumn (gap := 0) (style := childStyle) widgets
        -- Build a temporary widget tree and measure true content size.
        let (builtChild, _builderState) ← childBuilder.run {}
        let measureW := config.width
        let measureAt := fun (availableH : Float) => do
          let measured ← Afferent.runWithFonts fontRegistry
            (Afferent.Arbor.measureWidget builtChild measureW availableH)
          let layouts := Trellis.layout measured.node measureW availableH
          let rootLayout := layouts.get measured.node.id
          let rootW := rootLayout.map (·.borderRect.width) |>.getD config.width
          let rootH := rootLayout.map (·.borderRect.height) |>.getD config.height
          let childIds := measured.node.children.flatMap Trellis.LayoutNode.allIds
          let (measuredW, measuredH) :=
            if childIds.isEmpty then
              (rootW, rootH)
            else
              let initMinX := rootLayout.map (·.borderRect.x) |>.getD 0
              let initMinY := rootLayout.map (·.borderRect.y) |>.getD 0
              let initMaxX := rootLayout.map (fun l => l.borderRect.x + l.borderRect.width) |>.getD rootW
              let initMaxY := rootLayout.map (fun l => l.borderRect.y + l.borderRect.height) |>.getD rootH
              let (minX, minY, maxX, maxY, foundAny) := childIds.foldl
                (fun (acc : Float × Float × Float × Float × Bool) id =>
                  let (currMinX, currMinY, currMaxX, currMaxY, found) := acc
                  match layouts.get id with
                  | none => acc
                  | some cl =>
                    let rect := cl.borderRect
                    let rMaxX := rect.x + rect.width
                    let rMaxY := rect.y + rect.height
                    if found then
                      (min currMinX rect.x, min currMinY rect.y, max currMaxX rMaxX, max currMaxY rMaxY, true)
                    else
                      (rect.x, rect.y, rMaxX, rMaxY, true)
                )
                (initMinX, initMinY, initMaxX, initMaxY, false)
              if foundAny then
                (max 0 (maxX - minX), max 0 (maxY - minY))
              else
                (rootW, rootH)
          pure (measuredW, measuredH)
        -- First pass uses a large height probe to capture naturally tall content.
        -- If the content resolves to nearly the probe itself (e.g., percent-height/grow feedback),
        -- fall back to viewport-constrained measurement to avoid runaway scroll ranges.
        let probeH : Float := 1000000
        let (probeW, probeContentH) ← measureAt probeH
        let (measuredContentW, measuredContentH) ←
          if probeContentH >= probeH * 0.9 then
            measureAt config.height
          else
            pure (probeW, probeContentH)
        let contentW := if config.horizontalScroll then max config.width measuredContentW else config.width
        let contentH := if config.verticalScroll then max config.height measuredContentH else config.height
        contentSizeRef.set (contentW, contentH)
        -- Pass the builder (not the built widget) so IDs are fresh
        pure (scrollContainerVisual name config theme state.scroll contentW contentH childBuilder)
      version := do
        let childVersions ← childRenders.mapM (fun r => r.version)
        pure (hashVersions childVersions)
    }
    emitRender render

  pure (result, { scrollState })

/-- Vertical-only scroll container (convenience wrapper).
    - `height`: Viewport height in pixels
    - `children`: Child widgets
-/
def vscrollContainer (height : Float) (children : WidgetM α)
    : WidgetM (α × ScrollContainerResult) :=
  scrollContainer (ScrollContainerConfig.vertical height) children

/-- Horizontal-only scroll container (convenience wrapper).
    - `width`: Viewport width in pixels
    - `children`: Child widgets
-/
def hscrollContainer (width : Float) (children : WidgetM α)
    : WidgetM (α × ScrollContainerResult) :=
  scrollContainer (ScrollContainerConfig.horizontal width) children

/-- ScrollView - a scrollable content area with visible scrollbars.
    This is the enhanced version of vscrollContainer with always-visible scrollbars.

    - `width`: Viewport width in pixels
    - `height`: Viewport height in pixels
    - `children`: Child widgets to render inside the scrollable area

    Returns a tuple of the children's result and scroll container result.

    Example:
    ```
    let (_, scrollResult) ← scrollView 300 200 do
      column' (gap := 4) (style := {}) do
        for i in [1:21] do
          bodyText' s!"Item {i}"
        pure ()
    ```
-/
def scrollView (width height : Float) (children : WidgetM α)
    : WidgetM (α × ScrollContainerResult) :=
  scrollContainer { width, height, scrollbarVisibility := .always } children

/-- Vertical scroll view (scrolls only vertically with visible scrollbar).
    - `height`: Viewport height in pixels
    - `children`: Child widgets
-/
def vscrollView (height : Float) (children : WidgetM α)
    : WidgetM (α × ScrollContainerResult) :=
  scrollContainer (ScrollContainerConfig.vertical height) children

/-- Horizontal scroll view (scrolls only horizontally with visible scrollbar).
    - `width`: Viewport width in pixels
    - `children`: Child widgets
-/
def hscrollView (width : Float) (children : WidgetM α)
    : WidgetM (α × ScrollContainerResult) :=
  scrollContainer (ScrollContainerConfig.horizontal width) children

/-- HTML-like document flow:
    children stack vertically, default to no grow/shrink, and overflow is scrollable. -/
def documentFlow (config : DocumentFlowConfig := {}) (children : WidgetM α)
    : WidgetM (α × ScrollContainerResult) := do
  let scrollConfig : ScrollContainerConfig := {
    width := config.width
    height := config.height
    verticalScroll := true
    horizontalScroll := false
    scrollSpeed := config.scrollSpeed
    scrollbarVisibility := config.scrollbarVisibility
    scrollbarThickness := config.scrollbarThickness
    scrollbarMinThumb := config.scrollbarMinThumb
    scrollbarRadius := config.scrollbarRadius
    fillHeight := config.fillHeight
    fillWidth := config.fillWidth
  }
  scrollContainer scrollConfig do
    let contentStyle : BoxStyle := {
      width := if config.fillWidth then .percent 1.0 else .auto
      padding := Trellis.EdgeInsets.uniform config.padding
    }
    staticColumn' (gap := config.gap) (style := contentStyle) children

end Afferent.Canopy
