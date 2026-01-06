---
id: 111
title: Implement GridAutoFlow in autoPlaceItem
status: open
priority: high
created: 2026-01-06T23:29:20
updated: 2026-01-06T23:29:20
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Implement GridAutoFlow in autoPlaceItem

## Description
The _flow parameter in autoPlaceItem is prefixed with underscore indicating it's unused, but GridAutoFlow should affect placement behavior (row vs column major, dense packing). Either implement flow-aware placement or document why it's not implemented. Effort: Small-Medium

