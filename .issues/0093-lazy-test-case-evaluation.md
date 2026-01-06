---
id: 93
title: Lazy Test Case Evaluation
status: open
priority: low
created: 2026-01-06T22:57:28
updated: 2026-01-06T22:57:28
labels: [improvement]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Lazy Test Case Evaluation

## Description
Currently all TestCase structures are created at module load time. Propose using thunks for the run field to defer test body construction until execution. Potentially faster startup for large test suites. Affected files: Crucible/Core.lean. Small effort.

