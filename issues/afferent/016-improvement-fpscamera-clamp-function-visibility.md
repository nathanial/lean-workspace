# FPSCamera Clamp Function Visibility

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
The clamp helper function in FPSCamera is marked private but could be useful elsewhere.

## Rationale
Move clamp to a shared utility module (e.g., Afferent.Core.Math or use Float.max/Float.min).

Benefits: Reduce code duplication, consistent utility functions.

## Affected Files
- `Afferent/Render/FPSCamera.lean` (line 34)
- New file or existing core module
