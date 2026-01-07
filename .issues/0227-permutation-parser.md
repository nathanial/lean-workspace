---
id: 227
title: Permutation parser
status: open
priority: medium
created: 2026-01-07T03:51:02
updated: 2026-01-07T03:51:02
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Permutation parser

## Description
Parse elements in any order (each exactly once).

Rationale: Common in configuration parsing where keys can appear in any order. Currently requires complex manual implementation.

Proposed API:
def permute2 (p1 : Parser α) (p2 : Parser β) : Parser (α × β)
def permute3 (p1 : Parser α) (p2 : Parser β) (p3 : Parser γ) : Parser (α × β × γ)
-- Or with heterogeneous list
def permutation (parsers : List (Parser ())) : Parser Unit

Affected: New Sift/Permutation.lean or Sift/Combinators.lean

Effort: Medium

