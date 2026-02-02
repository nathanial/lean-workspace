---
id: 232
title: Substring parsing
status: closed
priority: low
created: 2026-01-07T03:51:23
updated: 2026-02-02T04:12:46
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Substring parsing

## Description
Add ability to parse a Substring directly without copying to a new String.

Rationale: Parsing portions of larger strings without allocation improves performance.

Proposed API:
def Parser.runSubstring (p : Parser α) (input : Substring) : Except ParseError α

Affected: Sift/Core.lean

Effort: Small

## Progress
- [2026-02-02T04:12:46] Closed: Implemented substring parsing support with initSubstring, runSubstring, runSubstringWith, parseSubstring, and parseSubstringWith functions. Added startOffset and endOffset fields to ParseState. All 262 tests pass.
