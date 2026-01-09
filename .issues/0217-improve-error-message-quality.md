---
id: 217
title: Improve error message quality
status: closed
priority: high
created: 2026-01-07T03:50:29
updated: 2026-01-09T01:27:07
labels: [improvement]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Improve error message quality

## Description
Error messages include position and message, but expected items are sometimes incomplete. The merge function for combining errors at the same position could lose important context.

Proposed:
1. Ensure all primitive parsers consistently set expected field
2. Improve error merging to preserve most specific error information
3. Add structured error variants (unexpected char, unexpected eof, etc.)

Benefits:
- Better debugging experience
- Clearer error messages for end users
- More machine-parseable error information

Affected: Sift/Core.lean, Sift/Primitives.lean

Effort: Medium

## Progress
- [2026-01-09T01:27:03] Added structured ParseErrorKind and constructors, improved merge to prefer specific errors with deduped expected items, and updated primitives to set expected consistently; build/tests pass.
- [2026-01-09T01:27:07] Closed: Added structured ParseErrorKind, improved merge selection/deduping, and ensured primitives set expected entries; build/tests pass.
