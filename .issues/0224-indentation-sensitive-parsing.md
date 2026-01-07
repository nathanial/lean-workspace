---
id: 224
title: Indentation-sensitive parsing
status: open
priority: medium
created: 2026-01-07T03:51:00
updated: 2026-01-07T03:51:00
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

