/-
  Arbor Render Command Collector
  Convert widget trees + layouts into RenderCommand arrays.
  This is the key abstraction that makes rendering backend-independent.
-/
import Afferent.UI.Arbor.Widget.Core
import Afferent.UI.Arbor.Event.Scroll
import Afferent.Draw.Cache
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

/-- Separate children into flow, absolute (in-flow), and overlay (deferred) buckets. -/
def partitionChildren (children : Array Widget)
    : (Array Widget × Array Widget × Array Widget) := Id.run do
  let mut flow : Array Widget := #[]
  let mut abs : Array Widget := #[]
  let mut overlay : Array Widget := #[]
  for child in children do
    if isOverlayWidgetForRender child then
      overlay := overlay.push child
    else if isAbsoluteWidgetForRender child then
      abs := abs.push child
    else
      flow := flow.push child
  (flow, abs, overlay)

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

  | .custom _ _ style spec _ =>
    collectBoxStyle borderRect style
    CollectM.emitAll (spec.collect computed)

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

/-- Collect render commands with an initial save/restore wrapper. -/
def collectCommandsWithSave (w : Widget) (layouts : Trellis.LayoutResult) : Array RenderCommand :=
  CollectM.execute do
    CollectM.emit .save
    collectWidget w layouts
    renderDeferredOverlay
    CollectM.emit .restore

/-! ## Cached Collection

These functions provide render command caching at the widget level.
Cache is keyed by a path-derived key + layout hash. Each widget gets a unique
path key based on its position in the tree, which provides automatic caching
for all CustomSpec widgets without requiring explicit names.

When data changes, dynWidget rebuilds a subtree, and the paths within that
subtree naturally change, causing cache misses for the updated widgets. -/

/-- Optional collect instrumentation for cache and emit costs. -/
structure CollectMetrics where
  lookupNanos : IO.Ref Nat
  lookupCount : IO.Ref Nat
  touchNanos : IO.Ref Nat
  touchCount : IO.Ref Nat
  collectNanos : IO.Ref Nat
  collectCount : IO.Ref Nat
  insertNanos : IO.Ref Nat
  insertCount : IO.Ref Nat
  emitAllNanos : IO.Ref Nat
  emitAllCount : IO.Ref Nat

structure CollectMetricsSnapshot where
  lookupNanos : Nat
  lookupCount : Nat
  touchNanos : Nat
  touchCount : Nat
  collectNanos : Nat
  collectCount : Nat
  insertNanos : Nat
  insertCount : Nat
  emitAllNanos : Nat
  emitAllCount : Nat
deriving Repr, Inhabited

def CollectMetrics.new : IO CollectMetrics := do
  pure {
    lookupNanos := (← IO.mkRef 0)
    lookupCount := (← IO.mkRef 0)
    touchNanos := (← IO.mkRef 0)
    touchCount := (← IO.mkRef 0)
    collectNanos := (← IO.mkRef 0)
    collectCount := (← IO.mkRef 0)
    insertNanos := (← IO.mkRef 0)
    insertCount := (← IO.mkRef 0)
    emitAllNanos := (← IO.mkRef 0)
    emitAllCount := (← IO.mkRef 0)
  }

def CollectMetrics.reset (m : CollectMetrics) : IO Unit := do
  m.lookupNanos.set 0
  m.lookupCount.set 0
  m.touchNanos.set 0
  m.touchCount.set 0
  m.collectNanos.set 0
  m.collectCount.set 0
  m.insertNanos.set 0
  m.insertCount.set 0
  m.emitAllNanos.set 0
  m.emitAllCount.set 0

def CollectMetrics.snapshot (m : CollectMetrics) : IO CollectMetricsSnapshot := do
  pure {
    lookupNanos := (← m.lookupNanos.get)
    lookupCount := (← m.lookupCount.get)
    touchNanos := (← m.touchNanos.get)
    touchCount := (← m.touchCount.get)
    collectNanos := (← m.collectNanos.get)
    collectCount := (← m.collectCount.get)
    insertNanos := (← m.insertNanos.get)
    insertCount := (← m.insertCount.get)
    emitAllNanos := (← m.emitAllNanos.get)
    emitAllCount := (← m.emitAllCount.get)
  }

