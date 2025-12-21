# Matrix4 Performance

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small to Medium
**Dependencies:** None

## Description
Matrix4.multiply creates intermediate arrays and uses nested loops with getD.

## Rationale
Implement matrix multiplication with inline expanded operations or SIMD intrinsics in native code.

Benefits: Faster 3D transforms, especially for scenes with many objects.

## Affected Files
- `Afferent/Render/Matrix4.lean` (multiply function)
- Optionally: new FFI for matrix operations
