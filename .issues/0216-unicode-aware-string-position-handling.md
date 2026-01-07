---
id: 216
title: Unicode-aware string position handling
status: open
priority: high
created: 2026-01-07T03:50:28
updated: 2026-01-07T03:50:28
labels: [improvement]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Unicode-aware string position handling

## Description
Current parser uses byte offsets (Nat) for position tracking with direct indexing via deprecated String.get. Lean strings are UTF-8 encoded, meaning byte offsets may not correctly handle multi-byte characters.

Proposed: Use Lean's String.Pos type throughout. Update ParseState to use proper String.Pos instead of Nat.

Benefits:
- Correct handling of UTF-8 multi-byte characters
- Future-proof against Lean standard library changes
- Eliminates deprecation warnings

Affected: Sift/Core.lean, Sift/Primitives.lean

Effort: Medium

