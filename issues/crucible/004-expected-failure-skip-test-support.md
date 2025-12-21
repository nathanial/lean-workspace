# Expected Failure / Skip Test Support

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description

Add ability to mark tests as expected to fail (`xfail`) or to skip them conditionally.

## Rationale

Common test framework feature for:
- Documenting known bugs without breaking CI
- Skipping platform-specific tests
- Skipping tests that require external resources

## Affected Files

- `Crucible/Core.lean` - Add `TestCase.xfail`, `TestCase.skip`, `TestCase.skipIf`
- `Crucible/Macros.lean` - Add syntax like `test "name" (skip := true) := do`
