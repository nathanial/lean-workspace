# Add Timeout Tests with Mock Server

**Priority:** Medium
**Section:** Testing Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Timeout tests depend on httpbin.org's `/delay` endpoint which can be unreliable.

## Rationale
Consider using a local mock server for timeout testing reliability.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Tests/Main.lean:232-254`
