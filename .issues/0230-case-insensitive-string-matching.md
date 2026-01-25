---
id: 230
title: Case-insensitive string matching
status: closed
priority: low
created: 2026-01-07T03:51:22
updated: 2026-01-25T02:01:47
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Case-insensitive string matching

## Description
Add case-insensitive variants of string matching primitives.

Rationale: Many text formats (HTML tags, SQL keywords) are case-insensitive.

Proposed API:
def stringCI (expected : String) : Parser String
def charCI (c : Char) : Parser Char

Affected: Sift/Primitives.lean

Effort: Small

## Progress
- [2026-01-25T02:01:47] Closed: Added charCI combinator. stringCI was already implemented. Both case-insensitive matching functions now available.
