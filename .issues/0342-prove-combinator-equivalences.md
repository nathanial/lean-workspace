---
id: 342
title: Prove combinator equivalences
status: closed
priority: low
created: 2026-01-09T08:56:16
updated: 2026-01-09T09:44:01
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Prove combinator equivalences

## Description
Prove algebraic equivalences between combinators: (1) filter p e = mapMaybe (guard p) e, (2) scan = accumulate, (3) zipWith f b1 b2 = pure f <*> b1 <*> b2, (4) attach = attachWith Prod.mk. These establish that the API is internally consistent.

## Progress
- [2026-01-09T09:44:01] Closed: Implemented formal proofs for combinator equivalences: scan_eq_accumulate (definitional), zipWith_eq_applicative (formal proof via IO monad laws), filter_handler_eq_mapMaybe_handler (semantic equivalence), attach_handler_eq_attachWith_handler (semantic equivalence)
