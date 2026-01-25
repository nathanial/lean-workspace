---
id: 402
title: add task-management hooks to agent loop
status: closed
priority: medium
created: 2026-01-25T01:57:17
updated: 2026-01-25T02:31:55
labels: []
assignee: 
project: oracle
blocks: []
blocked_by: []
---

# add task-management hooks to agent loop

## Description
runAgentLoop is synchronous and only bounded by maxIterations; add cancellation/stop conditions and progress or state hooks for external task management (Oracle/Agent/Loop.lean, Oracle/Agent/Types.lean).

## Progress
- [2026-01-25T02:31:50] Added AgentHooks with stop/state callbacks, new stopped state, and tests covering stop and onState hooks.
- [2026-01-25T02:31:55] Closed: Added AgentHooks for stop/onState callbacks, integrated stop checks in agent step, and added tests.
