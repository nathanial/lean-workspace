---
id: 128
title: Add named timezone support
status: closed
priority: medium
created: 2026-01-07T00:01:44
updated: 2026-01-08T06:53:25
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Add named timezone support

## Description
Support for IANA timezone names (e.g., 'America/New_York') beyond UTC and local time. API: Timezone structure, Timezone.fromName, DateTime.inTimezone. Complex due to platform differences - may need ICU or IANA tzdata.

## Progress
- [2026-01-08T06:53:25] Closed: Implemented IANA named timezone support with Timezone type, fromName, utc, localTz functions, and DateTime timezone conversion methods (inTimezone, fromTimestampInTimezone, toTimestampInTimezone, nowInTimezone). Uses portable TZ environment variable approach for cross-platform compatibility.
