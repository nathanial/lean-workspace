/-
  Afferent Render Plan Packets
  Backend-ready packet IR produced from render streams.
-/
import Afferent.UI.Arbor
import Afferent.Render.Stream
import Afferent.Render.Sink.Batches

namespace Afferent.Widget

open Afferent
open Afferent.Arbor

/-- Planned packet to execute at the sink boundary.
    This is explicit and exhaustive: there is no generic command fallback packet. -/
inductive DrawPacket where
  | fillRectBatch (entries : Array RectBatchEntry)
  | strokeRectBatch (entries : Array StrokeRectBatchEntry) (lineWidth : Float)
  | fillCircleBatch (entries : Array CircleBatchEntry)
  | strokeCircleBatch (entries : Array StrokeCircleBatchEntry) (lineWidth : Float)

  | fillRect (rect : Rect) (color : Color) (cornerRadius : Float)
  | fillRectStyle (rect : Rect) (style : Afferent.FillStyle) (cornerRadius : Float)
  | strokeRect (rect : Rect) (color : Color) (lineWidth : Float) (cornerRadius : Float)

  | strokeRectPacked (data : Array Float) (count : Nat) (lineWidth : Float)
  | fillCircle (center : Point) (radius : Float) (color : Color)
  | fillCirclePacked (data : Array Float) (count : Nat)
  | strokeCircle (center : Point) (radius : Float) (color : Color) (lineWidth : Float)

  | strokeLine (p1 p2 : Point) (color : Color) (lineWidth : Float)
  | strokeLineBatch (data : Array Float) (count : Nat) (lineWidth : Float)

  | fillText (text : String) (x y : Float) (font : FontId) (color : Color)
  | fillTextBlock (text : String) (rect : Rect) (font : FontId) (color : Color)
      (align : TextAlign) (valign : TextVAlign)

  | fillPolygon (points : Array Point) (color : Color)
  | strokePolygon (points : Array Point) (color : Color) (lineWidth : Float)
  | fillPath (path : Path) (color : Color)
  | fillPathStyle (path : Path) (style : Afferent.FillStyle)
  | strokePath (path : Path) (color : Color) (lineWidth : Float)

  | fillPolygonInstanced (pathHash : UInt64) (vertices : Array Float) (indices : Array UInt32)
      (instances : Array MeshInstance) (centerX centerY : Float)
  | strokeArcInstanced (instances : Array ArcInstance) (segments : Nat)

  | drawFragment (fragmentHash : UInt64) (primitiveType : UInt32)
      (params : Array Float) (instanceCount : UInt32)
  | fillTessellatedBatch (vertices : Array Float) (indices : Array UInt32) (vertexCount : Nat)

  | pushClip (rect : Rect)
  | popClip
  | pushTranslate (dx dy : Float)
  | pushRotate (angle : Float)
  | pushScale (sx sy : Float)
  | popTransform
  | save
  | restore
  deriving Repr

/-- Per-stage trace record for the stream pipeline. -/
structure StageTrace where
  name : String
  inputCount : Nat
  outputCount : Nat
  elapsedMs : Float
  deriving Repr, Inhabited

/-- Execution trace for one frame through the render stream pipeline. -/
structure RenderTrace where
  frameId : Nat := 0
  normalizedEvents : Nat := 0
  coalescedCommands : Nat := 0
  packets : Nat := 0
  stages : Array StageTrace := #[]
  deriving Repr, Inhabited

end Afferent.Widget
