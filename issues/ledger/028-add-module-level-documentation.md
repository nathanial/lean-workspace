# Add Module-Level Documentation

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
While files have header comments, they lack structured module documentation that would appear in generated docs.

## Rationale
Add `/-! ... -/` module documentation at the top of each file. Include module purpose, key types, and usage examples. Add `@[inherit_doc]` where appropriate.

## Affected Files
- All `.lean` files
