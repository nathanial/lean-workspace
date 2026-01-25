---
id: 224
title: Indentation-sensitive parsing
status: closed
priority: medium
created: 2026-01-07T03:51:00
updated: 2026-01-25T02:27:03
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Indentation-sensitive parsing

## Description
Add combinators for indentation-sensitive languages (Python, YAML, Haskell-style layout).

Proposed API:
- indented (p : Parser α) : Parser α -- Parse if indented relative to reference
- block (p : Parser α) : Parser (Array α) -- Parse indentation-delimited block
- sameLine (p : Parser α) : Parser α -- Parse on same line
- checkIndent : Parser Unit -- Verify current indentation
- withIndent (n : Nat) (p : Parser α) : Parser α

Affected: New Sift/Indentation.lean

Effort: Medium

Dependencies: Context-sensitive parsing support

## Progress
- [2026-01-25T02:27:03] Closed: Implemented in commit 048535d (v0.0.10). Added Sift/Indent.lean with: getColumn, getLine, atColumn, indented, onLine, measureIndent, IndentState for indent stack tracking, block, sameLevel, blockLines, processIndent, checkIndent, withIndentContext, atIndent, softBlock. Full test suite included.
