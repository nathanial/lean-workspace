---
id: 134
title: Add DecidableEq and decidable ordering
status: closed
priority: high
created: 2026-01-07T00:02:14
updated: 2026-01-07T00:17:01
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Add DecidableEq and decidable ordering

## Description
Types implement Ord, LT, LE but not DecidableEq or decidable ordering proofs. Add decidable instances for use in dependent types and theorem proving.

## Progress
- [2026-01-07T00:17:01] Closed: Added DecidableEq to Duration, Timestamp, DateTime, Weekday, and MonotonicTime. Added decidable ordering instances for LT/LE on all types. Renamed Weekday.ofNat to Weekday.fromNat to avoid conflict with auto-generated definition.
