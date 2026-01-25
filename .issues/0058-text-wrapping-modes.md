---
id: 58
title: Text Wrapping Modes
status: closed
priority: medium
created: 2026-01-06T22:45:46
updated: 2026-01-25T01:51:53
labels: [feature]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Text Wrapping Modes

## Description
Implement multiple text wrapping modes for Paragraph widget: word wrap, character wrap, no wrap with horizontal scroll. Would improve text display quality. Affects: Terminus/Widgets/Paragraph.lean, new Terminus/Core/ text utilities

## Progress
- [2026-01-25T01:51:53] Closed: Implemented Unicode-aware text wrapping (displayWidth for CJK/emoji) and horizontal scrolling with scrollableParagraph' widget. Added 27 tests and demo examples.
