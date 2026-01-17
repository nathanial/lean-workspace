---
id: 333
title: Dynamic Functor and Applicative Instances
status: closed
priority: low
created: 2026-01-09T08:12:04
updated: 2026-01-17T13:11:47
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Dynamic Functor and Applicative Instances

## Description
Add pure Functor, Applicative, and potentially Monad instances for Dynamic. Currently Dynamic operations are inherently effectful (require NodeId allocation). SpiderM-based combinators provide a workaround. Pure typeclass instances would require a ReaderT NodeIdGenerator approach or similar.

## Progress
- [2026-01-17T13:11:47] Closed: Closed by user request
