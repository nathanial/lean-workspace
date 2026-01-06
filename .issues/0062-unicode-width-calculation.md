---
id: 62
title: Unicode Width Calculation
status: open
priority: high
created: 2026-01-06T22:46:10
updated: 2026-01-06T22:46:10
labels: [improvement]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Unicode Width Calculation

## Description
Wide characters (CJK, emoji) are treated as single-width in cell positioning, causing display issues. Implement Unicode width calculation (wcwidth equivalent) and handle double-width characters properly in Buffer operations. Affects: Terminus/Core/Cell.lean, Terminus/Core/Buffer.lean, new Terminus/Core/Unicode.lean

