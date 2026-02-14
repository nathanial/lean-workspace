/-
  Afferent Tessellation Cache
  Types for pre-tessellated polygon geometry.
-/
import Afferent.Core.Types
import Afferent.Graphics.Render.Tessellation.Types

namespace Afferent

namespace Tessellation

/-- Pre-tessellated polygon in local coordinates (not NDC, no colors).
    Used to cache tessellation results that can be reused each frame. -/
structure TessellatedPolygon where
  /-- Vertex positions: [x, y, x, y, ...] in normalized 0-1 coords. -/
  positions : Array Float
  /-- Triangle indices for rendering. -/
  indices : Array UInt32
  /-- Number of vertices (positions.size / 2). -/
  vertexCount : Nat
  /-- Centroid X coordinate in normalized coords. -/
  centroidX : Float
  /-- Centroid Y coordinate in normalized coords. -/
  centroidY : Float
  /-- Bounding box: (minX, minY, maxX, maxY) -/
  bounds : Float × Float × Float × Float
  deriving Repr, Inhabited

namespace TessellatedPolygon

/-- Create an empty tessellated polygon. -/
def empty : TessellatedPolygon :=
  { positions := #[]
    indices := #[]
    vertexCount := 0
    centroidX := 0.0
    centroidY := 0.0
    bounds := (0.0, 0.0, 0.0, 0.0) }

/-- Check if the tessellated polygon is empty. -/
def isEmpty (poly : TessellatedPolygon) : Bool := poly.vertexCount == 0

end TessellatedPolygon

end Tessellation

end Afferent
