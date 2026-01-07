---
id: 230
title: Case-insensitive string matching
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

# Case-insensitive string matching

## Description
Add case-insensitive variants of string matching primitives.

Rationale: Many text formats (HTML tags, SQL keywords) are case-insensitive.

Proposed API:
def stringCI (expected : String) : Parser String
def charCI (c : Char) : Parser Char

Affected: Sift/Primitives.lean

Effort: Small

