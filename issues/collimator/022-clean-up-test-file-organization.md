# Clean Up Test File Organization

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Tests are well-written but some test files are very long (e.g., `TraversalTests.lean` at 1183 lines).

## Rationale
Consider splitting large test files by category (e.g., `TraversalTests/Laws.lean`, `TraversalTests/Effectful.lean`). Extract common test utilities to a shared module. Ensure consistent naming conventions.

## Affected Files
- `CollimatorTests/`
