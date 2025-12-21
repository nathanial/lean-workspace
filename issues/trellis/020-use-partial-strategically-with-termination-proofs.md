# Use `partial` Strategically with Termination Proofs

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
`layoutNode` is marked `partial` without a termination proof (line 891). Similarly, `nodeCount` and `allIds` in Node.lean (lines 221-226).

Proposed change: Add `termination_by` clauses or refactor to use `Nat.rec` patterns to prove termination.

## Rationale
Stronger correctness guarantees, avoidance of potential infinite loops.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean` (line 891)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Node.lean` (lines 221-226)
