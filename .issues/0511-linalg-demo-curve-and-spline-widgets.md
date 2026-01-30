---
id: 511
title: Linalg Demo: Curve and Spline Widgets
status: open
priority: medium
created: 2026-01-30T02:28:06
updated: 2026-01-30T02:28:06
labels: []
assignee: 
project: afferent
blocks: []
blocked_by: []
---

# Linalg Demo: Curve and Spline Widgets

## Description
Create 5 curve and spline visualization widgets:

1. **BezierCurveEditor** - Quadratic/cubic Bezier with draggable control points. Shows control polygon, tangent vectors, de Casteljau construction animation. Slider for t parameter. Demonstrates Bezier2, Bezier3, evalVec2, derivativeVec2, splitVec2.

2. **CatmullRomSplineEditor** - Click to add control points, curve passes through all. Alpha parameter slider (uniform/centripetal/chordal). Open vs closed spline toggle. Demonstrates CatmullRom, SplinePath2, evalVec2 with different alpha values.

3. **BSplineCurveDemo** - B-spline with editable knot vector. Shows basis functions affecting curve. Variable degree (1-5). Demonstrates BSpline, BSpline.uniform, BSpline.evalVec2, basisFunction, local control property.

4. **ArcLengthParameterization** - Curve with regular vs arc-length parameterization comparison. Animated point showing constant vs variable speed. Demonstrates ArcLengthTable.build, sToT, uToT, totalLength.

5. **BezierPatchSurface** - 3D bicubic Bezier surface with 4x4 control point grid. Draggable control points, adjustable tessellation, normal visualization. Demonstrates BezierPatch, eval, normal, derivativeU/V, isocurves.

