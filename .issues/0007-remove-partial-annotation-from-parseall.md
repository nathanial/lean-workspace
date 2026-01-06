---
id: 7
title: Remove partial annotation from parseAll
status: open
priority: high
created: 2026-01-06T14:47:16
updated: 2026-01-06T14:47:16
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Remove partial annotation from parseAll

## Description
ParserM.parseAll is marked partial due to recursive structure. Refactor to use well-founded recursion on token list length. Location: Parse/Parser.lean line 181

