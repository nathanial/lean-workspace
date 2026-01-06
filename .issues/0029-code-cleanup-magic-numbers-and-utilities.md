---
id: 29
title: Code cleanup: magic numbers and utilities
status: open
priority: low
created: 2026-01-06T14:48:37
updated: 2026-01-06T14:48:37
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Code cleanup: magic numbers and utilities

## Description
Several cleanup items: (1) Replace magic numbers with named constants (descColumn := 24, width := 80, etc), (2) Extract common padding utilities from Help.lean and Table.lean, (3) Remove or implement unused Token.shortFlagValue, (4) Fix inconsistent error message formats

