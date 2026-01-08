---
id: 95
title: Consolidate Error Message Format
status: closed
priority: low
created: 2026-01-06T22:57:40
updated: 2026-01-08T07:48:54
labels: [cleanup]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Consolidate Error Message Format

## Description
Error messages across different assertions have slightly different formats. Some prefix with 'Expected', others with 'Assertion failed:'. Standardize error message format across all assertions for consistent output. Location: Crucible/Core.lean lines 40-105. Small effort.

## Progress
- [2026-01-08T07:48:54] Closed: Standardized error message formats across all assertions. Changed 'Assertion failed:' to 'Expected:', removed redundant phrases, unified containment and result assertion formats. Commit 3f2f72c, tagged v0.0.6.
