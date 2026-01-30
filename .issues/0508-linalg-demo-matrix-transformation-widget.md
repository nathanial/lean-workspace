---
id: 508
title: Linalg Demo: Matrix Transformation Widgets
status: closed
priority: medium
created: 2026-01-30T02:28:06
updated: 2026-01-30T06:45:57
labels: []
assignee: 
project: afferent
blocks: []
blocked_by: []
---

# Linalg Demo: Matrix Transformation Widgets

## Description
Create 4 matrix transformation visualization widgets:

1. **Matrix2DTransformPlayground** - Shape (square/triangle) before and after matrix transform. Editable matrix cells with presets for scale, rotate, shear, reflect. Shows transformed grid and basis vectors. Demonstrates Mat2, Mat3, Affine2D, determinant visualization.

2. **Matrix3DTransformChain** - Stack of 3D transforms on an object. Drag to reorder transforms showing non-commutativity. Demonstrates Mat4.translation, Mat4.scaling, Mat4.rotationX/Y/Z, Mat4.multiply, Transform composition.

3. **ProjectionMatrixExplorer** - Visualize perspective and orthographic frustums. Objects in both world and clip space. Sliders for FOV, near/far, aspect. Demonstrates Mat4.perspective, Mat4.orthographic, Mat4.lookAt, Vec4 homogeneous coords.

4. **MatrixDecomposition** - Visual SVD decomposition showing rotation, scale, rotation components. Demonstrates matrix factorization concepts.

## Progress
- [2026-01-30T05:19:37] Reviewed linalg API (Mat2, Mat4, Affine2D) and existing demo patterns. Starting implementation of Matrix2DTransformPlayground.
- [2026-01-30T06:45:52] Implemented all 4 matrix transformation widgets: Matrix2DTransform (2D matrix playground with presets), Matrix3DTransform (3D transform chain), ProjectionExplorer (perspective/orthographic frustums), MatrixDecomposition (SVD-like visualization). Build succeeds.
- [2026-01-30T06:45:57] Closed: Implemented all 4 matrix transformation widgets: Matrix2DTransform (presets for rotation, scale, shear, reflect), Matrix3DTransform (reorderable transform chain), ProjectionExplorer (perspective/ortho frustum viz), MatrixDecomposition (rotation/scale decomposition). All widgets registered in DemoRegistry with keyboard controls.
