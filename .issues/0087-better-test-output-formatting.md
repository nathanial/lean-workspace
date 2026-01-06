---
id: 87
title: Better Test Output Formatting
status: closed
priority: medium
created: 2026-01-06T22:57:18
updated: 2026-01-06T23:47:48
labels: [feature]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Better Test Output Formatting

## Description
Improve test output with colors, progress indicators, and summary statistics. Enhanced formatting could include: colored pass/fail indicators (green checkmark, red X), progress bar for long test runs, timing information per test, summary with total time and pass/fail counts by suite. Affected files: Crucible/Core.lean (enhance runTest and runTests), new Crucible/Output.lean for formatting utilities.

## Progress
- [2026-01-06T23:47:48] Closed: Implemented colored output with timing and progress indicators:
- Created Crucible/Output.lean with ANSI color utilities
- Added per-test timing display (0ms, 12ms, etc.)
- Added progress indicators [1/5], [2/5], etc.
- Colored symbols: green ✓, red ✗, yellow ⊘
- Colored summary: bold green passed, red failed (if any), yellow skipped/xfailed
- Percentage colored based on pass rate (100% green, 80%+ light green, etc.)
- Dim styling for progress indicators, timing, and borders
