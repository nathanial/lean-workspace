# Automatic Suite Discovery and Runner

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description

Add a `runAllSuites` function that automatically discovers and runs all registered test suites without requiring manual enumeration in `main`.

## Rationale

Currently, projects like `protolean`, `collimator`, and `wisp` must manually list each test suite in their `main` function (see `/Users/Shared/Projects/lean-workspace/protolean/Tests/Main.lean` lines 24-76). This is error-prone and requires updating when new test files are added. The `SuiteRegistry` already tracks suites via environment extension but provides no automatic runner.

## Affected Files

- `Crucible/SuiteRegistry.lean` - Add runner that iterates over `getAllSuites`
- `Crucible/Core.lean` - Add `runAllSuites : IO UInt32`
