# Test Event Dispatch

**Priority:** Medium
**Section:** Testing Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Event dispatch logic in `Arbor/App/UI.lean` has no dedicated tests.

Action required:
1. Create `ArborTests/EventTests.lean`
2. Test bubbling, capture, stop propagation
3. Test handler registration and lookup

## Rationale
Critical functionality needs comprehensive testing.

## Affected Files
New test file needed
