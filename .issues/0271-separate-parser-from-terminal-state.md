---
id: 271
title: Separate Parser from Terminal State
status: open
priority: medium
created: 2026-01-07T04:09:07
updated: 2026-01-07T04:09:07
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Separate Parser from Terminal State

## Description
Parser and terminal state are tightly coupled through Action type. Make Action type more abstract; terminal could implement an ActionHandler trait. Easier testing, potential reuse of parser in other contexts. Affects: Vane/Parser/Types.lean, Vane/Terminal/Executor.lean

