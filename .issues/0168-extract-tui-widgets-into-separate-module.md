---
id: 168
title: Extract TUI widgets into separate modules
status: open
priority: low
created: 2026-01-07T00:11:12
updated: 2026-01-07T00:11:12
labels: [refactor]
assignee: 
project: tracker
blocks: []
blocked_by: []
---

# Extract TUI widgets into separate modules

## Description
All drawing code is in single Draw.lean with inline rendering logic. Extract reusable widgets (border, text input, selector) into separate modules for better organization.

