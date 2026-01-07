---
id: 231
title: Recovery/error correction
status: open
priority: low
created: 2026-01-07T03:51:22
updated: 2026-01-07T03:51:22
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Recovery/error correction

## Description
Add combinators for error recovery to enable parsing to continue after errors.

Rationale: For IDE integration and better user experience, parsers should be able to recover from errors and continue parsing to report multiple issues.

Proposed API:
def recover (p : Parser α) (handler : ParseError → Parser α) : Parser α
def withRecovery (p : Parser α) (default : α) (skipUntil : Parser Unit) : Parser α

Affected: Sift/Combinators.lean

Effort: Medium

