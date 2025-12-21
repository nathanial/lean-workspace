# Add Property-Based Tests

**Priority:** High
**Section:** Testing Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Current tests are example-based. Property-based testing would catch edge cases.

Action required:
1. Add Plausible dependency (already available in tincture)
2. Test properties like:
   - `measureWidget` is idempotent
   - `collectCommands` produces valid command sequences (balanced push/pop)
   - Hit testing respects widget bounds

## Rationale
Better test coverage, catches edge cases.

## Affected Files
- `ArborTests/Main.lean`
