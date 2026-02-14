/-
  Afferent Widget Backend Arbor Rendering
  Immediate widget rendering pipeline.
-/
import Afferent.Output.Canvas
import Afferent.Graphics.Text.Font
import Afferent.Graphics.Text.Measurer
import Afferent.UI.Arbor

namespace Afferent.Widget

open Afferent
open Afferent.Arbor

/-- Execution statistics for direct widget rendering. -/
structure DrawStats where
  drawCalls : Nat := 0
  deriving Repr, Inhabited

private structure PreparedRender where
  measuredWidget : Afferent.Arbor.Widget
  layouts : Trellis.LayoutResult
  offsetX : Float := 0.0
  offsetY : Float := 0.0

structure ArborRenderStats where
  draw : DrawStats := {}
  timeCollectMs : Float := 0.0
  timeExecuteMs : Float := 0.0
  timeCustomMs : Float := 0.0
deriving Repr, Inhabited

private structure DrawState where
  deferredOverlay : Array (Afferent.Arbor.Widget × Trellis.LayoutResult) := #[]
deriving Inhabited

private abbrev DrawM := StateT DrawState CanvasM

private def DrawM.liftCanvas {α : Type} (m : CanvasM α) : DrawM α :=
  StateT.lift m

namespace DrawM

def deferOverlay (w : Afferent.Arbor.Widget) (layouts : Trellis.LayoutResult) : DrawM Unit := do
  modify fun s => { s with deferredOverlay := s.deferredOverlay.push (w, layouts) }

end DrawM

private def isAbsoluteWidgetForRender (w : Afferent.Arbor.Widget) : Bool :=
  match w.style? with
  | some style => style.position == .absolute
  | none => false

private def isOverlayWidgetForRender (w : Afferent.Arbor.Widget) : Bool :=
  match w.style? with
  | some style => style.position == .absolute && style.layer == .overlay
  | none => false

private def drawBoxStyle (rect : Trellis.LayoutRect) (style : BoxStyle) : DrawM Unit := do
  let r : Rect := ⟨⟨rect.x, rect.y⟩, ⟨rect.width, rect.height⟩⟩
  if let some bg := style.backgroundColor then
    DrawM.liftCanvas (CanvasM.fillRectColor r bg style.cornerRadius)
  if let some bc := style.borderColor then
    if style.borderWidth > 0 then
      DrawM.liftCanvas (CanvasM.strokeRectColor r bc style.borderWidth style.cornerRadius)

private def drawWrappedText (contentRect : Trellis.LayoutRect) (font : FontId)
    (color : Color) (align : TextAlign) (textLayout : TextLayout) : DrawM Unit := do
  let lineHeight := textLayout.lineHeight
  let ascender := textLayout.ascender
  let verticalOffset := (contentRect.height - textLayout.totalHeight) / 2
  let mut y := contentRect.y + verticalOffset + ascender

  for line in textLayout.lines do
    let x := match align with
      | .left => contentRect.x
      | .center => contentRect.x + (contentRect.width - line.width) / 2
      | .right => contentRect.x + contentRect.width - line.width
    DrawM.liftCanvas (CanvasM.fillTextId line.text x y font color)
    y := y + lineHeight

private def drawSingleLineText (contentRect : Trellis.LayoutRect) (text : String)
    (font : FontId) (color : Color) (align : TextAlign) (textWidth : Float)
    (lineHeight : Float) : DrawM Unit := do
  let x := match align with
    | .left => contentRect.x
    | .center => contentRect.x + (contentRect.width - textWidth) / 2
    | .right => contentRect.x + contentRect.width - textWidth
  let ascender := lineHeight * 0.8
  let verticalOffset := (contentRect.height - lineHeight) / 2
  DrawM.liftCanvas (CanvasM.fillTextId text x (contentRect.y + verticalOffset + ascender) font color)

