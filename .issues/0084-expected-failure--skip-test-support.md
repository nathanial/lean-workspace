---
id: 84
title: Expected Failure / Skip Test Support
status: open
priority: medium
created: 2026-01-06T22:57:17
updated: 2026-01-06T22:57:17
labels: [feature]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Expected Failure / Skip Test Support

## Description
Add ability to mark tests as expected to fail (xfail) or to skip them conditionally. Common test framework feature for documenting known bugs without breaking CI, skipping platform-specific tests, and skipping tests that require external resources. Affected files: Crucible/Core.lean (TestCase.xfail, TestCase.skip, TestCase.skipIf), Crucible/Macros.lean (syntax like test "name" (skip := true)).

