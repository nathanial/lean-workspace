# Buffer Diff Optimization

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The `diff` function in Buffer.lean iterates through all cells, but could be optimized for common patterns.

## Rationale
Implement dirty region tracking or use a more efficient diffing algorithm (e.g., row-level checksums).

Reduced rendering overhead for large terminals.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Core/Buffer.lean`
