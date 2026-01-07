---
id: 136
title: Improve error handling in FFI functions
status: open
priority: medium
created: 2026-01-07T00:02:15
updated: 2026-01-07T00:02:15
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Improve error handling in FFI functions

## Description
FFI functions can fail but return IO with potential exceptions. Use IO (Except Error a) or EIO for explicit error handling. Handle the -1 timestamp edge case by checking errno after timegm.

