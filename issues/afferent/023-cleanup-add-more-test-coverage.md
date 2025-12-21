# Add More Test Coverage

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Tests exist for tessellation and FFI safety but coverage could be expanded for Canvas, Widget rendering, and gradient sampling edge cases.

## Rationale
Add:
- CanvasState transform composition tests
- Gradient edge case tests (empty stops, single stop)
- Font loading and measurement tests

## Affected Files
- `Afferent/Tests/` directory
- `AfferentTests.lean`
