---
id: 215
title: Consolidate duplicate escape sequence handling
status: open
priority: low
created: 2026-01-07T03:50:07
updated: 2026-01-07T03:50:07
labels: [cleanup]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Consolidate duplicate escape sequence handling

## Description
The stringLiteral and charLiteral parsers in Sift/Text.lean both define identical escapeChar helper functions.

Location: Sift/Text.lean: lines 117-123 and 132-138

Action: Extract a shared escapeChar parser at the module level.

Effort: Small

