/-
  Afferent FFI Renderer
  GPU rendering operations including frame management and drawing.
-/
import Afferent.Runtime.FFI.Types
import Afferent.Runtime.FFI.Init

namespace Afferent.FFI

-- Renderer management
@[extern "lean_afferent_renderer_create"]
opaque Renderer.create (window : @& Window) : IO Renderer

@[extern "lean_afferent_renderer_destroy"]
opaque Renderer.destroy (renderer : @& Renderer) : IO Unit

@[extern "lean_afferent_renderer_begin_frame"]
opaque Renderer.beginFrame (renderer : @& Renderer) (r g b a : Float) : IO Bool

@[extern "lean_afferent_renderer_end_frame"]
opaque Renderer.endFrame (renderer : @& Renderer) : IO Unit

-- Override drawable pixel scale (1.0 disables Retina). Pass 0 to restore native scale.
@[extern "lean_afferent_renderer_set_drawable_scale"]
opaque Renderer.setDrawableScale (renderer : @& Renderer) (scale : Float) : IO Unit

-- Buffer management
-- Vertices: Array of Float, 6 per vertex (pos.x, pos.y, color.r, color.g, color.b, color.a)
@[extern "lean_afferent_buffer_create_vertex"]
opaque Buffer.createVertex (renderer : @& Renderer) (vertices : @& Array Float) : IO Buffer

-- Stroke vertices: Array of Float, 5 per vertex (pos.x, pos.y, nx, ny, side)
@[extern "lean_afferent_buffer_create_stroke_vertex"]
opaque Buffer.createStrokeVertex (renderer : @& Renderer) (vertices : @& Array Float) : IO Buffer

-- Stroke segments: Array of Float, 18 per segment (packed parametric segment data)
@[extern "lean_afferent_buffer_create_stroke_segment"]
opaque Buffer.createStrokeSegment (renderer : @& Renderer) (segments : @& Array Float) : IO Buffer

-- Persistent stroke segments (not pooled): Array of Float, 18 per segment
@[extern "lean_afferent_buffer_create_stroke_segment_persistent"]
opaque Buffer.createStrokeSegmentPersistent (renderer : @& Renderer) (segments : @& Array Float) : IO Buffer

-- Indices: Array of UInt32
@[extern "lean_afferent_buffer_create_index"]
opaque Buffer.createIndex (renderer : @& Renderer) (indices : @& Array UInt32) : IO Buffer

@[extern "lean_afferent_buffer_destroy"]
opaque Buffer.destroy (buffer : @& Buffer) : IO Unit

-- Drawing
@[extern "lean_afferent_renderer_draw_triangles"]
opaque Renderer.drawTriangles
  (renderer : @& Renderer)
  (vertexBuffer indexBuffer : @& Buffer)
  (indexCount : UInt32) : IO Unit

-- Draw triangles with screen-space coordinates (GPU converts to NDC)
-- vertexData: [x, y, r, g, b, a] per vertex (6 floats) in pixel coordinates
-- indices: triangle indices
@[extern "lean_afferent_renderer_draw_triangles_screen_coords"]
opaque Renderer.drawTrianglesScreenCoords
  (renderer : @& Renderer)
  (vertexData : @& Array Float)
  (indices : @& Array UInt32)
  (vertexCount : UInt32)
  (canvasWidth canvasHeight : Float) : IO Unit

-- Draw extruded strokes (screen-space width)
@[extern "lean_afferent_renderer_draw_stroke"]
opaque Renderer.drawStroke
  (renderer : @& Renderer)
  (vertexBuffer indexBuffer : @& Buffer)
  (indexCount : UInt32)
  (halfWidth : Float)
  (canvasWidth : Float)
  (canvasHeight : Float)
  (r g b a : Float) : IO Unit

-- Draw GPU-extruded strokes from parametric segments
@[extern "lean_afferent_renderer_draw_stroke_path"]
opaque Renderer.drawStrokePath
  (renderer : @& Renderer)
  (segmentBuffer : @& Buffer)
  (segmentCount : UInt32)
  (segmentSubdivisions : UInt32)
  (halfWidth : Float)
  (canvasWidth : Float)
  (canvasHeight : Float)
  (miterLimit : Float)
  (lineCap : UInt32)
  (lineJoin : UInt32)
  (transformA : Float)
  (transformB : Float)
  (transformC : Float)
  (transformD : Float)
  (transformTx : Float)
  (transformTy : Float)
  (dashSegments : @& Array Float)
  (dashCount : UInt32)
  (dashOffset : Float)
  (r g b a : Float) : IO Unit

-- Scissor rect for clipping
@[extern "lean_afferent_renderer_set_scissor"]
opaque Renderer.setScissor
  (renderer : @& Renderer)
  (x y width height : UInt32) : IO Unit

@[extern "lean_afferent_renderer_reset_scissor"]
opaque Renderer.resetScissor (renderer : @& Renderer) : IO Unit

end Afferent.FFI
