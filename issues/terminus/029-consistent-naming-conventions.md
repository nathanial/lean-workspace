# Consistent Naming Conventions

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Some naming inconsistencies exist:
- `withX` vs `setX` for builder methods
- `new` vs module-level constructors

## Rationale
Establish naming convention in documentation and refactor for consistency where feasible (may require deprecation warnings).

## Affected Files
- Throughout widget files
