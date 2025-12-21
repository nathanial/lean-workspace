# Test Timeout Support

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description

Add ability to specify timeouts for individual tests or test suites.

## Rationale

Tests that involve I/O, network calls, or complex computations may hang. The wisp tests at `/Users/Shared/Projects/lean-workspace/wisp/Tests/Main.lean` demonstrate real-world need for timeouts (lines 233-253). Having timeout support built into the framework prevents hung test runs.

## Affected Files

- `Crucible/Core.lean` - Add `TestCase.withTimeout` or `runTestWithTimeout`
- `Crucible/Macros.lean` - Add syntax for `test "name" (timeout := 5000) := do`
