# Document Vertex Layout Constants

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Vertex layouts (6 floats for 2D, 10 floats for 3D, 12 floats for textured 3D) are documented in comments but could benefit from named constants.

## Rationale
Define constants like VERTEX_SIZE_2D = 6, VERTEX_SIZE_3D = 10, VERTEX_SIZE_TEXTURED = 12.

## Affected Files
- `Afferent/Render/Tessellation.lean` (multiple locations)
- `Afferent/FFI/Renderer3D.lean`
- `Afferent/FFI/Asset.lean`
