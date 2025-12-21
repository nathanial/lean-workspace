# Consistent Naming Conventions

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Some inconsistencies in naming:
- `text'` uses prime suffix (Lean convention for variants)
- `namedText` uses prefix (clearer intent)
- `hitTestId` vs `hitTestPath` vs `hitTest` (good, but could add `hitTestWidget`)

Action required:
1. Decide on consistent naming pattern
2. Add aliases for discoverability if needed

## Rationale
Consistent, predictable API.

## Affected Files
- `Arbor/Widget/DSL.lean`
- `Arbor/Event/HitTest.lean`
