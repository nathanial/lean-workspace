/-
  Arbor Render Command Collector
  Convert widget trees + layouts into RenderCommand streams.
-/
import Afferent.UI.Arbor.Widget.Core
import Afferent.UI.Arbor.Event.Scroll
import Trellis

namespace Afferent.Arbor

abbrev OverlayQueue := Array (Widget × Trellis.LayoutResult)
abbrev CollectFoldM (m : Type → Type) := StateT OverlayQueue m

private def foldLift [Monad m] (action : m α) : CollectFoldM m α := fun q => do
  let a ← action
  pure (a, q)

def isAbsoluteWidgetForRender (w : Widget) : Bool :=
  match w.style? with
  | some style => style.position == .absolute
  | none => false

def isOverlayWidgetForRender (w : Widget) : Bool :=
  match w.style? with
  | some style => style.position == .absolute && style.layer == .overlay
  | none => false

private def emitMany [Monad m] (emit : RenderCommand → m Unit) (cmds : Array RenderCommand) : m Unit := do
  for cmd in cmds do
    emit cmd

/-- Emit box background and border render commands based on BoxStyle. -/
private def emitBoxStyle [Monad m]
    (emit : RenderCommand → m Unit) (rect : Trellis.LayoutRect) (style : BoxStyle) : m Unit := do
  let r : Rect := ⟨⟨rect.x, rect.y⟩, ⟨rect.width, rect.height⟩⟩

  if let some bg := style.backgroundColor then
    emit (.fillRect r bg style.cornerRadius)

  if let some bc := style.borderColor then
    if style.borderWidth > 0 then
      emit (.strokeRect r bc style.borderWidth style.cornerRadius)

/-- Emit render commands for wrapped text with alignment.
    Text is vertically centered within the content rect.
    Baseline = top + verticalOffset + ascender (where verticalOffset centers the text block). -/
private def emitWrappedText [Monad m]
    (emit : RenderCommand → m Unit)
    (contentRect : Trellis.LayoutRect) (font : FontId)
    (color : Color) (align : TextAlign) (textLayout : TextLayout) : m Unit := do
  let lineHeight := textLayout.lineHeight
  let ascender := textLayout.ascender
  let verticalOffset := (contentRect.height - textLayout.totalHeight) / 2
  let mut y := contentRect.y + verticalOffset + ascender

  for line in textLayout.lines do
    let x := match align with
      | .left => contentRect.x
      | .center => contentRect.x + (contentRect.width - line.width) / 2
      | .right => contentRect.x + contentRect.width - line.width

    emit (.fillText line.text x y font color)
    y := y + lineHeight

/-- Emit render commands for single-line text (no wrapping).
    Text is vertically centered within the content rect. -/
private def emitSingleLineText [Monad m]
    (emit : RenderCommand → m Unit)
    (contentRect : Trellis.LayoutRect) (text : String)
    (font : FontId) (color : Color) (align : TextAlign) (textWidth : Float)
    (lineHeight : Float) : m Unit := do
  let x := match align with
    | .left => contentRect.x
    | .center => contentRect.x + (contentRect.width - textWidth) / 2
    | .right => contentRect.x + contentRect.width - textWidth

  let ascender := lineHeight * 0.8
  let verticalOffset := (contentRect.height - lineHeight) / 2
  emit (.fillText text x (contentRect.y + verticalOffset + ascender) font color)

private def deferOverlay [Monad m]
    (w : Widget) (layouts : Trellis.LayoutResult) : CollectFoldM m Unit := do
  modify (fun q => q.push (w, layouts))

