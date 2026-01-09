---
id: 214
title: Eliminate unnecessary partial annotations
status: closed
priority: medium
created: 2026-01-07T03:50:06
updated: 2026-01-09T01:14:35
labels: [cleanup]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Eliminate unnecessary partial annotations

## Description
Several functions are marked partial but may not require it with proper termination proofs.

Locations:
- Sift/Primitives.lean: string, take, takeWhile, takeWhile1, skipWhile, skipWhile1
- Sift/Combinators.lean: many, skipMany, manyTill, sepBy1, sepBy, endBy, sepEndBy1, sepEndBy, chainl1, chainl, chainr1, chainr

Action: Evaluate whether termination proofs can be provided for inner recursive helpers.

Effort: Medium

## Progress
- [2026-01-09T01:13:55] Removed partial annotations by rewriting string/take and combinators with structural recursion and bounded loops; added non-consuming parser guard; tests pass.
- [2026-01-09T01:14:35] Closed: Removed partial annotations in Sift primitives/combinators by rewriting recursion to be structural and bounded.
