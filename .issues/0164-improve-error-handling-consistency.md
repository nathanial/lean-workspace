---
id: 164
title: Improve error handling consistency
status: open
priority: medium
created: 2026-01-07T00:11:05
updated: 2026-01-07T00:11:05
labels: [refactor]
assignee: 
project: tracker
blocks: []
blocked_by: []
---

# Improve error handling consistency

## Description
Mix of Option, IO.userError, and Except for error handling across modules. Standardize on Except String or custom TrackerError type for predictable error propagation.

