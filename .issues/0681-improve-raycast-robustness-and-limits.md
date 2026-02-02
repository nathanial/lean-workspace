---
id: 681
title: Improve raycast robustness and limits
status: closed
priority: medium
created: 2026-02-02T05:45:44
updated: 2026-02-02T05:57:19
labels: []
assignee: 
project: cairn
blocks: []
blocked_by: []
---

# Improve raycast robustness and limits

## Description
handle zero-length direction, derive iteration cap from maxDistance, and cover diagonal/inside-block cases

## Progress
- [2026-02-02T05:57:17] guard zero-length direction, derive iteration cap from maxDistance, add raycast edge-case tests
- [2026-02-02T05:57:19] Closed: add zero-direction guard, dynamic iteration cap, and raycast edge-case tests
