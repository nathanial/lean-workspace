/-
  Arbor Draw Types
  Shared draw datatypes used by immediate-mode rendering.
-/
import Afferent.UI.Arbor.Core.Types

namespace Afferent.Arbor

/-- Text horizontal alignment. -/
inductive TextAlign where
  | left
  | center
  | right
deriving Repr, BEq, Inhabited

/-- Text vertical alignment. -/
inductive TextVAlign where
  | top
  | middle
  | bottom
deriving Repr, BEq, Inhabited

/-- Instance data for instanced polygon rendering.
    8 floats per instance: position(2), rotation(1), scale(1), color(4). -/
structure MeshInstance where
  x : Float
  y : Float
  rotation : Float
  scale : Float
  r : Float
  g : Float
  b : Float
  a : Float
deriving Repr, BEq, Inhabited

/-- Instance data for instanced arc stroke rendering.
    10 floats per instance: center(2), startAngle(1), sweepAngle(1),
    radius(1), strokeWidth(1), color(4). -/
structure ArcInstance where
  centerX : Float
  centerY : Float
  startAngle : Float
  sweepAngle : Float
  radius : Float
  strokeWidth : Float
  r : Float
  g : Float
  b : Float
  a : Float
deriving Repr, BEq, Inhabited

end Afferent.Arbor
