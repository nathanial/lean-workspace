# Replace HashMap with Lean4 Standard HashMap

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Use Lean.HashMap instead of Std.HashMap for consistency.

## Rationale
Multiple files import `Std.Data.HashMap` (e.g., `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Map.lean`, `/Users/Shared/Projects/lean-workspace/protolean/Protolean/WellKnown.lean`). Evaluate whether Lean.HashMap or Std.HashMap is more appropriate and use consistently.

Benefits: Reduced dependencies, consistency

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Map.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/WellKnown.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Types.lean`
