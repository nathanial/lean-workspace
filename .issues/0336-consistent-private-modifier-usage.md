---
id: 336
title: Consistent Private Modifier Usage
status: open
priority: low
created: 2026-01-09T08:12:04
updated: 2026-01-09T08:12:04
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Consistent Private Modifier Usage

## Description
Some constructors use 'private mk ::' while others are public. The pattern is inconsistent across Event.lean and Dynamic.lean. Review and standardize which constructors should be private vs public across all core types.

