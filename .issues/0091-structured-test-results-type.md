---
id: 91
title: Structured Test Results Type
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

# Structured Test Results Type

## Description
Current runAllSuites returns IO UInt32. Propose returning a structured TestResults type with pass/fail counts per suite, timing information, and a standard toExitCode method for richer reporting. Enables richer reporting, timing analysis, and programmatic access to results. Affected files: Crucible/Core.lean. Small effort.

