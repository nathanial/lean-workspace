---
id: 40
title: Simplify printStreamMarkdown Function
status: open
priority: medium
created: 2026-01-06T15:15:41
updated: 2026-01-06T15:15:41
labels: []
assignee: 
project: ask
blocks: []
blocked_by: []
---

# Simplify printStreamMarkdown Function

## Description
Refactor Main.lean lines 16-56. Current uses multiple IO.mkRef for state. Consider single state structure or StateT monad for cleaner threading.

