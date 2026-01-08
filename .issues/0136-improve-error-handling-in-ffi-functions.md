---
id: 136
title: Improve error handling in FFI functions
status: closed
priority: medium
created: 2026-01-07T00:02:15
updated: 2026-01-08T07:20:10
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Improve error handling in FFI functions

## Description
FFI functions can fail but return IO with potential exceptions. Use IO (Except Error a) or EIO for explicit error handling. Handle the -1 timestamp edge case by checking errno after timegm.

## Progress
- [2026-01-08T07:20:10] Closed: Added EIO-based error handling with ChronosError type. Fixed -1 timestamp edge case by checking errno after timegm/mktime calls. Added ChronosM monad (abbrev for EIO ChronosError) with liftIO, toIO, and run functions. Added E-suffixed versions of key functions (nowE, nowUtcE, nowLocalE, toTimestampE, fromTimestampUtcE, etc.).
