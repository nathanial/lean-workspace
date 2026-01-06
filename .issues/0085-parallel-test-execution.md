---
id: 85
title: Parallel Test Execution
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

# Parallel Test Execution

## Description
Add option to run tests in parallel using Lean's task system. Large test suites (like ledger with 80+ tests, collimator with 200+ tests) would benefit from parallel execution. Currently all tests run sequentially. Affected files: Crucible/Core.lean (add runTestsParallel with configurable concurrency). May need fixture support to handle shared resource initialization.

