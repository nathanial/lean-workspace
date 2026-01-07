---
id: 199
title: Separate Streaming Logic
status: open
priority: medium
created: 2026-01-07T01:10:03
updated: 2026-01-07T01:10:03
labels: [improvement]
assignee: 
project: enchiridion
blocks: []
blocked_by: []
---

# Separate Streaming Logic

## Description
AI streaming is handled inline in runLoop which makes the function very long and complex. Extract streaming management into a dedicated module or state machine.

