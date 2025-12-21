# Shadow and Glow Effects

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** May require additional render passes or blur shader

## Description
Add shadow/glow capabilities to the Canvas API, similar to HTML5 Canvas shadowBlur, shadowColor, shadowOffsetX/Y.

## Rationale
Shadows and glows are essential for modern UI design, depth perception, and visual effects.

## Affected Files
- `Afferent/Canvas/State.lean` (CanvasState structure)
- `Afferent/Canvas/Context.lean` (shadow rendering)
- `native/src/metal/` (blur shader or multi-pass rendering)
