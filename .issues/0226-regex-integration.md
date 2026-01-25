---
id: 226
title: Regex integration
status: closed
priority: medium
created: 2026-01-07T03:51:01
updated: 2026-01-25T02:58:38
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

## Progress
- [2026-01-25T02:49:33] Blocked on rune issue #452: need matchAt/matchPrefix in rune's public API before Sift integration can proceed. The internal findMatchAt function exists but isn't exposed.
- [2026-01-25T02:53:05] Blocker resolved: rune v0.0.3 now has matchAt/matchPrefix. Ready for Sift integration.
- [2026-01-25T02:58:38] Closed: Cannot implement as library feature due to circular dependency (rune depends on sift for regex parsing). Documented integration pattern in CLAUDE.md instead - projects using both libraries can copy the ~30 line regex combinator implementation.
