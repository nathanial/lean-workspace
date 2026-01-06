---
id: 11
title: Flag groups and mutual exclusion
status: open
priority: medium
created: 2026-01-06T14:47:48
updated: 2026-01-06T14:47:48
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Flag groups and mutual exclusion

## Description
Support grouping related flags and defining mutually exclusive flag sets (e.g., --json vs --table for output format). Add FlagGroup type, group field to Flag. Validate after parsing, generate conflictingFlags error. Group flags visually in help. Affects: Core/Types.lean, Parse/Parser.lean, Core/Error.lean, Command/Help.lean

