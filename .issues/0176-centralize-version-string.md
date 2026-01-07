---
id: 176
title: Centralize version string
status: open
priority: low
created: 2026-01-07T00:11:31
updated: 2026-01-07T00:11:31
labels: [cleanup]
assignee: 
project: tracker
blocks: []
blocked_by: []
---

# Centralize version string

## Description
Version 0.1.0 appears in multiple places (Commands.lean, Main.lean) without single source of truth. Define version constant in one place and reference elsewhere.