initialize collectMetricsRef : IO.Ref (Option CollectMetrics) ← IO.mkRef none

def enableCollectMetrics : IO CollectMetrics := do
  let metrics ← CollectMetrics.new
  collectMetricsRef.set (some metrics)
  pure metrics

def disableCollectMetrics : IO Unit :=
  collectMetricsRef.set none

def getCollectMetrics : IO (Option CollectMetrics) :=
  collectMetricsRef.get

/-- Cached collector state with access to the render cache. -/
structure CachedCollectState where
  sink : RenderCommandSink := RenderCommandSink.ofEmit (fun _ => pure ())
  /-- Deferred overlay widgets with their path keys for cache key generation. -/
  deferredOverlay : Array (Widget × Trellis.LayoutResult × CacheKey) := #[]
  cacheHits : Nat := 0
  cacheMisses : Nat := 0
  metrics : Option CollectMetrics := none
  /-- Enable LRU touch updates only after a miss occurs in this collection pass. -/
  touchEnabled : Bool := false
deriving Inhabited

/-- Cached collector monad with IO for cache access. -/
abbrev CachedCollectM := StateT CachedCollectState IO

namespace CachedCollectM

def emit (cmd : RenderCommand) : CachedCollectM Unit := do
  let sink := (← get).sink
  sink.emit cmd

def emitFillRect (rect : Rect) (color : Color) (cornerRadius : Float := 0.0) : CachedCollectM Unit := do
  let sink := (← get).sink
  sink.emitFillRect rect color cornerRadius

def emitStrokeRect (rect : Rect) (color : Color) (lineWidth : Float)
    (cornerRadius : Float := 0.0) : CachedCollectM Unit := do
  let sink := (← get).sink
  sink.emitStrokeRect rect color lineWidth cornerRadius

def emitFillText (text : String) (x y : Float) (font : FontId) (color : Color) : CachedCollectM Unit := do
  let sink := (← get).sink
  sink.emitFillText text x y font color

def emitPushClip (rect : Rect) : CachedCollectM Unit := do
  let sink := (← get).sink
  sink.emitPushClip rect

def emitPopClip : CachedCollectM Unit := do
  let sink := (← get).sink
  sink.emitPopClip

def emitSave : CachedCollectM Unit := do
  let sink := (← get).sink
  sink.emitSave

def emitRestore : CachedCollectM Unit := do
  let sink := (← get).sink
  sink.emitRestore

def emitPushTranslate (dx dy : Float) : CachedCollectM Unit := do
  let sink := (← get).sink
  sink.emitPushTranslate dx dy

def emitPopTransform : CachedCollectM Unit := do
  let sink := (← get).sink
  sink.emitPopTransform

def emitAll (cmds : Array RenderCommand) : CachedCollectM Unit := do
  let state ← get
  let metricsOpt := state.metrics
  let sink := state.sink
  let append : CachedCollectM Unit :=
    sink.emitAll cmds
  match metricsOpt with
  | none =>
      append
  | some metrics =>
      let t0 ← IO.monoNanosNow
      append
      let t1 ← IO.monoNanosNow
      metrics.emitAllNanos.modify (· + (t1 - t0))
      metrics.emitAllCount.modify (· + 1)

def deferOverlay (w : Widget) (layouts : Trellis.LayoutResult) (pathKey : CacheKey) : CachedCollectM Unit := do
  modify fun s => { s with deferredOverlay := s.deferredOverlay.push (w, layouts, pathKey) }

def recordCacheHit : CachedCollectM Unit := do
  modify fun s => { s with cacheHits := s.cacheHits + 1 }

def recordCacheMiss : CachedCollectM Unit := do
  modify fun s => { s with cacheMisses := s.cacheMisses + 1 }

end CachedCollectM

private def appendCommandsRef (ref : IO.Ref (Array RenderCommand))
    (cmds : Array RenderCommand) : IO Unit := do
  ref.modify fun acc => Id.run do
    let mut out := acc
    for cmd in cmds do
      out := out.push cmd
    out

