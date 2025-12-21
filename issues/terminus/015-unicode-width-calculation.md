# Unicode Width Calculation

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Wide characters (CJK, emoji) are treated as single-width in cell positioning, causing display issues.

## Rationale
Implement Unicode width calculation (wcwidth equivalent) and handle double-width characters properly in Buffer operations.

Correct display of international text and emoji.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Core/Cell.lean`
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Core/Buffer.lean`
- New file: `Terminus/Core/Unicode.lean`
