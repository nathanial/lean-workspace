---
id: 215
title: Consolidate duplicate escape sequence handling
status: closed
priority: low
created: 2026-01-07T03:50:07
updated: 2026-01-09T01:35:41
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

## Progress
- [2026-01-09T01:33:10] Found duplicate escapeChar helpers in Sift/Text.lean (stringLiteral and charLiteral). They only differ in which quote is allowed; can extract escapeChar (quote : Char) at module scope and reuse in both.
- [2026-01-09T01:35:41] Closed: Extracted shared escapeChar helper and added tests for escaped quotes; build/tests pass.
