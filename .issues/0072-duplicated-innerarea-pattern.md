---
id: 72
title: Duplicated innerArea Pattern
status: open
priority: medium
created: 2026-01-06T22:46:33
updated: 2026-01-06T22:46:33
labels: [cleanup]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Duplicated innerArea Pattern

## Description
Every widget has the same boilerplate for handling optional blocks and computing inner areas. Extract common pattern into a helper function, consider a Widget wrapper that handles block rendering. Location: All widget files in Terminus/Widgets/

