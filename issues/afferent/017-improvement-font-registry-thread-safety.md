# Font Registry Thread Safety

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
FontRegistry uses a simple Array which may not be thread-safe for concurrent access.

## Rationale
Consider using thread-safe data structures or document single-threaded usage requirement.

Benefits: Safer concurrent font registration and lookup.

## Affected Files
- `Afferent/Text/Measurer.lean`
