# Image/Texture Drawing in Canvas API

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add drawImage/drawTexture functions to the Canvas API for drawing textures with transformations.

## Rationale
While Renderer.drawSprites exists, there is no high-level Canvas API for texture drawing with transforms, clipping, and compositing.

## Affected Files
- `Afferent/Canvas/Context.lean` (new drawImage functions)
- `Afferent/FFI/Texture.lean` (may need additional FFI functions)
