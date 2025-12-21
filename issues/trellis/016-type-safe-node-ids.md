# Type-Safe Node IDs

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Node IDs are raw `Nat` values that can be confused with other numeric values.

Proposed change: Create an opaque `NodeId` type to prevent accidental misuse of numeric values as node identifiers.

## Rationale
Compile-time prevention of ID misuse, clearer API contracts.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Node.lean` (lines 78-85)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Result.lean`
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean`
