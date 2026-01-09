---
id: 56
title: Composable Widget Typeclass
status: closed
priority: medium
created: 2026-01-06T22:45:46
updated: 2026-01-09T01:21:45
labels: [feature]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Composable Widget Typeclass

## Description
Introduce a Widget typeclass with methods for measuring preferred size, handling input events, and rendering. Would enable automatic size calculation, event bubbling, focus management, and widget introspection. Affects: Terminus/Widgets/Widget.lean and all widget files.

## Progress
- [2026-01-09T01:18:02] Added preferredSize/handleEvent defaults to Widget typeclass, updated AnyWidget type erasure, ScrollView sizing uses preferredSize fallback, and hooked handleEvent into common interactive widgets (TextInput/TextArea/List/RadioGroup/Checkbox/Tabs/Tree).
- [2026-01-09T01:21:45] Closed: Implemented preferred size/event handling in Widget typeclass, updated AnyWidget and ScrollView, and added default event handling for common interactive widgets.
