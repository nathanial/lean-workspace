---
id: 118
title: Clean Up Import Structure
status: open
priority: low
created: 2026-01-06T23:29:21
updated: 2026-01-06T23:29:21
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Clean Up Import Structure

## Description
Algorithm.lean imports all other modules but some imports may be transitively satisfied. Review import graph and minimize direct imports to only what's directly needed. Effort: Small

