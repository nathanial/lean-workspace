# Pattern and Image Fills

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** Requires UV coordinate generation in tessellation and texture binding in the 2D rendering pipeline

## Description
Add support for pattern/texture fills in addition to solid colors and gradients. The FillStyle enum already has a commented placeholder for `pattern (p : Pattern)`.

## Rationale
Pattern fills are essential for many graphics applications (tiled backgrounds, hatching, textures). The infrastructure exists but the feature is not implemented.

## Affected Files
- `Afferent/Core/Paint.lean` (FillStyle enum)
- `Afferent/Render/Tessellation.lean` (sampleFillStyle, vertex UV generation)
- `native/src/metal/` (shader support for texture sampling in 2D pipeline)
