# Test Fixtures / Setup-Teardown Hooks

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description

Add support for setup/teardown code that runs before/after each test or test suite.

## Rationale

Many tests need shared setup (database connections, file creation, network clients). The wisp tests show this pattern at `/Users/Shared/Projects/lean-workspace/wisp/Tests/Main.lean` lines 883-915 with manual `globalInit`/`globalCleanup` calls in main.

## Affected Files

- `Crucible/Core.lean` - Add `TestSuite` structure with `beforeAll`, `afterAll`, `beforeEach`, `afterEach` hooks
- `Crucible/SuiteRegistry.lean` - Update `SuiteInfo` to include hook references
