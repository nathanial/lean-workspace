/-
  Afferent Widget Backend Command Execution
-/
import Afferent.Output.Canvas
import Afferent.Core.Path
import Afferent.Core.Transform
import Afferent.Graphics.Text.Font
import Afferent.Graphics.Text.Measurer
import Afferent.UI.Arbor
import Std.Data.HashMap

namespace Afferent.Widget

open Afferent
open Afferent.Arbor

/-- Convert a polygon (array of points) to a closed path. -/
private def polygonToPath (points : Array Point) : Path :=
  Id.run do
    if points.size > 0 then
      let first := points[0]!
      let mut path := Path.empty.moveTo first
      for i in [1:points.size] do
        let p := points[i]!
        path := path.lineTo p
      return path.closePath
    else
      return Path.empty

/-- Snap text positions to device pixels for axis-aligned transforms (scale + translate only). -/
private def snapTextPosition (x y : Float) (transform : Transform) : (Float × Float) :=
  let eps : Float := 1.0e-4
  let axisAligned := Float.abs transform.b <= eps && Float.abs transform.c <= eps
  if axisAligned && transform.a != 0.0 && transform.d != 0.0 then
    let snappedX := (Float.round (transform.a * x + transform.tx) - transform.tx) / transform.a
    let snappedY := (Float.round (transform.d * y + transform.ty) - transform.ty) / transform.d
    (snappedX, snappedY)
  else
    (x, y)

private def transformIsIdentity (transform : Transform) : Bool :=
  let eps : Float := 1.0e-6
  Float.abs (transform.a - 1.0) <= eps &&
  Float.abs transform.b <= eps &&
  Float.abs transform.c <= eps &&
  Float.abs (transform.d - 1.0) <= eps &&
  Float.abs transform.tx <= eps &&
  Float.abs transform.ty <= eps

private def transformPointXY (transform : Transform) (x y : Float) : (Float × Float) :=
  let p := transform.apply ⟨x, y⟩
  (p.x, p.y)

private def transformLineBatchData (data : Array Float) (count : Nat) (transform : Transform) : Array Float := Id.run do
  if count == 0 || transformIsIdentity transform then
    return data
  let mut out : Array Float := Array.mkEmpty data.size
  for i in [:count] do
    let base := i * 9
    let x1 := data[base]!
    let y1 := data[base + 1]!
    let x2 := data[base + 2]!
    let y2 := data[base + 3]!
    let (tx1, ty1) := transformPointXY transform x1 y1
    let (tx2, ty2) := transformPointXY transform x2 y2
    out := out.push tx1 |>.push ty1 |>.push tx2 |>.push ty2
      |>.push data[base + 4]! |>.push data[base + 5]!
      |>.push data[base + 6]! |>.push data[base + 7]!
      |>.push data[base + 8]!
  return out

private def transformRectBatchData (data : Array Float) (count : Nat) (transform : Transform) : Array Float := Id.run do
  if count == 0 || transformIsIdentity transform then
    return data
  let mut out : Array Float := Array.mkEmpty data.size
  for i in [:count] do
    let base := i * 9
    let x := data[base]!
    let y := data[base + 1]!
    let (tx, ty) := transformPointXY transform x y
    out := out.push tx |>.push ty
      |>.push data[base + 2]! |>.push data[base + 3]!
      |>.push data[base + 4]! |>.push data[base + 5]!
      |>.push data[base + 6]! |>.push data[base + 7]!
      |>.push data[base + 8]!
  return out

private def transformCircleBatchData (data : Array Float) (count : Nat) (transform : Transform) : Array Float := Id.run do
  if count == 0 || transformIsIdentity transform then
    return data
  let mut out : Array Float := Array.mkEmpty data.size
  for i in [:count] do
    let base := i * 7
    let cx := data[base]!
    let cy := data[base + 1]!
    let (tcx, tcy) := transformPointXY transform cx cy
    out := out.push tcx |>.push tcy |>.push data[base + 2]!
      |>.push data[base + 3]! |>.push data[base + 4]!
      |>.push data[base + 5]! |>.push data[base + 6]!
  return out

