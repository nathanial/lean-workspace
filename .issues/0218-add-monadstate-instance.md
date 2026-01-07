---
id: 218
title: Add MonadState instance
status: open
priority: medium
created: 2026-01-07T03:50:29
updated: 2026-01-07T03:50:29
labels: [improvement]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Add MonadState instance

## Description
Parser state access is via custom get, set, modify functions in the Parser namespace.

Proposed: Add MonadState ParseState Parser instance for compatibility with generic state-manipulating code.

Benefits:
- Better integration with standard library patterns
- Enables use of generic state combinators

Affected: Sift/Core.lean

Effort: Small

