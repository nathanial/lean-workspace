---
id: 162
title: Consolidate duplicate padLeft functions
status: open
priority: high
created: 2026-01-07T00:11:05
updated: 2026-01-07T00:11:05
labels: [refactor]
assignee: 
project: tracker
blocks: []
blocked_by: []
---

# Consolidate duplicate padLeft functions

## Description
padLeft function is defined in Types.lean, Output.lean, and Draw.lean. Move to Util.lean and import where needed for single source of truth.

