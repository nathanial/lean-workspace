---
id: 96
title: Soft Assertions
status: open
priority: low
created: 2026-01-06T22:57:40
updated: 2026-01-06T22:57:40
labels: [feature]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Soft Assertions

## Description
Add assertions that record failures but don't stop test execution, allowing multiple checks per test. Sometimes useful to check multiple conditions and see all failures at once. Affected files: Crucible/Core.lean (add softAssert family of functions), possibly need a test context monad to track soft failures. Medium effort.

