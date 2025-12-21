# Standardize Error Handling

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Functions use a mix of `Option`, silent failures, and panicking patterns.

Action required:
1. Replace `!` indexing with safe alternatives where possible
2. Document expected failure modes
3. Consider a unified error type for widget operations

## Rationale
More robust and predictable error handling.

## Affected Files
- `HitTest.lean` - returns `Option` (good)
- `Collect.lean:91` - `let some computed := layouts.get w.id | return` (early return)
- `Renderer.lean:142` - `points[0]!` uses `!` indexing
