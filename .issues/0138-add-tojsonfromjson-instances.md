---
id: 138
title: Add ToJson/FromJson instances
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

# Add ToJson/FromJson instances

## Description
No JSON serialization support. Add ToJson and FromJson instances for Timestamp and DateTime (ISO 8601 strings or epoch numbers). Consider optional dependency to avoid bloat.

## Progress
- [2026-01-07T00:54:41] Closed: Added ToJson/FromJson instances for Duration (as nanoseconds), Timestamp (as object), and DateTime (as ISO 8601 string). Added 7 JSON tests.
