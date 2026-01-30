---
id: 483
title: Better error messages: Include Lua stack traces in error types
status: in-progress
priority: high
created: 2026-01-29T06:43:58
updated: 2026-01-30T07:18:08
labels: [enhancement]
assignee: 
project: selene
blocks: []
blocked_by: []
---

# Better error messages: Include Lua stack traces in error types

## Description


## Progress
- [2026-01-30T03:54:20] Added traceback-aware error handling in FFI/Lean and tests; investigating intermittent selene_tests crash when running without filters
- [2026-01-30T07:18:08] Implemented Lean-side callback registry with index-based C callbacks, removed debug logging, restored state close/ref finalizer, and corrected callback invocation signatures. Individual tests pass, but full selene_tests run still crashes when including coroutine yield/resume; likely remaining heap corruption to chase.
