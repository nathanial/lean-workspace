---
id: 87
title: Better Test Output Formatting
status: open
priority: medium
created: 2026-01-06T22:57:18
updated: 2026-01-06T22:57:18
labels: [feature]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Better Test Output Formatting

## Description
Improve test output with colors, progress indicators, and summary statistics. Enhanced formatting could include: colored pass/fail indicators (green checkmark, red X), progress bar for long test runs, timing information per test, summary with total time and pass/fail counts by suite. Affected files: Crucible/Core.lean (enhance runTest and runTests), new Crucible/Output.lean for formatting utilities.