private def teeRenderCommandSink (recordRef : IO.Ref (Array RenderCommand))
    (base : RenderCommandSink) : RenderCommandSink :=
  { emit := fun cmd => do
      recordRef.modify (·.push cmd)
      base.emit cmd
    emitAll := fun cmds => do
      if !cmds.isEmpty then
        appendCommandsRef recordRef cmds
      base.emitAll cmds
    emitFillRect? := some (fun rect color cornerRadius => do
      recordRef.modify (·.push (.fillRect rect color cornerRadius))
      base.emitFillRect rect color cornerRadius)
    emitStrokeRect? := some (fun rect color lineWidth cornerRadius => do
      recordRef.modify (·.push (.strokeRect rect color lineWidth cornerRadius))
      base.emitStrokeRect rect color lineWidth cornerRadius)
    emitFillText? := some (fun text x y font color => do
      recordRef.modify (·.push (.fillText text x y font color))
      base.emitFillText text x y font color)
    emitPushClip? := some (fun rect => do
      recordRef.modify (·.push (.pushClip rect))
      base.emitPushClip rect)
    emitPopClip? := some (do
      recordRef.modify (·.push .popClip)
      base.emitPopClip)
    emitSave? := some (do
      recordRef.modify (·.push .save)
      base.emitSave)
    emitRestore? := some (do
      recordRef.modify (·.push .restore)
      base.emitRestore)
    emitPushTranslate? := some (fun dx dy => do
      recordRef.modify (·.push (.pushTranslate dx dy))
      base.emitPushTranslate dx dy)
    emitPopTransform? := some (do
      recordRef.modify (·.push .popTransform)
      base.emitPopTransform) }

private def collectCustomSpecIntoSink (spec : CustomSpec)
    (computed : Trellis.ComputedLayout) (sink : RenderCommandSink) : IO Unit := do
  match spec.collectInto? with
  | some collectInto => collectInto computed sink
  | none => sink.emitAll (spec.collect computed)

