---
id: 229
title: Debug/trace combinators
status: open
priority: medium
created: 2026-01-07T03:51:22
updated: 2026-01-07T03:51:22
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Debug/trace combinators

## Description
Add combinators for debugging parsers during development.

Rationale: Parser debugging is notoriously difficult. Tracing input consumption and parser decisions would significantly improve development experience.

Proposed API:
def trace (name : String) (p : Parser α) : Parser α
def traceState (msg : String) : Parser Unit
def traceOnFail (p : Parser α) : Parser α

Affected: Sift/Combinators.lean or new Sift/Debug.lean

Effort: Small

