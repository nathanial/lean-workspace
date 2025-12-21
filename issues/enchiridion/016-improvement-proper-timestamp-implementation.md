# Proper Timestamp Implementation

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`Timestamp.now` uses `IO.monoNanosNow` which returns monotonic time, not Unix epoch time. The conversion to milliseconds is also incorrect.

## Rationale
Use proper system time for timestamps. The comment says "milliseconds since Unix epoch" but the implementation uses monotonic nanoseconds.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Core/Types.lean` (lines 39-43)
