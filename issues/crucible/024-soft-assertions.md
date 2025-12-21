# Soft Assertions

**Priority:** Low
**Section:** API Enhancements
**Estimated Effort:** Medium
**Dependencies:** None

## Description

Add assertions that record failures but don't stop test execution, allowing multiple checks per test.

## Rationale

Sometimes useful to check multiple conditions and see all failures at once.

## Affected Files

- `Crucible/Core.lean` - Add `softAssert` family of functions
- Possibly need a test context monad to track soft failures
