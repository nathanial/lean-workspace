---
id: 84
title: Expected Failure / Skip Test Support
status: closed
priority: medium
created: 2026-01-06T22:57:17
updated: 2026-01-06T23:31:59
labels: [feature]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Expected Failure / Skip Test Support

## Description
Add ability to mark tests as expected to fail (xfail) or to skip them conditionally. Common test framework feature for documenting known bugs without breaking CI, skipping platform-specific tests, and skipping tests that require external resources. Affected files: Crucible/Core.lean (TestCase.xfail, TestCase.skip, TestCase.skipIf), Crucible/Macros.lean (syntax like test "name" (skip := true)).

## Progress
- [2026-01-06T23:31:59] Closed: Implemented skip and xfail test support:
- Added SkipReason type and skip/xfail fields to TestCase
- Added TestOutcome type to track different test results
- Updated TestResults to track skipped, xfailed, and xpassed counts
- Added syntax: test "name" (skip := "reason") and test "name" (skip)
- Added syntax: test "name" (xfail := "reason") and test "name" (xfail)
- Updated runTest to handle skip (shows ⊘) and xfail (shows ✗ with xfail/XPASS labels)
- Updated summary to show all result types and percentages
- xfailed tests count as passing, xpassed tests count as failing
