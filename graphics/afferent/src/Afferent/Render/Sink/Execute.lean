/-
  Afferent Render Sink Execute
  Terminal execution boundary for planned draw packets.
-/
import Afferent.Output.Canvas
import Afferent.Core.Path
import Afferent.Core.Transform
import Afferent.Graphics.Text.Font
import Afferent.Graphics.Text.Measurer
import Afferent.UI.Arbor
import Afferent.Render.Plan.Packet
import Afferent.Render.Sink.Batches

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

private def executeCirclePacked (data : Array Float) (count : Nat) : CanvasM Unit := do
  if count == 0 then
    pure ()
  else
    let canvas ← CanvasM.getCanvas
    let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
    -- Legacy packed circle command format is 7 floats; renderer expects 9.
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

private def executeStrokeRectPacked (data : Array Float) (count : Nat) (lineWidth : Float) : CanvasM Unit := do
  if count == 0 then
    pure ()
  else
    let canvas ← CanvasM.getCanvas
    let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
    canvas.ctx.renderer.drawBatch 2 data count.toUInt32 lineWidth 0.0 canvasWidth canvasHeight

private def executeStrokeLineBatch (data : Array Float) (count : Nat) (lineWidth : Float) : CanvasM Unit := do
  if count == 0 then
    pure ()
  else
    let canvas ← CanvasM.getCanvas
    let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
    canvas.ctx.renderer.drawLineBatch data count.toUInt32 lineWidth canvasWidth canvasHeight

private def executePacketCommand (reg : FontRegistry) (packet : DrawPacket) : CanvasM Unit := do
  match packet with
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

  | .strokeRectPacked data count lineWidth =>
    executeStrokeRectPacked data count lineWidth

  | .fillCircle center radius color =>
    let canvas ← CanvasM.getCanvas
    let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
    let data := #[center.x, center.y, radius, 0.0, color.r, color.g, color.b, color.a, 0.0]
    canvas.ctx.renderer.drawBatch 1 data 1 0.0 0.0 canvasWidth canvasHeight

  | .fillCirclePacked data count =>
    executeCirclePacked data count

  | .strokeCircle center radius color lineWidth =>
    let twoPi := 6.283185307179586
    let path := Path.empty.arc center radius 0 twoPi false
    CanvasM.setStrokeColor color
    CanvasM.setLineWidth lineWidth
    CanvasM.strokePath path

  | .strokeLine p1 p2 color lineWidth =>
    let canvas ← CanvasM.getCanvas
    let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
    let data := #[p1.x, p1.y, p2.x, p2.y, color.r, color.g, color.b, color.a, 0.0]
    canvas.ctx.renderer.drawLineBatch data 1 lineWidth canvasWidth canvasHeight

  | .strokeLineBatch data count lineWidth =>
    executeStrokeLineBatch data count lineWidth

  | .fillText text x y fontId color =>
    match reg.get fontId with
    | some font =>
      let canvas ← CanvasM.getCanvas
      let (sx, sy) := snapTextPosition x y canvas.state.transform
      CanvasM.fillTextColor text ⟨sx, sy⟩ font color
    | none =>
      pure ()

  | .fillTextBlock text rect fontId color align valign =>
    match reg.get fontId with
    | some font =>
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
      let canvas ← CanvasM.getCanvas
      let (mesh, canvas) ← do
        match canvas.meshCache.get? pathHash with
        | some mesh => pure (mesh, canvas)
        | none =>
          let mesh ← FFI.MeshCache.create canvas.ctx.renderer vertices indices centerX centerY
          let cache := canvas.meshCache.insert pathHash mesh
          pure (mesh, { canvas with meshCache := cache })

      let requiredFloats := instances.size * 8
      let (buf, _cap, canvas) ←
        match canvas.meshInstanceBuffer with
        | some buf =>
          if canvas.meshInstanceBufferCapacity >= requiredFloats then
            pure (buf, canvas.meshInstanceBufferCapacity, canvas)
          else
            FFI.FloatBuffer.destroy buf
            let newBuf ← FFI.FloatBuffer.create requiredFloats.toUSize
            pure (newBuf, requiredFloats,
              { canvas with meshInstanceBuffer := some newBuf, meshInstanceBufferCapacity := requiredFloats })
        | none =>
          let newBuf ← FFI.FloatBuffer.create requiredFloats.toUSize
          pure (newBuf, requiredFloats,
            { canvas with meshInstanceBuffer := some newBuf, meshInstanceBufferCapacity := requiredFloats })

      let mut idx : USize := 0
      for inst in instances do
        buf.setVec8 idx inst.x inst.y inst.rotation inst.scale inst.r inst.g inst.b inst.a
        idx := idx + 8

      CanvasM.setCanvas canvas

      let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
      FFI.MeshCache.drawInstancedBuffer canvas.ctx.renderer mesh buf instances.size.toUInt32 canvasWidth canvasHeight

  | .strokeArcInstanced instances segments =>
    if instances.size == 0 then
      pure ()
    else
      let canvas ← CanvasM.getCanvas
      let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
      let data := instances.foldl (init := #[]) fun acc inst =>
        acc.push inst.centerX |>.push inst.centerY
           |>.push inst.startAngle |>.push inst.sweepAngle
           |>.push inst.radius |>.push inst.strokeWidth
           |>.push inst.r |>.push inst.g |>.push inst.b |>.push inst.a
      canvas.ctx.renderer.drawArcInstanced data instances.size.toUInt32 segments.toUInt32 canvasWidth canvasHeight

  | .drawFragment fragmentHash _primitiveType params _instanceCount =>
    let canvas ← CanvasM.getCanvas
    let cache ← canvas.fragmentCache.get
    let (maybePipeline, newCache) ← Shader.getOrCompileGlobal cache canvas.ctx.renderer fragmentHash
    canvas.fragmentCache.set newCache

    match maybePipeline with
    | some pipeline =>
      let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
      FFI.Fragment.draw canvas.ctx.renderer pipeline params canvasWidth canvasHeight
    | none =>
      pure ()

  | .fillTessellatedBatch vertices indices vertexCount =>
    if vertexCount == 0 || indices.size == 0 then
      pure ()
    else
      let canvas ← CanvasM.getCanvas
      let (screenWidth, screenHeight) ← canvas.ctx.getCurrentSize
      canvas.ctx.renderer.drawTrianglesScreenCoords
        vertices indices vertexCount.toUInt32 screenWidth screenHeight

  | .pushClip rect =>
    CanvasM.clip rect

  | .popClip =>
    CanvasM.popClip

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

  | .fillRectBatch _
  | .strokeRectBatch _ _
  | .fillCircleBatch _
  | .strokeCircleBatch _ _ =>
    pure ()

/-- Execute one planned draw packet.
    Returns elapsed time in nanoseconds for draw-call timing metrics. -/
def executeDrawPacket (reg : FontRegistry) (packet : DrawPacket) : CanvasM Nat := do
  let t0 ← IO.monoNanosNow
  match packet with
  | .fillRectBatch entries =>
    executeFillRectBatch entries
  | .strokeRectBatch entries lineWidth =>
    executeStrokeRectBatch entries lineWidth
  | .fillCircleBatch entries =>
    executeFillCircleBatch entries
  | .strokeCircleBatch entries lineWidth =>
    executeStrokeCircleBatch entries lineWidth
  | _ =>
    executePacketCommand reg packet
  let t1 ← IO.monoNanosNow
  pure (t1 - t0)

end Afferent.Widget
