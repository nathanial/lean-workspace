---
id: 223
title: Context-sensitive parsing (Reader/State)
status: open
priority: high
created: 2026-01-07T03:51:00
updated: 2026-01-07T03:51:00
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Context-sensitive parsing (Reader/State)

## Description
Add support for user-defined state that persists across parser invocations, enabling context-sensitive parsing.

Rationale: Many real parsers need to track context (indentation level, symbol tables, configuration). Currently users must thread state manually.

Proposed API:
def ParserT (σ : Type) (α : Type) := σ → ParseState → Except ParseError (α × σ × ParseState)
-- Or transformer-style:
def ParserT (m : Type → Type) (α : Type) := ParseState → m (Except ParseError (α × ParseState))

Affected: New Sift/ParserT.lean

Effort: Large

