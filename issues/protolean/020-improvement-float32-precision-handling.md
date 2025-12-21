# Float32 Precision Handling

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Improve float32/float64 conversion to handle edge cases better.

## Rationale
`/Users/Shared/Projects/lean-workspace/protolean/Protolean/Encoder.lean` (lines 104-133) and `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Decoder.lean` (lines 203-235) have inline float conversion with limited denormal handling. Extract to separate module, add property-based tests for edge cases, consider FFI for IEEE754 compliance.

Benefits: Correct handling of denormals, NaN payloads, and edge cases

## Affected Files
- Create `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Float.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Encoder.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Decoder.lean`
