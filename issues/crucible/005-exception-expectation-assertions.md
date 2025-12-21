# Exception Expectation Assertions

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description

Add assertions to verify that code throws expected exceptions.

## Rationale

The pattern `| .error e => throw (IO.userError ...)` appears throughout test code. Need assertions like `shouldThrow`, `shouldThrowWith msg`, and `shouldNotThrow` for testing error handling code paths.

## Affected Files

- `Crucible/Core.lean` - Add `shouldThrow`, `shouldThrowMatching`
