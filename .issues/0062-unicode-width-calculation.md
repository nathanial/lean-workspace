---
id: 62
title: Unicode Width Calculation
status: closed
priority: high
created: 2026-01-06T22:46:10
updated: 2026-01-06T23:47:36
labels: [improvement]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Unicode Width Calculation

## Description
Wide characters (CJK, emoji) are treated as single-width in cell positioning, causing display issues. Implement Unicode width calculation (wcwidth equivalent) and handle double-width characters properly in Buffer operations. Affects: Terminus/Core/Cell.lean, Terminus/Core/Buffer.lean, new Terminus/Core/Unicode.lean

## Progress
- [2026-01-06T23:47:36] Closed: Implemented Unicode width calculation (wcwidth equivalent). Created new Terminus/Core/Unicode.lean module with Char.displayWidth and String.displayWidth. Updated Cell.lean with isPlaceholder field for wide characters. Updated Buffer write functions, Paragraph, Block, TextInput, and TextArea to be display-width aware. Added 12 new tests. All 341 tests pass.
