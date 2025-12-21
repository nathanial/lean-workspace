# Dashed and Dotted Lines

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add support for dashed and dotted line patterns in StrokeStyle.

## Rationale
Dashed lines are a common requirement for charts, borders, selection indicators, and technical drawings.

## Affected Files
- `Afferent/Core/Paint.lean` (StrokeStyle structure)
- `Afferent/Render/Tessellation.lean` (stroke tessellation)
