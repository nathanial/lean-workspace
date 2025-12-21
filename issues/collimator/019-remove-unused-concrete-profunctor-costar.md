# Remove Unused Concrete Profunctor: Costar

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
The `Collimator/Concrete/Costar.lean` file defines `Costar` profunctor but it may not be used anywhere in the library.

## Rationale
Search for usages of `Costar` in the codebase. If unused, either document its intended purpose or remove it. If used, ensure it's properly exported.

## Affected Files
- `Collimator/Concrete/Costar.lean`
