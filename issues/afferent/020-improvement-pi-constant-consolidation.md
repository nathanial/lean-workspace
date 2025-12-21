# Pi Constant Consolidation

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Pi is defined locally in multiple files (Path.lean, FPSCamera.lean, Seascape.lean).

## Rationale
Define Float.pi or Afferent.pi in a single location and use it everywhere.

Benefits: Consistency, reduced duplication.

## Affected Files
- `Afferent/Core/Path.lean`
- `Afferent/Render/FPSCamera.lean`
- `Demos/Seascape.lean`
