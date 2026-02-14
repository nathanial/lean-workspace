/-
  Arbor Canvas Draw Helpers
  Immediate-mode drawing helpers layered on CanvasM.
-/
import Afferent.Draw.Types
import Afferent.Output.Canvas
import Afferent.Core.Path
import Afferent.Core.Transform
import Afferent.Graphics.Text.Measurer
import Afferent.Runtime.FFI.FloatBuffer
import Afferent.Runtime.FFI.Fragment
import Afferent.Runtime.FFI.MeshCache
import Afferent.Runtime.Shader.Cache
import Afferent.Runtime.Shader.Fragment

namespace Afferent

open Afferent
open Afferent.Arbor

namespace CanvasM

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

/-! ## Rectangle Commands -/

def fillRectColor (rect : Rect) (color : Color) (cornerRadius : Float := 0) : CanvasM Unit := do
  setFillColor color
  if cornerRadius > 0 then
    fillRoundedRect rect cornerRadius
  else
    fillRect rect

def fillRectColor' (x y w h : Float) (color : Color) (cornerRadius : Float := 0) : CanvasM Unit :=
  fillRectColor (Rect.mk' x y w h) color cornerRadius

def fillRectStyle (rect : Rect) (style : Afferent.FillStyle) (cornerRadius : Float := 0) : CanvasM Unit := do
  save
  setFillStyle style
  if cornerRadius > 0 then
    fillRoundedRect rect cornerRadius
  else
    fillRect rect
  restore

def strokeRectColor (rect : Rect) (color : Color) (lineWidth : Float) (cornerRadius : Float := 0) : CanvasM Unit := do
  setStrokeColor color
  setLineWidth lineWidth
  if cornerRadius > 0 then
    strokeRoundedRect rect cornerRadius
  else
    strokeRect rect

def strokeRectColor' (x y w h : Float) (color : Color) (lineWidth : Float) (cornerRadius : Float := 0) : CanvasM Unit :=
  strokeRectColor (Rect.mk' x y w h) color lineWidth cornerRadius

/-! ## Text Commands -/

def fillTextId (reg : FontRegistry) (text : String) (x y : Float) (font : Arbor.FontId) (color : Color) : CanvasM Unit := do
  match reg.get font with
  | some resolved =>
      let canvas ← getCanvas
      let (sx, sy) := snapTextPosition x y canvas.state.transform
      fillTextColor text ⟨sx, sy⟩ resolved color
  | none =>
      pure ()

def fillTextBlockId (reg : FontRegistry) (text : String) (rect : Rect) (font : Arbor.FontId) (color : Color)
    (align : Arbor.TextAlign := .left) (valign : Arbor.TextVAlign := .top) : CanvasM Unit := do
  match reg.get font with
  | some resolved =>
      let (textWidth, textHeight) ← measureText text resolved
      let x := match align with
        | .left => rect.origin.x
        | .center => rect.origin.x + (rect.size.width - textWidth) / 2
        | .right => rect.origin.x + rect.size.width - textWidth
      let y := match valign with
        | .top => rect.origin.y + resolved.ascender
        | .middle => rect.origin.y + (rect.size.height - textHeight) / 2 + resolved.ascender
        | .bottom => rect.origin.y + rect.size.height - resolved.descender
      let canvas ← getCanvas
      let (sx, sy) := snapTextPosition x y canvas.state.transform
      fillTextColor text ⟨sx, sy⟩ resolved color
  | none =>
      pure ()

/-! ## Path Commands -/

def fillPathColor (path : Path) (color : Color) : CanvasM Unit := do
  setFillColor color
  fillPath path

def fillPathStyle (path : Path) (style : Afferent.FillStyle) : CanvasM Unit := do
  save
  setFillStyle style
  fillPath path
  restore

def strokePathColor (path : Path) (color : Color) (lineWidth : Float) : CanvasM Unit := do
  setStrokeColor color
  setLineWidth lineWidth
  strokePath path

/-! ## Line/Batch Commands -/

def strokeLineBatch (data : Array Float) (count : Nat) (lineWidth : Float) : CanvasM Unit := do
  if count == 0 then
    pure ()
  else
    let canvas ← getCanvas
    let data := transformLineBatchData data count canvas.state.transform
    let (canvasWidth, canvasHeight) ← getCurrentSize
    canvas.ctx.renderer.drawLineBatch data count.toUInt32 lineWidth canvasWidth canvasHeight

def strokeRectBatch (data : Array Float) (count : Nat) (lineWidth : Float) : CanvasM Unit := do
  if count == 0 then
    pure ()
  else
    let canvas ← getCanvas
    let data := transformRectBatchData data count canvas.state.transform
    let (canvasWidth, canvasHeight) ← getCurrentSize
    canvas.ctx.renderer.drawBatch 2 data count.toUInt32 lineWidth 0.0 canvasWidth canvasHeight

def fillCircleBatch (data : Array Float) (count : Nat) : CanvasM Unit := do
  if count == 0 then
    pure ()
  else
    let canvas ← getCanvas
    let data := transformCircleBatchData data count canvas.state.transform
    let (canvasWidth, canvasHeight) ← getCurrentSize
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

/-! ## Polygon/Instancing Commands -/

def fillPolygon (points : Array Point) (color : Color) : CanvasM Unit := do
  if points.size >= 3 then
    let mut path := Path.empty.moveTo points[0]!
    for i in [1:points.size] do
      path := path.lineTo points[i]!
    path := path.closePath
    fillPathColor path color
  else
    pure ()

def strokePolygon (points : Array Point) (color : Color) (lineWidth : Float := 1.0) : CanvasM Unit := do
  if points.size >= 3 then
    let mut path := Path.empty.moveTo points[0]!
    for i in [1:points.size] do
      path := path.lineTo points[i]!
    path := path.closePath
    strokePathColor path color lineWidth
  else
    pure ()

def fillPolygonInstanced (pathHash : UInt64) (vertices : Array Float) (indices : Array UInt32)
    (instances : Array MeshInstance) (centerX centerY : Float) : CanvasM Unit := do
  if instances.size == 0 then
    pure ()
  else
    let canvas ← getCanvas
    let (mesh, canvas) ←
      match canvas.meshCache.get? pathHash with
      | some mesh => pure (mesh, canvas)
      | none =>
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

    let requiredFloats := transformedInstances.size * 8
    let (buf, canvas) ←
      match canvas.meshInstanceBuffer with
      | some buf =>
          if canvas.meshInstanceBufferCapacity >= requiredFloats then
            pure (buf, canvas)
          else
            FFI.FloatBuffer.destroy buf
            let newBuf ← FFI.FloatBuffer.create requiredFloats.toUSize
            pure (newBuf, { canvas with
              meshInstanceBuffer := some newBuf
              meshInstanceBufferCapacity := requiredFloats })
      | none =>
          let newBuf ← FFI.FloatBuffer.create requiredFloats.toUSize
          pure (newBuf, { canvas with
            meshInstanceBuffer := some newBuf
            meshInstanceBufferCapacity := requiredFloats })

    let mut idx : USize := 0
    for inst in transformedInstances do
      buf.setVec8 idx inst.x inst.y inst.rotation inst.scale inst.r inst.g inst.b inst.a
      idx := idx + 8

    setCanvas canvas
    let (canvasWidth, canvasHeight) ← getCurrentSize
    FFI.MeshCache.drawInstancedBuffer canvas.ctx.renderer mesh buf transformedInstances.size.toUInt32 canvasWidth canvasHeight

def strokeArcInstanced (instances : Array ArcInstance) (segments : Nat := 16) : CanvasM Unit := do
  if instances.size == 0 then
    pure ()
  else
    let canvas ← getCanvas
    let (canvasWidth, canvasHeight) ← getCurrentSize
    let transformedInstances :=
      if transformIsIdentity canvas.state.transform then
        instances
      else
        instances.map fun inst =>
          let (cx, cy) := transformPointXY canvas.state.transform inst.centerX inst.centerY
          { inst with centerX := cx, centerY := cy }
    let data := transformedInstances.foldl (init := #[]) fun acc inst =>
      acc.push inst.centerX |>.push inst.centerY
        |>.push inst.startAngle |>.push inst.sweepAngle
        |>.push inst.radius |>.push inst.strokeWidth
        |>.push inst.r |>.push inst.g |>.push inst.b |>.push inst.a
    canvas.ctx.renderer.drawArcInstanced data transformedInstances.size.toUInt32 segments.toUInt32 canvasWidth canvasHeight

/-! ## Fragment Commands -/

def drawFragment (fragmentHash : UInt64) (_primitiveType : UInt32)
    (params : Array Float) (_instanceCount : UInt32) : CanvasM Unit := do
  let canvas ← getCanvas
  let cache ← canvas.fragmentCache.get
  let (maybePipeline, newCache) ← Shader.getOrCompileGlobal cache canvas.ctx.renderer fragmentHash
  canvas.fragmentCache.set newCache

  match maybePipeline with
  | some pipeline =>
      let params ←
        match (← Shader.lookupFragment fragmentHash) with
        | some fragment =>
            pure (transformFragmentParamsCenter params fragment canvas.state.transform)
        | none =>
            pure params
      let (canvasWidth, canvasHeight) ← getCurrentSize
      FFI.Fragment.draw canvas.ctx.renderer pipeline params canvasWidth canvasHeight
  | none =>
      pure ()

/-! ## Batched Tessellation Commands -/

def fillTessellatedBatch (vertices : Array Float) (indices : Array UInt32) (vertexCount : Nat) : CanvasM Unit := do
  if vertexCount == 0 || indices.size == 0 then
    pure ()
  else
    let canvas ← getCanvas
    let vertices := transformTessellatedVertices vertices vertexCount canvas.state.transform
    let (screenWidth, screenHeight) ← getCurrentSize
    canvas.ctx.renderer.drawTrianglesScreenCoords
      vertices indices vertexCount.toUInt32 screenWidth screenHeight

/-! ## Circles -/

def fillCircleColor (center : Point) (radius : Float) (color : Color) : CanvasM Unit := do
  let canvas ← getCanvas
  let (cx, cy) := transformPointXY canvas.state.transform center.x center.y
  let (canvasWidth, canvasHeight) ← getCurrentSize
  let data := #[cx, cy, radius, 0.0, color.r, color.g, color.b, color.a, 0.0]
  canvas.ctx.renderer.drawBatch 1 data 1 0.0 0.0 canvasWidth canvasHeight

def fillCircleColor' (cx cy radius : Float) (color : Color) : CanvasM Unit :=
  fillCircleColor ⟨cx, cy⟩ radius color

def strokeCircleColor (center : Point) (radius : Float) (color : Color) (lineWidth : Float := 1.0) : CanvasM Unit := do
  let twoPi := 6.283185307179586
  let path := Path.empty.arc center radius 0 twoPi false
  strokePathColor path color lineWidth

def strokeCircleColor' (cx cy radius : Float) (color : Color) (lineWidth : Float := 1.0) : CanvasM Unit :=
  strokeCircleColor ⟨cx, cy⟩ radius color lineWidth

/-! ## Clipping -/

def pushClip (rect : Rect) : CanvasM Unit :=
  clip rect

def withClip (rect : Rect) (m : CanvasM Unit) : CanvasM Unit := do
  pushClip rect
  m
  popClip

/-! ## Transforms -/

def pushTranslate (dx dy : Float) : CanvasM Unit := do
  save
  translate dx dy

def pushRotate (angle : Float) : CanvasM Unit := do
  save
  rotate angle

def pushScale (sx sy : Float) : CanvasM Unit := do
  save
  scale sx sy

def popTransform : CanvasM Unit :=
  restore

def withTranslate (dx dy : Float) (m : CanvasM Unit) : CanvasM Unit := do
  pushTranslate dx dy
  m
  popTransform

def withRotate (angle : Float) (m : CanvasM Unit) : CanvasM Unit := do
  pushRotate angle
  m
  popTransform

def withScale (sx sy : Float) (m : CanvasM Unit) : CanvasM Unit := do
  pushScale sx sy
  m
  popTransform

/-! ## State Save/Restore -/

def withSave (m : CanvasM Unit) : CanvasM Unit := do
  save
  m
  restore

end CanvasM

end Afferent
