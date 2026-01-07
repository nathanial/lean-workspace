---
id: 195
title: Proper Timestamp Implementation
status: open
priority: high
created: 2026-01-07T01:10:01
updated: 2026-01-07T01:10:01
labels: [improvement]
assignee: 
project: enchiridion
blocks: []
blocked_by: []
---

# Proper Timestamp Implementation

## Description
Timestamp.now uses IO.monoNanosNow which returns monotonic time, not Unix epoch time. The conversion to milliseconds is also incorrect. Comment says 'milliseconds since Unix epoch' but uses monotonic nanoseconds.

