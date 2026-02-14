/-
  Arbor Render Command Collector
  Convert widget trees + layouts into RenderCommand arrays.
  This is the key abstraction that makes rendering backend-independent.
-/
import Afferent.UI.Arbor.Widget.Core
import Afferent.UI.Arbor.Event.Scroll
import Trellis

namespace Afferent.Arbor

/-- Render command collector state. -/
structure CollectState where
  commands : Array RenderCommand := #[]
  /-- Deferred overlay widgets to render after normal flow. -/
  deferredOverlay : Array (Widget × Trellis.LayoutResult) := #[]
deriving Inhabited

/-- Collector monad for accumulating render commands. -/
abbrev CollectM := StateM CollectState

namespace CollectM

/-- Emit a single render command. -/
def emit (cmd : RenderCommand) : CollectM Unit := do
  modify fun s => { s with commands := s.commands.push cmd }

/-- Emit multiple render commands. -/
def emitAll (cmds : Array RenderCommand) : CollectM Unit := do
  modify fun s =>
    let commands := Id.run do
      let mut acc := s.commands
      for cmd in cmds do
        acc := acc.push cmd
      acc
    { s with commands := commands }

/-- Defer an overlay widget to render after normal flow. -/
def deferOverlay (w : Widget) (layouts : Trellis.LayoutResult) : CollectM Unit := do
  modify fun s => { s with deferredOverlay := s.deferredOverlay.push (w, layouts) }

/-- Run the collector and return the commands. -/
def execute {α : Type} (m : CollectM α) : Array RenderCommand :=
  (StateT.run m {}).2.commands

end CollectM

def isAbsoluteWidgetForRender (w : Widget) : Bool :=
  match w.style? with
  | some style => style.position == .absolute
  | none => false

def isOverlayWidgetForRender (w : Widget) : Bool :=
  match w.style? with
  | some style => style.position == .absolute && style.layer == .overlay
  | none => false

/-- Collect box background and border render commands based on BoxStyle. -/
def collectBoxStyle (rect : Trellis.LayoutRect) (style : BoxStyle) : CollectM Unit := do
  let r : Rect := ⟨⟨rect.x, rect.y⟩, ⟨rect.width, rect.height⟩⟩

  -- Background
  if let some bg := style.backgroundColor then
    CollectM.emit (.fillRect r bg style.cornerRadius)

  -- Border
  if let some bc := style.borderColor then
    if style.borderWidth > 0 then
      CollectM.emit (.strokeRect r bc style.borderWidth style.cornerRadius)

/-- Collect render commands for wrapped text with alignment.
    Text is vertically centered within the content rect.
    Baseline = top + verticalOffset + ascender (where verticalOffset centers the text block). -/
def collectWrappedText (contentRect : Trellis.LayoutRect) (font : FontId)
    (color : Color) (align : TextAlign) (textLayout : TextLayout) : CollectM Unit := do
  let lineHeight := textLayout.lineHeight
  let ascender := textLayout.ascender
  -- Vertical centering: offset to center the text block within the content rect
  let verticalOffset := (contentRect.height - textLayout.totalHeight) / 2
  -- First baseline: top of content + vertical offset + ascender
  let mut y := contentRect.y + verticalOffset + ascender

  for line in textLayout.lines do
    -- Calculate x based on alignment
    let x := match align with
      | .left => contentRect.x
      | .center => contentRect.x + (contentRect.width - line.width) / 2
      | .right => contentRect.x + contentRect.width - line.width

    CollectM.emit (.fillText line.text x y font color)
    y := y + lineHeight

/-- Collect render commands for single-line text (no wrapping).
    Text is vertically centered within the content rect. -/
def collectSingleLineText (contentRect : Trellis.LayoutRect) (text : String)
    (font : FontId) (color : Color) (align : TextAlign) (textWidth : Float)
    (lineHeight : Float) : CollectM Unit := do
  -- Calculate x based on alignment
  let x := match align with
    | .left => contentRect.x
    | .center => contentRect.x + (contentRect.width - textWidth) / 2
    | .right => contentRect.x + contentRect.width - textWidth

  -- Vertical centering with estimated ascender (0.8 * lineHeight)
  let ascender := lineHeight * 0.8
  let verticalOffset := (contentRect.height - lineHeight) / 2
  CollectM.emit (.fillText text x (contentRect.y + verticalOffset + ascender) font color)

/-- Collect render commands for a widget tree using computed layout positions.
    The widget should have been measured (text layouts computed) before calling this.
    Returns an array of RenderCommands that can be executed by any backend. -/
