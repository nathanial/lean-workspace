# Add Module-Level Documentation

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Several modules lack module-level documentation:
- `Collimator/Exports.lean`
- `Collimator/Concrete/*.lean` (some have docs, some don't)
- Example files

## Rationale
Add `/-! ... -/` documentation blocks at the top of each module explaining its purpose, contents, and usage.

## Affected Files
- Various
