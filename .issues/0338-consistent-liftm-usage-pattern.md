---
id: 338
title: Consistent liftM Usage Pattern
status: closed
priority: low
created: 2026-01-09T08:12:04
updated: 2026-01-25T02:02:03
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Consistent liftM Usage Pattern

## Description
Test code and examples use verbose 'liftM (m := IO) <| ...' for lifting IO actions into SpiderM. SpiderM.liftIO convenience function was added but existing tests still use the verbose pattern. Update existing tests to use liftIO and document preferred lifting patterns.

## Progress
- [2026-01-25T02:02:03] Closed: Updated all test code and examples to use SpiderM.liftIO instead of liftM (m := IO). Updated EventTests.lean, DynamicTests.lean, README.md, and Reactive.lean. All 417 tests pass.
