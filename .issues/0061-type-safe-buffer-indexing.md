---
id: 61
title: Type-Safe Buffer Indexing
status: closed
priority: high
created: 2026-01-06T22:46:10
updated: 2026-01-06T23:31:55
labels: [improvement]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Type-Safe Buffer Indexing

## Description
Buffer access in Terminus/Core/Buffer.lean uses cells[idx]! which can panic on out-of-bounds access. Use bounds-checked access with proper error handling or proof-carrying code to ensure safe indexing. Prevents runtime panics, improves reliability.

## Progress
- [2026-01-06T23:27:09] Found that Array.modify is the safe alternative to set! - returns array unchanged if index is out of bounds
- [2026-01-06T23:31:55] Closed: Replaced all unsafe array indexing (!-suffixed operations) with type-safe alternatives: Array.modify instead of set!, Array.getD instead of indexed!, List.getLast?.getD instead of getLast!. Changed 14 files across Buffer.lean, Spinner, Calendar, Sparkline, PieChart, Canvas, BigText, TextArea, and KitchenSink example. All 329 tests pass.
