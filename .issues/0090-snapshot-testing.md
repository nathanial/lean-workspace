---
id: 90
title: Snapshot Testing
status: open
priority: low
created: 2026-01-06T22:57:18
updated: 2026-01-06T22:57:18
labels: [feature]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Snapshot Testing

## Description
Add support for snapshot testing where expected output is stored in files and compared against actual output. Useful for testing complex output (rendered text, serialized data) without writing complex equality checks. Affected files: new Crucible/Snapshot.lean for snapshot management and comparison. Large effort.

