# Parallel Test Execution

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** May need fixture support to handle shared resource initialization

## Description

Add option to run tests in parallel using Lean's task system.

## Rationale

Large test suites (like ledger with 80+ tests, collimator with 200+ tests) would benefit from parallel execution. Currently all tests run sequentially.

## Affected Files

- `Crucible/Core.lean` - Add `runTestsParallel` with configurable concurrency
