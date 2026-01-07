---
id: 255
title: Add Private Marker to CSI Dispatch
status: open
priority: medium
created: 2026-01-07T04:08:09
updated: 2026-01-07T04:08:09
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Add Private Marker to CSI Dispatch

## Description
privateMarker is tracked in parser state but not passed to TerminalCommand.fromCSI. Pass private marker to CSI dispatch for proper ? sequence handling. Affects: Vane/Parser/Machine.lean, Vane/Parser/CSI.lean

