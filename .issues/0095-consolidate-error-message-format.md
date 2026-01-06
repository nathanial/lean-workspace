---
id: 95
title: Consolidate Error Message Format
status: open
priority: low
created: 2026-01-06T22:57:40
updated: 2026-01-06T22:57:40
labels: [cleanup]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Consolidate Error Message Format

## Description
Error messages across different assertions have slightly different formats. Some prefix with 'Expected', others with 'Assertion failed:'. Standardize error message format across all assertions for consistent output. Location: Crucible/Core.lean lines 40-105. Small effort.

