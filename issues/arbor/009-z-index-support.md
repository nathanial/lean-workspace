# Z-Index Support

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Allow widgets to specify explicit z-ordering independent of tree order.

## Rationale
Currently z-order is determined by tree traversal order. Explicit z-index would allow popups, tooltips, and overlays to render on top.

## Affected Files
- `Arbor/Widget/Core.lean` - add `zIndex` field
- `Arbor/Render/Collect.lean` - sort commands by z-index
