---
id: 81
title: Expand Test Coverage
status: open
priority: high
created: 2026-01-06T22:46:55
updated: 2026-01-06T22:46:55
labels: [testing]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Expand Test Coverage

## Description
Current coverage: TerminalEffect mock, key/escape sequence parsing well tested; event polling has basic tests. Missing: widget rendering, layout calculations, style merging, buffer operations, canvas/chart drawing. Create buffer comparison utilities, add unit tests for each widget, add property-based tests for layout algorithms.

