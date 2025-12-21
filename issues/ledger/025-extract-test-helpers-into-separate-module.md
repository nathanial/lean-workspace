# Extract Test Helpers into Separate Module

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The test file `Tests/Main.lean` is 945 lines and contains all test cases. No test helper utilities are extracted.

## Rationale
Create `Tests/Helpers.lean` with common test setup (create test db, populate test data). Split tests into topic-specific files: `Tests/Core.lean`, `Tests/Query.lean`, `Tests/Pull.lean`, etc. Use shared fixtures for common scenarios.

## Affected Files
- `Tests/Main.lean`