private def collectCustomSpecIntoCacheAndSink (spec : CustomSpec)
    (computed : Trellis.ComputedLayout) (sink : RenderCommandSink) : IO (Array RenderCommand) := do
  match spec.collectInto? with
  | none =>
    let cmds := spec.collect computed
    sink.emitAll cmds
    pure cmds
  | some collectInto => do
    let cmdsRef ← IO.mkRef (#[] : Array RenderCommand)
    collectInto computed (teeRenderCommandSink cmdsRef sink)
    cmdsRef.get

/-- Collect box background and border render commands (cached version). -/
def collectBoxStyleCached (rect : Trellis.LayoutRect) (style : BoxStyle) : CachedCollectM Unit := do
  let r : Rect := ⟨⟨rect.x, rect.y⟩, ⟨rect.width, rect.height⟩⟩
  if let some bg := style.backgroundColor then
    CachedCollectM.emitFillRect r bg style.cornerRadius
  if let some bc := style.borderColor then
    if style.borderWidth > 0 then
      CachedCollectM.emitStrokeRect r bc style.borderWidth style.cornerRadius

/-- Collect wrapped text (cached version). -/
def collectWrappedTextCached (contentRect : Trellis.LayoutRect) (font : FontId)
    (color : Color) (align : TextAlign) (textLayout : TextLayout) : CachedCollectM Unit := do
  let lineHeight := textLayout.lineHeight
  let ascender := textLayout.ascender
  let verticalOffset := (contentRect.height - textLayout.totalHeight) / 2
  let mut y := contentRect.y + verticalOffset + ascender
  for line in textLayout.lines do
    let x := match align with
      | .left => contentRect.x
      | .center => contentRect.x + (contentRect.width - line.width) / 2
      | .right => contentRect.x + contentRect.width - line.width
    CachedCollectM.emitFillText line.text x y font color
    y := y + lineHeight

/-- Collect single-line text (cached version). -/
def collectSingleLineTextCached (contentRect : Trellis.LayoutRect) (text : String)
    (font : FontId) (color : Color) (align : TextAlign) (textWidth : Float)
    (lineHeight : Float) : CachedCollectM Unit := do
  let x := match align with
    | .left => contentRect.x
    | .center => contentRect.x + (contentRect.width - textWidth) / 2
    | .right => contentRect.x + contentRect.width - textWidth
  let ascender := lineHeight * 0.8
  let verticalOffset := (contentRect.height - lineHeight) / 2
  CachedCollectM.emitFillText text x (contentRect.y + verticalOffset + ascender) font color

/-- Collect render commands for a widget tree with caching support.
    All CustomSpec widgets are automatically cached using path keys derived
    from their position in the tree. -/
partial def collectWidgetCached (cache : IO.Ref RenderCache)
    (w : Widget) (layouts : Trellis.LayoutResult) (pathKey : CacheKey) : CachedCollectM Unit := do
  let some computed := layouts.get w.id | return
  let borderRect := computed.borderRect
  let contentRect := computed.contentRect

  match w with
  | .rect _ _ style _ =>
    collectBoxStyleCached borderRect style

  | .text _ _ content font color align _ textLayoutOpt _ =>
    match textLayoutOpt with
    | some textLayout =>
      collectWrappedTextCached contentRect font color align textLayout
    | none =>
      collectSingleLineTextCached contentRect content font color align contentRect.width 16.0

  | .spacer _ _ _ _ _ =>
    pure ()

  | .custom _ name style spec _ =>
    collectBoxStyleCached borderRect style
    let state ← get
    let metricsOpt := state.metrics
    let sink := state.sink

    -- Skip cache entirely for widgets that change every frame (e.g., spinners)
    if spec.skipCache then
      match metricsOpt with
      | none =>
        collectCustomSpecIntoSink spec computed sink
      | some metrics => do
        let t0 ← IO.monoNanosNow
        collectCustomSpecIntoSink spec computed sink
        let t1 ← IO.monoNanosNow
        metrics.collectNanos.modify (· + (t1 - t0))
        metrics.collectCount.modify (· + 1)
    else do
      let layoutHash := hashLayoutRect contentRect

      -- Cache key: widget name if provided, otherwise path key.
      -- We store generation in the cache entry itself, not in the key.
      -- This allows animated widgets to update in place (same key) rather than
      -- creating new entries each frame, preventing unbounded memory growth.
      let cacheKey := match name with
        | some widgetName => nameCacheKey widgetName
        | none => pathKey

      let renderCache ← cache.get
      let touchEnabled := state.touchEnabled
      let found ← match metricsOpt with
      | none =>
          pure (renderCache.find? cacheKey)
      | some metrics => do
          let t0 ← IO.monoNanosNow
          let result := renderCache.find? cacheKey
          let t1 ← IO.monoNanosNow
          metrics.lookupNanos.modify (· + (t1 - t0))
          metrics.lookupCount.modify (· + 1)
          pure result
      match found with
      | some cached =>
        -- Cache hit only if BOTH generation and layout match
        if cached.generation == spec.generation && cached.layoutHash == layoutHash then
          if touchEnabled then
            match metricsOpt with
            | none =>
                cache.modify fun rc => rc.touch cacheKey
            | some metrics => do
                let t0 ← IO.monoNanosNow
                cache.modify fun rc => rc.touch cacheKey
                let t1 ← IO.monoNanosNow
                metrics.touchNanos.modify (· + (t1 - t0))
                metrics.touchCount.modify (· + 1)
          CachedCollectM.emitAll cached.commands
          CachedCollectM.recordCacheHit
        else
          -- Generation or layout changed, recompute and update in place
          modify fun s => { s with touchEnabled := true }
          let cmds ← match metricsOpt with
          | none =>
              collectCustomSpecIntoCacheAndSink spec computed sink
          | some metrics => do
              let t0 ← IO.monoNanosNow
              let cmds ← collectCustomSpecIntoCacheAndSink spec computed sink
              let t1 ← IO.monoNanosNow
              metrics.collectNanos.modify (· + (t1 - t0))
              metrics.collectCount.modify (· + 1)
              pure cmds
          match metricsOpt with
          | none =>
              cache.modify fun rc => rc.insert cacheKey ⟨cmds, layoutHash, spec.generation⟩
          | some metrics => do
              let t0 ← IO.monoNanosNow
              cache.modify fun rc => rc.insert cacheKey ⟨cmds, layoutHash, spec.generation⟩
              let t1 ← IO.monoNanosNow
              metrics.insertNanos.modify (· + (t1 - t0))
              metrics.insertCount.modify (· + 1)
          CachedCollectM.recordCacheMiss
      | none =>
        -- First time seeing this widget, compute and cache
        modify fun s => { s with touchEnabled := true }
        let cmds ← match metricsOpt with
        | none =>
            collectCustomSpecIntoCacheAndSink spec computed sink
        | some metrics => do
            let t0 ← IO.monoNanosNow
            let cmds ← collectCustomSpecIntoCacheAndSink spec computed sink
            let t1 ← IO.monoNanosNow
            metrics.collectNanos.modify (· + (t1 - t0))
            metrics.collectCount.modify (· + 1)
            pure cmds
        match metricsOpt with
        | none =>
            cache.modify fun rc => rc.insert cacheKey ⟨cmds, layoutHash, spec.generation⟩
        | some metrics => do
            let t0 ← IO.monoNanosNow
            cache.modify fun rc => rc.insert cacheKey ⟨cmds, layoutHash, spec.generation⟩
            let t1 ← IO.monoNanosNow
            metrics.insertNanos.modify (· + (t1 - t0))
            metrics.insertCount.modify (· + 1)
        CachedCollectM.recordCacheMiss

  | .flex _ _ _ style children _ =>
    collectBoxStyleCached borderRect style
    let mut absChildren : Array Widget := #[]
    let mut overlayChildren : Array Widget := #[]
    let mut flowIdx := 0
    for child in children do
      if isOverlayWidgetForRender child then
        overlayChildren := overlayChildren.push child
      else if isAbsoluteWidgetForRender child then
        absChildren := absChildren.push child
      else
        collectWidgetCached cache child layouts (childPathKey pathKey flowIdx)
        flowIdx := flowIdx + 1
    let mut absIdx := flowIdx
    for child in absChildren do
      collectWidgetCached cache child layouts (childPathKey pathKey absIdx)
      absIdx := absIdx + 1
    let mut overlayIdx := absIdx
    for child in overlayChildren do
      CachedCollectM.deferOverlay child layouts (childPathKey pathKey overlayIdx)
      overlayIdx := overlayIdx + 1

  | .grid _ _ _ style children _ =>
    collectBoxStyleCached borderRect style
    let mut absChildren : Array Widget := #[]
    let mut overlayChildren : Array Widget := #[]
    let mut flowIdx := 0
    for child in children do
      if isOverlayWidgetForRender child then
        overlayChildren := overlayChildren.push child
      else if isAbsoluteWidgetForRender child then
        absChildren := absChildren.push child
      else
        collectWidgetCached cache child layouts (childPathKey pathKey flowIdx)
        flowIdx := flowIdx + 1
    let mut absIdx := flowIdx
    for child in absChildren do
      collectWidgetCached cache child layouts (childPathKey pathKey absIdx)
      absIdx := absIdx + 1
    let mut overlayIdx := absIdx
    for child in overlayChildren do
      CachedCollectM.deferOverlay child layouts (childPathKey pathKey overlayIdx)
      overlayIdx := overlayIdx + 1

  | .scroll _ _ style scrollState contentWidth contentHeight scrollbarConfig child _ =>
    collectBoxStyleCached borderRect style
    let clipRect : Rect := ⟨⟨contentRect.x, contentRect.y⟩, ⟨contentRect.width, contentRect.height⟩⟩
    let viewportW := contentRect.width
    let viewportH := contentRect.height
    let effectiveScroll := scrollState.clamp viewportW viewportH contentWidth contentHeight
    CachedCollectM.emitPushClip clipRect
    CachedCollectM.emitSave
    CachedCollectM.emitPushTranslate (-effectiveScroll.offsetX) (-effectiveScroll.offsetY)
    collectWidgetCached cache child layouts (childPathKey pathKey 0)
    CachedCollectM.emitPopTransform
    CachedCollectM.emitRestore
    CachedCollectM.emitPopClip

    -- Render scrollbars
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
      CachedCollectM.emitFillRect trackRect scrollbarConfig.trackColor radius
      let thumbRect : Rect := ⟨⟨trackX, contentRect.y + thumbY⟩, ⟨thickness, thumbHeight⟩⟩
      CachedCollectM.emitFillRect thumbRect scrollbarConfig.thumbColor radius

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
      CachedCollectM.emitFillRect trackRect scrollbarConfig.trackColor radius
      let thumbRect : Rect := ⟨⟨contentRect.x + thumbX, trackY⟩, ⟨thumbWidth, thickness⟩⟩
      CachedCollectM.emitFillRect thumbRect scrollbarConfig.thumbColor radius

/-- Render all deferred overlay widgets (cached version). -/
partial def renderDeferredOverlayCached (cache : IO.Ref RenderCache) : CachedCollectM Unit := do
  let state ← get
  set { state with deferredOverlay := #[] }
  for (widget, layouts, widgetPathKey) in state.deferredOverlay do
    collectWidgetCached cache widget layouts widgetPathKey
  let newState ← get
  if newState.deferredOverlay.size > 0 then
    renderDeferredOverlayCached cache

/-- Collect render commands with caching.
    This is the main entry point for cached render command collection.
    All CustomSpec widgets are automatically cached using path keys. -/
def collectCommandsCachedIntoWithSinkAndStats (cache : IO.Ref RenderCache) (w : Widget)
    (layouts : Trellis.LayoutResult) (sink : RenderCommandSink) : IO (Nat × Nat) := do
  let metricsOpt ← collectMetricsRef.get
  let ((), state) ← StateT.run (do
    modify fun s => { s with metrics := metricsOpt, sink := sink }
    collectWidgetCached cache w layouts rootPathKey  -- Start with root path key
    renderDeferredOverlayCached cache) {}
  pure (state.cacheHits, state.cacheMisses)

/-- Collect render commands with caching and stream them to a sink callback.
    Returns (cacheHits, cacheMisses). -/
def collectCommandsCachedIntoWithStats (cache : IO.Ref RenderCache) (w : Widget)
    (layouts : Trellis.LayoutResult) (emitCommand : RenderCommand → IO Unit) : IO (Nat × Nat) := do
  collectCommandsCachedIntoWithSinkAndStats cache w layouts
    (RenderCommandSink.ofEmit emitCommand)

/-- Collect render commands with caching and stream them to a sink callback. -/
def collectCommandsCachedInto (cache : IO.Ref RenderCache) (w : Widget)
    (layouts : Trellis.LayoutResult) (emitCommand : RenderCommand → IO Unit) : IO Unit := do
  let _ ← collectCommandsCachedIntoWithStats cache w layouts emitCommand
  pure ()

/-- Collect render commands with caching and stream them to a sink. -/
def collectCommandsCachedIntoWithSink (cache : IO.Ref RenderCache) (w : Widget)
    (layouts : Trellis.LayoutResult) (sink : RenderCommandSink) : IO Unit := do
  let _ ← collectCommandsCachedIntoWithSinkAndStats cache w layouts sink
  pure ()

/-- Collect render commands with caching.
    This is the main entry point for cached render command collection.
    All CustomSpec widgets are automatically cached using path keys. -/
def collectCommandsCached (cache : IO.Ref RenderCache) (w : Widget)
    (layouts : Trellis.LayoutResult) : IO (Array RenderCommand) := do
  let outRef ← IO.mkRef (#[] : Array RenderCommand)
  let sink : RenderCommandSink := {
    emit := fun cmd => outRef.modify (·.push cmd)
    emitAll := fun cmds =>
      outRef.modify fun acc => Id.run do
        let mut out := acc
        for cmd in cmds do
          out := out.push cmd
        out
  }
  collectCommandsCachedIntoWithSink cache w layouts sink
  outRef.get

/-- Collect render commands with caching and return statistics.
    Returns (commands, cacheHits, cacheMisses). -/
def collectCommandsCachedWithStats (cache : IO.Ref RenderCache) (w : Widget)
    (layouts : Trellis.LayoutResult) : IO (Array RenderCommand × Nat × Nat) := do
  let outRef ← IO.mkRef (#[] : Array RenderCommand)
  let sink : RenderCommandSink := {
    emit := fun cmd => outRef.modify (·.push cmd)
    emitAll := fun cmds =>
      outRef.modify fun acc => Id.run do
        let mut out := acc
        for cmd in cmds do
          out := out.push cmd
        out
  }
  let (hits, misses) ←
    collectCommandsCachedIntoWithSinkAndStats cache w layouts sink
  let commands ← outRef.get
  pure (commands, hits, misses)

end Afferent.Arbor
