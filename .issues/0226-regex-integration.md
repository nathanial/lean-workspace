---
id: 226
title: Regex integration
status: open
priority: medium
created: 2026-01-07T03:51:01
updated: 2026-01-07T03:51:01
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Regex integration

## Description
Add a combinator that matches against a compiled regex from the workspace's rune library.

Rationale: Some parsing tasks are more naturally expressed as regex patterns. Integration with existing regex library would provide a powerful hybrid approach.

Proposed API:
def regex (pattern : Rune.Regex) : Parser String
def regexCaptures (pattern : Rune.Regex) : Parser (Array String)

Affected: New Sift/Regex.lean, lakefile.lean (add dependency)

Effort: Medium

Dependencies: rune library