partial def collectWidget (w : Widget) (layouts : Trellis.LayoutResult) : CollectM Unit := do
  let some computed := layouts.get w.id | return
  let borderRect := computed.borderRect
  let contentRect := computed.contentRect

  match w with
  | .rect _ _ style _ =>
    collectBoxStyle borderRect style

  | .text _ _ content font color align _ textLayoutOpt _ =>
    match textLayoutOpt with
    | some textLayout =>
      collectWrappedText contentRect font color align textLayout
    | none =>
      -- Fallback to single-line rendering with estimated dimensions
      -- (this path shouldn't normally be hit if measureWidget was called)
      collectSingleLineText contentRect content font color align contentRect.width 16.0

  | .spacer _ _ _ _ _ =>
    -- Spacers don't render anything
    pure ()

  | .custom _ _ style _ _ =>
    collectBoxStyle borderRect style
    -- Legacy command collector cannot materialize immediate-mode custom draws.
    -- Runtime rendering executes custom specs directly via `Output.Execute.Render`.
    pure ()

  | .flex _ _ _ style children _ =>
    collectBoxStyle borderRect style
    -- Fast path for common static-flow UIs: avoid allocating a flow array.
    let mut absChildren : Array Widget := #[]
    let mut overlayChildren : Array Widget := #[]
    for child in children do
      if isOverlayWidgetForRender child then
        overlayChildren := overlayChildren.push child
      else if isAbsoluteWidgetForRender child then
        absChildren := absChildren.push child
      else
        collectWidget child layouts
    for child in absChildren do
      collectWidget child layouts
    for child in overlayChildren do
      CollectM.deferOverlay child layouts

  | .grid _ _ _ style children _ =>
    collectBoxStyle borderRect style
    -- Same optimization as flex: process flow children immediately.
    let mut absChildren : Array Widget := #[]
    let mut overlayChildren : Array Widget := #[]
    for child in children do
      if isOverlayWidgetForRender child then
        overlayChildren := overlayChildren.push child
      else if isAbsoluteWidgetForRender child then
        absChildren := absChildren.push child
      else
        collectWidget child layouts
    for child in absChildren do
      collectWidget child layouts
    for child in overlayChildren do
      CollectM.deferOverlay child layouts

  | .scroll _ _ style scrollState contentWidth contentHeight scrollbarConfig child _ =>
    -- Render background
    collectBoxStyle borderRect style
    let viewportW := contentRect.width
    let viewportH := contentRect.height
    let effectiveScroll := scrollState.clamp viewportW viewportH contentWidth contentHeight

    -- Set up clipping to content area
    let clipRect : Rect := ⟨⟨contentRect.x, contentRect.y⟩, ⟨contentRect.width, contentRect.height⟩⟩
    CollectM.emit (.pushClip clipRect)

    -- Save state and apply scroll offset
    CollectM.emit .save
    CollectM.emit (.pushTranslate (-effectiveScroll.offsetX) (-effectiveScroll.offsetY))

    -- Render child
    collectWidget child layouts

    -- Restore state
    CollectM.emit .popTransform
    CollectM.emit .restore
    CollectM.emit .popClip

    -- Render scrollbars (after content, so they overlay)
    let thickness := scrollbarConfig.thickness
    let minThumb := scrollbarConfig.minThumbLength
    let radius := scrollbarConfig.cornerRadius

    -- Vertical scrollbar
    if scrollbarConfig.showVertical && contentHeight > viewportH then
      -- Calculate scrollable range
      let maxScrollY := contentHeight - viewportH
      let scrollRatio := if maxScrollY > 0 then effectiveScroll.offsetY / maxScrollY else 0

      -- Calculate thumb size (proportional to viewport/content ratio)
      let thumbRatio := viewportH / contentHeight
      let thumbHeight := max minThumb (viewportH * thumbRatio)
      let trackHeight := viewportH
      let thumbTravel := trackHeight - thumbHeight
      let thumbY := thumbTravel * scrollRatio

      -- Track rect (right edge of content area)
      let trackX := contentRect.x + viewportW - thickness
      let trackRect : Rect := ⟨⟨trackX, contentRect.y⟩, ⟨thickness, trackHeight⟩⟩
      CollectM.emit (.fillRect trackRect scrollbarConfig.trackColor radius)

      -- Thumb rect
      let thumbRect : Rect := ⟨⟨trackX, contentRect.y + thumbY⟩, ⟨thickness, thumbHeight⟩⟩
      CollectM.emit (.fillRect thumbRect scrollbarConfig.thumbColor radius)

    -- Horizontal scrollbar
    if scrollbarConfig.showHorizontal && contentWidth > viewportW then
      -- Calculate scrollable range
      let maxScrollX := contentWidth - viewportW
      let scrollRatio := if maxScrollX > 0 then effectiveScroll.offsetX / maxScrollX else 0

      -- Calculate thumb size (proportional to viewport/content ratio)
      let thumbRatio := viewportW / contentWidth
      let thumbWidth := max minThumb (viewportW * thumbRatio)
      let trackWidth := viewportW
      let thumbTravel := trackWidth - thumbWidth
      let thumbX := thumbTravel * scrollRatio

      -- Track rect (bottom edge of content area)
      let trackY := contentRect.y + viewportH - thickness
      let trackRect : Rect := ⟨⟨contentRect.x, trackY⟩, ⟨trackWidth, thickness⟩⟩
      CollectM.emit (.fillRect trackRect scrollbarConfig.trackColor radius)

      -- Thumb rect
      let thumbRect : Rect := ⟨⟨contentRect.x + thumbX, trackY⟩, ⟨thumbWidth, thickness⟩⟩
      CollectM.emit (.fillRect thumbRect scrollbarConfig.thumbColor radius)

/-- Render all deferred overlay widgets.
    Called after the main tree traversal to ensure they render on top. -/
partial def renderDeferredOverlay : CollectM Unit := do
  let state ← get
  -- Clear the deferred list before processing (in case rendering adds more)
  set { state with deferredOverlay := #[] }
  for (widget, layouts) in state.deferredOverlay do
    collectWidget widget layouts
  -- Check if any new overlay elements were deferred during rendering
  let newState ← get
  if newState.deferredOverlay.size > 0 then
    renderDeferredOverlay

/-- Collect render commands for a widget tree.
    This is the main entry point for converting a widget tree to render commands.
    Overlay elements are rendered after all normal flow content. -/
def collectCommands (w : Widget) (layouts : Trellis.LayoutResult) : Array RenderCommand :=
  CollectM.execute do
    collectWidget w layouts
    renderDeferredOverlay

end Afferent.Arbor
