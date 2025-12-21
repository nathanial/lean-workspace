# Improve Float Parsing Robustness

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
The `parseFloat` function in `Parse.lean` (lines 82-103) is a basic implementation that:
- Does not handle negative numbers
- Does not handle scientific notation
- Does not handle leading zeros well

## Rationale
Improve the parser to handle more edge cases or use Lean's built-in parsing utilities if available.

More robust color parsing, fewer parsing failures.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Parse.lean`
