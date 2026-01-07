---
id: 123
title: Add DateTime parsing from ISO 8601 strings
status: closed
priority: high
created: 2026-01-07T00:01:29
updated: 2026-01-07T00:08:43
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Add DateTime parsing from ISO 8601 strings

## Description
Add parsing capabilities to construct DateTime from ISO 8601 strings. API: DateTime.parseIso8601, DateTime.parseDate (YYYY-MM-DD), DateTime.parseTime (HH:MM:SS). Enables interoperability with external data sources (JSON APIs, config files).

## Progress
- [2026-01-07T00:08:43] Closed: Already implemented: parseIso8601, parseDate, parseTime with full validation and fractional seconds support