private def transformFragmentParamsCenter (params : Array Float) (fragment : Shader.ShaderFragment)
    (transform : Transform) : Array Float :=
  if transformIsIdentity transform then
    params
  else
    let packed := fragment.paramsPackedFloatCount
    if packed < 2 || params.size % packed != 0 then
      params
    else
      Id.run do
        let mut out := params
        let batchCount := params.size / packed
        for i in [:batchCount] do
          let base := i * packed
          let x := out[base]!
          let y := out[base + 1]!
          let (tx, ty) := transformPointXY transform x y
          out := out.set! base tx
          out := out.set! (base + 1) ty
        return out

private def transformTessellatedVertices (vertices : Array Float) (vertexCount : Nat)
    (transform : Transform) : Array Float := Id.run do
  if vertexCount == 0 || transformIsIdentity transform then
    return vertices
  let mut out : Array Float := Array.mkEmpty vertices.size
  for i in [:vertexCount] do
    let base := i * 6
    let x := vertices[base]!
    let y := vertices[base + 1]!
    let (tx, ty) := transformPointXY transform x y
    out := out.push tx |>.push ty
      |>.push vertices[base + 2]! |>.push vertices[base + 3]!
      |>.push vertices[base + 4]! |>.push vertices[base + 5]!
  return out

/-- Clip stack operation represented by render commands.
    Kept explicit to make clip semantics easy to test and prevent regressions. -/
inductive ClipStackAction where
  | push (rect : Rect)
  | pop
deriving Repr, BEq, Inhabited

namespace ClipStackAction

/-- Apply a clip stack action to pure canvas state. -/
def applyToState (action : ClipStackAction) (state : CanvasState) : CanvasState :=
  match action with
  | .push rect => state.pushClip rect
  | .pop => state.popClip

end ClipStackAction

/-- Extract clip stack action for clip-related render commands. -/
def clipStackAction? : RenderCommand → Option ClipStackAction
  | .pushClip rect => some (.push rect)
  | .popClip => some .pop
  | _ => none

private def executeClipStackAction (action : ClipStackAction) : CanvasM Unit :=
  match action with
  | .push rect => CanvasM.clip rect
  | .pop => CanvasM.popClip

/-- Execute a single RenderCommand using CanvasM.
    Requires a FontRegistry to resolve FontIds to Font handles. -/
