# Round Line Caps and Joins

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None. Requires generating arc geometry for round elements

## Description
Implement proper round line caps and line joins for stroke rendering. Currently `LineCap.round` and `LineJoin.round` fall back to butt caps and miter joins respectively.

## Rationale
Round caps and joins are commonly needed for smooth graphics and are part of the standard Canvas API.

## Affected Files
- `Afferent/Render/Tessellation.lean` (expandPolylineToStroke function, lines 529, 555-558, 603-609)
