---
id: 4
title: Fix Float parsing in FromArg
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

# Fix Float parsing in FromArg

## Description
FromArg Float instance uses s.toNat?.map Float.ofNat which only parses integers, not actual floats. Implement proper float string parsing with decimal points, negative numbers, and scientific notation. Affects: Parse/Extractor.lean lines 29-30

