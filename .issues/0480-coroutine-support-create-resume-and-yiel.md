---
id: 480
title: Coroutine support: Create, resume, and yield Lua coroutines from Lean
status: in-progress
priority: high
created: 2026-01-29T06:43:57
updated: 2026-01-29T08:17:04
labels: [feature]
assignee: 
project: selene
blocks: []
blocked_by: []
---

# Coroutine support: Create, resume, and yield Lua coroutines from Lean

## Description


## Progress
- [2026-01-29T06:51:54] Explored Selene codebase structure and Lua C API coroutine functions. Found existing Value.thread type, LUA_TTHREAD/LUA_YIELD constants already defined. Need to add FFI layer, C implementation, and high-level wrapper.
