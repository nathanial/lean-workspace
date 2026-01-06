---
id: 15
title: Fluent command builder
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

# Fluent command builder

## Description
Add method chaining style for command building as alternative to the monad. Proposed: Command.new "myapp" |>.withVersion "1.0" |>.withFlag (Flag.long "verbose" |>.short 'v'). Affects: Core/Types.lean (add fluent methods), Command/Builder.lean

