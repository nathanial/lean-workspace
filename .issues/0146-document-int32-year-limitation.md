---
id: 146
title: Document Int32 year limitation
status: open
priority: low
created: 2026-01-07T00:02:32
updated: 2026-01-07T00:02:32
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Document Int32 year limitation

## Description
DateTime.year is Int32, limiting representable years. Differs from Timestamp.seconds which is Int. Document the limitation or consider using Int for scientific/astronomical applications. Location: Chronos/DateTime.lean:12

