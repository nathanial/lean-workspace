---
id: 137
title: Fix negative timestamp handling for pre-epoch dates
status: closed
priority: medium
created: 2026-01-07T00:02:15
updated: 2026-01-07T00:54:41
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Fix negative timestamp handling for pre-epoch dates

## Description
fromNanoseconds may not correctly handle negative timestamps (dates before 1970). Audit and fix modulo behavior for negative values. Add tests for pre-epoch dates.

## Progress
- [2026-01-07T00:54:41] Closed: Fixed fromNanoseconds to use floor division (fdiv/fmod) for correct handling of negative values. Added 5 tests for pre-epoch timestamps.
