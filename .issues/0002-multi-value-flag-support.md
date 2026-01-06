---
id: 2
title: Multi-value flag support
status: open
priority: high
created: 2026-01-06T14:47:03
updated: 2026-01-06T14:47:03
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Multi-value flag support

## Description
Support flags that can be specified multiple times to collect multiple values (e.g., -I path1 -I path2). Common pattern in compilers and build tools. Add repeatable:Bool to Flag type, accumulate values in parser. Affects: Core/Types.lean, Parse/Parser.lean, Parse/Extractor.lean

