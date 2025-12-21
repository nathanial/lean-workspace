# Float.sin/cos Performance

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Several widgets (charts, animations) use Float.sin/cos which may be slower than lookup tables for animation use cases.

## Rationale
Implement fast approximate trig functions or lookup tables for animation-quality rendering.

Better performance for animated UIs.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/examples/KitchenSink.lean`
- Chart widgets
