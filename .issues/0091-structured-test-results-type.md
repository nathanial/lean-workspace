---
id: 91
title: Structured Test Results Type
status: closed
priority: low
created: 2026-01-06T22:57:28
updated: 2026-01-07T00:15:30
labels: [improvement]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Structured Test Results Type

## Description
Current runAllSuites returns IO UInt32. Propose returning a structured TestResults type with pass/fail counts per suite, timing information, and a standard toExitCode method for richer reporting. Enables richer reporting, timing analysis, and programmatic access to results. Affected files: Crucible/Core.lean. Small effort.

## Progress
- [2026-01-07T00:15:30] Closed: Implemented per-suite breakdown in TestResults. Added SuiteResult type with name, counts, and timing. TestResults now has suites array with computed aggregate properties. runAllSuites/runAllSuitesFiltered now return IO TestResults with toExitCode method.
