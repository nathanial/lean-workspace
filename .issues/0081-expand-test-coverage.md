---
id: 81
title: Expand Test Coverage
status: closed
priority: high
created: 2026-01-06T22:46:55
updated: 2026-01-06T23:05:47
labels: [testing]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Expand Test Coverage

## Description
Current coverage: TerminalEffect mock, key/escape sequence parsing well tested; event polling has basic tests. Missing: widget rendering, layout calculations, style merging, buffer operations, canvas/chart drawing. Create buffer comparison utilities, add unit tests for each widget, add property-based tests for layout algorithms.

## Progress
- [2026-01-06T23:05:47] Closed: Added 95 new tests for 8 previously untested widgets (Clear, Scrollbar, ScrollView, Form, Logger, BigText, Canvas, Image). Test coverage increased from 234 to 329 tests.