partial def collectWidgetFoldM [Monad m]
    (emit : RenderCommand → m Unit)
    (w : Widget)
    (layouts : Trellis.LayoutResult)
    : CollectFoldM m Unit := do
  let some computed := layouts.get w.id | return
  let borderRect := computed.borderRect
  let contentRect := computed.contentRect

  match w with
  | .rect _ _ style _ =>
    foldLift (emitBoxStyle emit borderRect style)

  | .text _ _ content font color align _ textLayoutOpt _ =>
    match textLayoutOpt with
    | some textLayout =>
      foldLift (emitWrappedText emit contentRect font color align textLayout)
    | none =>
      foldLift (emitSingleLineText emit contentRect content font color align contentRect.width 16.0)

  | .spacer _ _ _ _ _ =>
    pure ()

  | .custom _ _ style spec _ =>
    foldLift (emitBoxStyle emit borderRect style)
    foldLift (emitMany emit (spec.collect computed))

  | .flex _ _ _ style children _ =>
    foldLift (emitBoxStyle emit borderRect style)
    let mut absChildren : Array Widget := #[]
    let mut overlayChildren : Array Widget := #[]
    for child in children do
      if isOverlayWidgetForRender child then
        overlayChildren := overlayChildren.push child
      else if isAbsoluteWidgetForRender child then
        absChildren := absChildren.push child
      else
        collectWidgetFoldM emit child layouts
    for child in absChildren do
      collectWidgetFoldM emit child layouts
    for child in overlayChildren do
      deferOverlay child layouts

  | .grid _ _ _ style children _ =>
    foldLift (emitBoxStyle emit borderRect style)
    let mut absChildren : Array Widget := #[]
    let mut overlayChildren : Array Widget := #[]
    for child in children do
      if isOverlayWidgetForRender child then
        overlayChildren := overlayChildren.push child
      else if isAbsoluteWidgetForRender child then
        absChildren := absChildren.push child
      else
        collectWidgetFoldM emit child layouts
    for child in absChildren do
      collectWidgetFoldM emit child layouts
    for child in overlayChildren do
      deferOverlay child layouts

  | .scroll _ _ style scrollState contentWidth contentHeight scrollbarConfig child _ =>
    foldLift (emitBoxStyle emit borderRect style)
    let viewportW := contentRect.width
    let viewportH := contentRect.height
    let effectiveScroll := scrollState.clamp viewportW viewportH contentWidth contentHeight

    let clipRect : Rect := ⟨⟨contentRect.x, contentRect.y⟩, ⟨contentRect.width, contentRect.height⟩⟩
    foldLift (emit (.pushClip clipRect))

    foldLift (emit .save)
    foldLift (emit (.pushTranslate (-effectiveScroll.offsetX) (-effectiveScroll.offsetY)))

    collectWidgetFoldM emit child layouts

    foldLift (emit .popTransform)
    foldLift (emit .restore)
    foldLift (emit .popClip)

    let thickness := scrollbarConfig.thickness
    let minThumb := scrollbarConfig.minThumbLength
    let radius := scrollbarConfig.cornerRadius

    if scrollbarConfig.showVertical && contentHeight > viewportH then
      let maxScrollY := contentHeight - viewportH
      let scrollRatio := if maxScrollY > 0 then effectiveScroll.offsetY / maxScrollY else 0

      let thumbRatio := viewportH / contentHeight
      let thumbHeight := max minThumb (viewportH * thumbRatio)
      let trackHeight := viewportH
      let thumbTravel := trackHeight - thumbHeight
      let thumbY := thumbTravel * scrollRatio

      let trackX := contentRect.x + viewportW - thickness
      let trackRect : Rect := ⟨⟨trackX, contentRect.y⟩, ⟨thickness, trackHeight⟩⟩
      foldLift (emit (.fillRect trackRect scrollbarConfig.trackColor radius))

      let thumbRect : Rect := ⟨⟨trackX, contentRect.y + thumbY⟩, ⟨thickness, thumbHeight⟩⟩
      foldLift (emit (.fillRect thumbRect scrollbarConfig.thumbColor radius))

    if scrollbarConfig.showHorizontal && contentWidth > viewportW then
      let maxScrollX := contentWidth - viewportW
      let scrollRatio := if maxScrollX > 0 then effectiveScroll.offsetX / maxScrollX else 0

      let thumbRatio := viewportW / contentWidth
      let thumbWidth := max minThumb (viewportW * thumbRatio)
      let trackWidth := viewportW
      let thumbTravel := trackWidth - thumbWidth
      let thumbX := thumbTravel * scrollRatio

      let trackY := contentRect.y + viewportH - thickness
      let trackRect : Rect := ⟨⟨contentRect.x, trackY⟩, ⟨trackWidth, thickness⟩⟩
      foldLift (emit (.fillRect trackRect scrollbarConfig.trackColor radius))

      let thumbRect : Rect := ⟨⟨contentRect.x + thumbX, trackY⟩, ⟨thumbWidth, thickness⟩⟩
      foldLift (emit (.fillRect thumbRect scrollbarConfig.thumbColor radius))

partial def drainDeferredOverlays [Monad m]
    (emit : RenderCommand → m Unit) : CollectFoldM m Unit := do
  let deferred ← get
  set (#[ ] : OverlayQueue)
  for (widget, layouts) in deferred do
    collectWidgetFoldM emit widget layouts
  let next ← get
  if next.size > 0 then
    drainDeferredOverlays emit

/-- Stream all render commands for a widget tree to an effectful consumer. -/
def collectCommandsFoldM [Monad m]
    (w : Widget)
    (layouts : Trellis.LayoutResult)
    (emit : RenderCommand → m Unit) : m Unit := do
  let action : CollectFoldM m Unit := do
    collectWidgetFoldM emit w layouts
    drainDeferredOverlays emit
  let _ ← action.run (#[ ] : OverlayQueue)
  pure ()

/-- Collect render commands for a widget tree.
    This is the main entry point for converting a widget tree to render commands.
    Overlay elements are rendered after all normal flow content. -/
def collectCommands (w : Widget) (layouts : Trellis.LayoutResult) : Array RenderCommand :=
  ((collectCommandsFoldM (m := StateM (Array RenderCommand)) w layouts
      (fun cmd => modify (fun acc => acc.push cmd))).run #[]).2

end Afferent.Arbor
