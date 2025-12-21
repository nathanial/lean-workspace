# Add Unit Tests for Edge Cases

**Priority:** Medium
**Section:** Testing Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Test suite focuses on integration tests against httpbin.org. Missing unit tests for:
- Header parsing edge cases (malformed headers, unusual encodings)
- SSE parser edge cases (partial chunks, missing fields)
- URL encoding edge cases
- Error handling paths

## Rationale
Add unit tests that don't require network access.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Tests/Main.lean`
