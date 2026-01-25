---
id: 225
title: Expression parser builder
status: closed
priority: medium
created: 2026-01-07T03:51:01
updated: 2026-01-25T02:35:17
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Expression parser builder

## Description
Add a configurable expression parser that handles operator precedence and associativity automatically.

Rationale: Existing chainl1/chainr1 work but require manual precedence handling. A table-driven approach is more ergonomic.

Proposed API:
inductive Assoc | left | right | none

structure Operator (α : Type) where
parser : Parser (α → α → α)
assoc : Assoc
precedence : Nat

def buildExprParser (operators : Array (Array (Operator α))) (term : Parser α) : Parser α

Affected: New Sift/Expression.lean

Effort: Medium

## Progress
- [2026-01-25T02:35:17] Closed: Already implemented in Sift/Prec.lean. The prec function provides full expression parser builder with precedence climbing, supporting binary/prefix/postfix operators, left/right/non-associativity. See OpTable, BinOpSpec, prec, precBinary. Full test suite in SiftTests/Prec.lean.
