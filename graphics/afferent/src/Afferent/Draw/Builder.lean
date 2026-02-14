/-
  Arbor Canvas Draw Helpers
  Immediate-mode drawing helpers layered on CanvasM.
-/
import Afferent.Draw.Types
import Afferent.Output.Canvas
import Afferent.Core.Path
import Afferent.Core.Transform
import Afferent.Graphics.Text.Measurer
import Afferent.Runtime.FFI.Fragment
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
        let entryCount := params.size / packed
        for i in [:entryCount] do
          let base := i * packed
          let x := out[base]!
          let y := out[base + 1]!
          let (tx, ty) := transformPointXY transform x y
          out := out.set! base tx
          out := out.set! (base + 1) ty
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

def fillTextId (text : String) (x y : Float) (font : Arbor.FontId) (color : Color) : CanvasM Unit := do
  let reg ← getFontRegistry
  match reg.get font with
  | some resolved =>
      let canvas ← getCanvas
      let (sx, sy) := snapTextPosition x y canvas.state.transform
      fillTextColor text ⟨sx, sy⟩ resolved color
  | none =>
      pure ()

def fillTextBlockId (text : String) (rect : Rect) (font : Arbor.FontId) (color : Color)
    (align : Arbor.TextAlign := .left) (valign : Arbor.TextVAlign := .top) : CanvasM Unit := do
  let reg ← getFontRegistry
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

/-! ## Line Commands -/

def strokeLineColor (start finish : Point) (color : Color) (lineWidth : Float := 1.0) : CanvasM Unit := do
  strokePathColor (Path.empty |>.moveTo start |>.lineTo finish) color lineWidth

/-! ## Polygon Commands -/

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

def strokeArcColor (center : Point) (radius startAngle sweepAngle : Float)
    (color : Color) (lineWidth : Float := 1.0) : CanvasM Unit := do
  let path := Path.empty.arc center radius startAngle (startAngle + sweepAngle) false
  strokePathColor path color lineWidth

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

/-! ## Circles -/

def fillCircleColor (center : Point) (radius : Float) (color : Color) : CanvasM Unit := do
  fillPathColor (Path.circle center radius) color

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
