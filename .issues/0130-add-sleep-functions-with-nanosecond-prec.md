---
id: 130
title: Add sleep functions with nanosecond precision
status: open
priority: low
created: 2026-01-07T00:01:55
updated: 2026-01-07T00:01:55
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Add sleep functions with nanosecond precision

## Description
Add cross-platform sleep functions. API: Chronos.sleep (Duration -> IO Unit), Chronos.sleepUntil (Timestamp -> IO Unit). Requires nanosleep FFI binding. Depends on Duration type.