partial def drawWidget (w : Afferent.Arbor.Widget) (layouts : Trellis.LayoutResult) : DrawM Unit := do
  let some computed := layouts.get w.id | return
  let borderRect := computed.borderRect
  let contentRect := computed.contentRect

  match w with
  | .rect _ _ style _ =>
    drawBoxStyle borderRect style

  | .text _ _ content font color align _ textLayoutOpt _ =>
    match textLayoutOpt with
    | some textLayout =>
      drawWrappedText contentRect font color align textLayout
    | none =>
      drawSingleLineText contentRect content font color align contentRect.width 16.0

  | .spacer .. =>
    pure ()

  | .custom _ _ style spec _ =>
    drawBoxStyle borderRect style
    DrawM.liftCanvas (spec.collect computed)

  | .flex _ _ _ style children _ =>
    drawBoxStyle borderRect style
    let mut absChildren : Array Afferent.Arbor.Widget := #[]
    let mut overlayChildren : Array Afferent.Arbor.Widget := #[]
    for child in children do
      if isOverlayWidgetForRender child then
        overlayChildren := overlayChildren.push child
      else if isAbsoluteWidgetForRender child then
        absChildren := absChildren.push child
      else
        drawWidget child layouts
    for child in absChildren do
      drawWidget child layouts
    for child in overlayChildren do
      DrawM.deferOverlay child layouts

  | .grid _ _ _ style children _ =>
    drawBoxStyle borderRect style
    let mut absChildren : Array Afferent.Arbor.Widget := #[]
    let mut overlayChildren : Array Afferent.Arbor.Widget := #[]
    for child in children do
      if isOverlayWidgetForRender child then
        overlayChildren := overlayChildren.push child
      else if isAbsoluteWidgetForRender child then
        absChildren := absChildren.push child
      else
        drawWidget child layouts
    for child in absChildren do
      drawWidget child layouts
    for child in overlayChildren do
      DrawM.deferOverlay child layouts

  | .scroll _ _ style scrollState contentWidth contentHeight scrollbarConfig child _ =>
    drawBoxStyle borderRect style
    let viewportW := contentRect.width
    let viewportH := contentRect.height
    let effectiveScroll := scrollState.clamp viewportW viewportH contentWidth contentHeight

    let clipRect : Rect := ⟨⟨contentRect.x, contentRect.y⟩, ⟨contentRect.width, contentRect.height⟩⟩
    DrawM.liftCanvas (CanvasM.pushClip clipRect)
    DrawM.liftCanvas CanvasM.save
    DrawM.liftCanvas (CanvasM.pushTranslate (-effectiveScroll.offsetX) (-effectiveScroll.offsetY))
    drawWidget child layouts
    DrawM.liftCanvas CanvasM.popTransform
    DrawM.liftCanvas CanvasM.restore
    DrawM.liftCanvas CanvasM.popClip

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
      DrawM.liftCanvas (CanvasM.fillRectColor trackRect scrollbarConfig.trackColor radius)
      let thumbRect : Rect := ⟨⟨trackX, contentRect.y + thumbY⟩, ⟨thickness, thumbHeight⟩⟩
      DrawM.liftCanvas (CanvasM.fillRectColor thumbRect scrollbarConfig.thumbColor radius)

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
      DrawM.liftCanvas (CanvasM.fillRectColor trackRect scrollbarConfig.trackColor radius)
      let thumbRect : Rect := ⟨⟨contentRect.x + thumbX, trackY⟩, ⟨thumbWidth, thickness⟩⟩
      DrawM.liftCanvas (CanvasM.fillRectColor thumbRect scrollbarConfig.thumbColor radius)

partial def drawDeferredOverlay : DrawM Unit := do
  let state ← get
  set { state with deferredOverlay := #[] }
  for (widget, layouts) in state.deferredOverlay do
    drawWidget widget layouts
  let newState ← get
  if newState.deferredOverlay.size > 0 then
    drawDeferredOverlay

private def drawWidgetTree (w : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) : CanvasM Unit := do
  let _ ← ((do
    drawWidget w layouts
    drawDeferredOverlay).run ({ deferredOverlay := #[] } : DrawState))
  pure ()

private def prepareRender (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) : CanvasM PreparedRender := do
  let measureResult ← runWithFonts reg (Afferent.Arbor.measureWidget widget availWidth availHeight)
  let layouts := Trellis.layout measureResult.node availWidth availHeight
  pure {
    measuredWidget := measureResult.widget
    layouts
  }

/-- Run an action under a temporary translation offset. -/
private def withOffset (offsetX offsetY : Float) (action : CanvasM α) : CanvasM α := do
  if offsetX == 0.0 && offsetY == 0.0 then
    action
  else
    CanvasM.save
    CanvasM.translate offsetX offsetY
    let result ← action
    CanvasM.restore
    pure result

private def drawWithOffset (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) (offsetX offsetY : Float) : CanvasM Unit := do
  withOffset offsetX offsetY (drawWidgetTree measuredWidget layouts)

private def drawWithOffsetAndStats (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) (offsetX offsetY : Float) : CanvasM (DrawStats × Float) := do
  let t0 ← IO.monoNanosNow
  withOffset offsetX offsetY (drawWidgetTree measuredWidget layouts)
  let t1 ← IO.monoNanosNow
  pure ({}, (t1 - t0).toFloat / 1000000.0)

/-- Render an already measured Arbor widget tree using a precomputed layout result.
    This avoids redundant measure/layout passes when a caller already has layout data
    (for example: event dispatch and rendering in the same frame). -/
def renderMeasuredArborWidget (reg : FontRegistry) (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) (offsetX : Float := 0.0) (offsetY : Float := 0.0) : CanvasM Unit := do
  CanvasM.setFontRegistry reg
  drawWithOffset measuredWidget layouts offsetX offsetY

/-- Render an Arbor widget tree using CanvasM.
    This is the single entry point for rendering Arbor widgets with Afferent's Metal backend. -/
def renderArborWidget (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) : CanvasM ArborRenderStats := do
  let prepared ← prepareRender reg widget availWidth availHeight
  CanvasM.setFontRegistry reg
  let (drawStats, timeExecuteMs) ←
    drawWithOffsetAndStats prepared.measuredWidget prepared.layouts prepared.offsetX prepared.offsetY
  pure {
    draw := drawStats
    timeCollectMs := 0.0
    timeExecuteMs
    timeCustomMs := 0.0
  }

end Afferent.Widget