def executeCommand (reg : FontRegistry) (cmd : Afferent.Arbor.RenderCommand) : CanvasM Unit := do
  match cmd with
  | .fillRect rect color cornerRadius =>
    if cornerRadius > 0 then
      CanvasM.setFillColor color
      CanvasM.fillRoundedRect rect cornerRadius
    else
      CanvasM.setFillColor color
      CanvasM.fillRect rect

  | .fillRectStyle rect style cornerRadius =>
    CanvasM.save
    CanvasM.setFillStyle style
    if cornerRadius > 0 then
      CanvasM.fillRoundedRect rect cornerRadius
    else
      CanvasM.fillRect rect
    CanvasM.restore

  | .strokeRect rect color lineWidth cornerRadius =>
    CanvasM.setStrokeColor color
    CanvasM.setLineWidth lineWidth
    if cornerRadius > 0 then
      CanvasM.strokeRoundedRect rect cornerRadius
    else
      CanvasM.strokeRect rect

  | .fillCircle center radius color =>
    -- Draw a single filled circle via the batch function
    let canvas ← CanvasM.getCanvas
    let (cx, cy) := transformPointXY canvas.state.transform center.x center.y
    let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
    let data := #[cx, cy, radius, 0.0, color.r, color.g, color.b, color.a, 0.0]
    canvas.ctx.renderer.drawBatch 1 data 1 0.0 0.0 canvasWidth canvasHeight

  | .strokeCircle center radius color lineWidth =>
    -- Draw a stroked circle using path (no stroked circle batch yet)
    let twoPi := 6.283185307179586  -- 2 * pi
    let path := Path.empty.arc center radius 0 twoPi false
    CanvasM.setStrokeColor color
    CanvasM.setLineWidth lineWidth
    CanvasM.strokePath path

  | .strokeLine p1 p2 color lineWidth =>
    -- Draw a single line via the batch function (batch size = 1)
    let canvas ← CanvasM.getCanvas
    let (x1, y1) := transformPointXY canvas.state.transform p1.x p1.y
    let (x2, y2) := transformPointXY canvas.state.transform p2.x p2.y
    let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
    let data := #[x1, y1, x2, y2, color.r, color.g, color.b, color.a, 0.0]
    canvas.ctx.renderer.drawLineBatch data 1 lineWidth canvasWidth canvasHeight

  | .strokeLineBatch data count lineWidth =>
    if count == 0 then
      pure ()
    else
      let canvas ← CanvasM.getCanvas
      let data := transformLineBatchData data count canvas.state.transform
      let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
      canvas.ctx.renderer.drawLineBatch data count.toUInt32 lineWidth canvasWidth canvasHeight

  | .strokeRectBatch data count lineWidth =>
    if count == 0 then
      pure ()
    else
      let canvas ← CanvasM.getCanvas
      let data := transformRectBatchData data count canvas.state.transform
      let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
      canvas.ctx.renderer.drawBatch 2 data count.toUInt32 lineWidth 0.0 canvasWidth canvasHeight

  | .fillCircleBatch data count =>
    if count == 0 then
      pure ()
    else
      let canvas ← CanvasM.getCanvas
      let data := transformCircleBatchData data count canvas.state.transform
      let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
      -- Convert from [cx, cy, radius, r, g, b, a] (7 floats) to [x, y, w, h, r, g, b, a, cornerRadius] (9 floats)
      let mut batchData : Array Float := Array.mkEmpty (count * 9)
      for i in [:count] do
        let base := i * 7
        let cx := data[base]!
        let cy := data[base + 1]!
        let radius := data[base + 2]!
        let r := data[base + 3]!
        let g := data[base + 4]!
        let b := data[base + 5]!
        let a := data[base + 6]!
        let diameter := radius * 2.0
        batchData := batchData.push (cx - radius) |>.push (cy - radius)
                               |>.push diameter |>.push diameter
                               |>.push r |>.push g |>.push b |>.push a |>.push 0.0
      canvas.ctx.renderer.drawBatch 1 batchData count.toUInt32 0.0 0.0 canvasWidth canvasHeight

  | .fillText text x y fontId color =>
    match reg.get fontId with
    | some font =>
      let canvas ← CanvasM.getCanvas
      let (sx, sy) := snapTextPosition x y canvas.state.transform
      CanvasM.fillTextColor text ⟨sx, sy⟩ font color
    | none =>
      -- Font not found, skip rendering
      pure ()

  | .fillTextBlock text rect fontId color align valign =>
    match reg.get fontId with
    | some font =>
      -- Measure text to calculate alignment
      let (textWidth, textHeight) ← CanvasM.measureText text font
      let x := match align with
        | .left => rect.origin.x
        | .center => rect.origin.x + (rect.size.width - textWidth) / 2
        | .right => rect.origin.x + rect.size.width - textWidth
      let y := match valign with
        | .top => rect.origin.y + font.ascender
        | .middle => rect.origin.y + (rect.size.height - textHeight) / 2 + font.ascender
        | .bottom => rect.origin.y + rect.size.height - font.descender
      let canvas ← CanvasM.getCanvas
      let (sx, sy) := snapTextPosition x y canvas.state.transform
      CanvasM.fillTextColor text ⟨sx, sy⟩ font color
    | none =>
      pure ()

  | .fillPolygon points color =>
    if points.size >= 3 then
      let path := polygonToPath points
      CanvasM.setFillColor color
      CanvasM.fillPath path
    else
      pure ()

  | .strokePolygon points color lineWidth =>
    if points.size >= 3 then
      let path := polygonToPath points
      CanvasM.setStrokeColor color
      CanvasM.setLineWidth lineWidth
      CanvasM.strokePath path
    else
      pure ()

  | .fillPath path color =>
    CanvasM.setFillColor color
    CanvasM.fillPath path

  | .fillPathStyle path style =>
    CanvasM.save
    CanvasM.setFillStyle style
    CanvasM.fillPath path
    CanvasM.restore

  | .strokePath path color lineWidth =>
    CanvasM.setStrokeColor color
    CanvasM.setLineWidth lineWidth
    CanvasM.strokePath path

  | .fillPolygonInstanced pathHash vertices indices instances centerX centerY =>
    if instances.size == 0 then
      pure ()
    else
      -- Get or create cached mesh
      let canvas ← CanvasM.getCanvas
      let (mesh, canvas) ← do
        match canvas.meshCache.get? pathHash with
        | some mesh => pure (mesh, canvas)
        | none =>
          -- Create new cached mesh
          let mesh ← FFI.MeshCache.create canvas.ctx.renderer vertices indices centerX centerY
          let cache := canvas.meshCache.insert pathHash mesh
          pure (mesh, { canvas with meshCache := cache })

      let transformedInstances :=
        if transformIsIdentity canvas.state.transform then
          instances
        else
          instances.map fun inst =>
            let (x, y) := transformPointXY canvas.state.transform inst.x inst.y
            { inst with x, y }

      -- Ensure instance buffer has enough capacity (8 floats per instance)
      let requiredFloats := transformedInstances.size * 8
      let (buf, _cap, canvas) ←
        match canvas.meshInstanceBuffer with
        | some buf =>
          if canvas.meshInstanceBufferCapacity >= requiredFloats then
            pure (buf, canvas.meshInstanceBufferCapacity, canvas)
          else
            FFI.FloatBuffer.destroy buf
            let newBuf ← FFI.FloatBuffer.create requiredFloats.toUSize
            pure (newBuf, requiredFloats, { canvas with meshInstanceBuffer := some newBuf, meshInstanceBufferCapacity := requiredFloats })
        | none =>
          let newBuf ← FFI.FloatBuffer.create requiredFloats.toUSize
          pure (newBuf, requiredFloats, { canvas with meshInstanceBuffer := some newBuf, meshInstanceBufferCapacity := requiredFloats })

      -- Write instance data to buffer
      let mut idx : USize := 0
      for inst in transformedInstances do
        buf.setVec8 idx inst.x inst.y inst.rotation inst.scale inst.r inst.g inst.b inst.a
        idx := idx + 8

      CanvasM.setCanvas canvas

      -- Draw all instances
      let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
      FFI.MeshCache.drawInstancedBuffer canvas.ctx.renderer mesh buf transformedInstances.size.toUInt32 canvasWidth canvasHeight

  | .strokeArcInstanced instances segments =>
    if instances.size == 0 then
      pure ()
    else
      let canvas ← CanvasM.getCanvas
      let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
      let transformedInstances :=
        if transformIsIdentity canvas.state.transform then
          instances
        else
          instances.map fun inst =>
            let (cx, cy) := transformPointXY canvas.state.transform inst.centerX inst.centerY
            { inst with centerX := cx, centerY := cy }
      -- Pack arc instances into Float array: 10 floats per instance
      let data := transformedInstances.foldl (init := #[]) fun acc inst =>
        acc.push inst.centerX |>.push inst.centerY
           |>.push inst.startAngle |>.push inst.sweepAngle
           |>.push inst.radius |>.push inst.strokeWidth
           |>.push inst.r |>.push inst.g |>.push inst.b |>.push inst.a
      canvas.ctx.renderer.drawArcInstanced data transformedInstances.size.toUInt32 segments.toUInt32 canvasWidth canvasHeight

  | .drawFragment fragmentHash _primitiveType params _instanceCount =>
    -- Get pipeline cache from canvas
    let canvas ← CanvasM.getCanvas
    let cache ← canvas.fragmentCache.get

    -- Get or compile the fragment pipeline using global registry
    let (maybePipeline, newCache) ← Shader.getOrCompileGlobal cache canvas.ctx.renderer fragmentHash

    -- Update cache if changed
    canvas.fragmentCache.set newCache

    -- Draw if we have a pipeline
    match maybePipeline with
    | some pipeline =>
      let params ←
        match (← Shader.lookupFragment fragmentHash) with
        | some fragment =>
          pure (transformFragmentParamsCenter params fragment canvas.state.transform)
        | none =>
          pure params
      let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
      FFI.Fragment.draw canvas.ctx.renderer pipeline params canvasWidth canvasHeight
    | none =>
      -- Pipeline compilation failed or fragment not registered
      pure ()

  | .fillTessellatedBatch vertices indices vertexCount =>
    if vertexCount == 0 || indices.size == 0 then
      pure ()
    else
      -- GPU-side NDC conversion: pass screen coords directly to shader
      let canvas ← CanvasM.getCanvas
      let vertices := transformTessellatedVertices vertices vertexCount canvas.state.transform
      let (screenWidth, screenHeight) ← canvas.ctx.getCurrentSize
      canvas.ctx.renderer.drawTrianglesScreenCoords
        vertices indices vertexCount.toUInt32 screenWidth screenHeight

  | .customDraw draw =>
    draw.run

  | .pushClip rect =>
    executeClipStackAction (.push rect)

  | .popClip =>
    executeClipStackAction .pop

  | .pushTranslate dx dy =>
    CanvasM.save
    CanvasM.translate dx dy

  | .pushRotate angle =>
    CanvasM.save
    CanvasM.rotate angle

  | .pushScale sx sy =>
    CanvasM.save
    CanvasM.scale sx sy

  | .popTransform =>
    CanvasM.restore

  | .save =>
    CanvasM.save

  | .restore =>
    CanvasM.restore

/-- Execution statistics.
    Fields are retained for compatibility with historical batching metrics. -/
structure BatchStats where
  batchedCalls : Nat := 0
  individualCalls : Nat := 0
  totalCommands : Nat := 0
  rectsBatched : Nat := 0
  circlesBatched : Nat := 0
  strokeRectsBatched : Nat := 0
  strokeRectDirectRuns : Nat := 0
  strokeRectDirectRects : Nat := 0
  textsBatched : Nat := 0
  textFillCommands : Nat := 0
  textBatchFlushes : Nat := 0
  timeFlattenMs : Float := 0.0
  timeCoalesceMs : Float := 0.0
  timeBatchLoopMs : Float := 0.0
  timeDrawCallsMs : Float := 0.0
  timeTextPackMs : Float := 0.0
  timeTextFFIMs : Float := 0.0
  deriving Repr, Inhabited

/-- Compatibility API: execute commands sequentially and return stats. -/
def executeCommandsBatchedWithStats (reg : FontRegistry)
    (cmds : Array Afferent.Arbor.RenderCommand) : CanvasM BatchStats := do
  let t0 ← IO.monoNanosNow
  for cmd in cmds do
    executeCommand reg cmd
  let t1 ← IO.monoNanosNow
  let totalMs := (t1 - t0).toFloat / 1000000.0
  pure {
    totalCommands := cmds.size
    individualCalls := cmds.size
    timeBatchLoopMs := totalMs
    timeDrawCallsMs := totalMs
  }

/-- Compatibility API: execute commands sequentially. -/
def executeCommandsBatched (reg : FontRegistry)
    (cmds : Array Afferent.Arbor.RenderCommand) : CanvasM Unit := do
  let _ ← executeCommandsBatchedWithStats reg cmds
  pure ()

end Afferent.Widget
