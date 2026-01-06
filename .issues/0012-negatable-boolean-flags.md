---
id: 12
title: Negatable boolean flags
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

# Negatable boolean flags

## Description
Automatically support --no-<flag> variants for boolean flags. POSIX convention (e.g., --color / --no-color). Add negatable:Bool to Flag, handle --no- prefix in parser, display in help. Affects: Core/Types.lean, Parse/Parser.lean, Command/Help.lean

