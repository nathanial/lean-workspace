---
id: 234
title: Add edge case tests
status: closed
priority: medium
created: 2026-01-07T03:51:41
updated: 2026-02-02T04:05:32
labels: [testing]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Add edge case tests

## Description
Current tests cover happy paths well but could benefit from more edge cases.

Missing test cases:
- Empty input for all primitives
- Very long inputs (stress testing)
- Unicode characters in input
- Deeply nested structures with many
- Error message content verification
- Position tracking with multi-byte UTF-8 characters
- endBy, endBy1 combinators (no dedicated tests)
- sepEndBy, sepEndBy1 combinators (no dedicated tests)
- skipMany, skipMany1 combinators (no dedicated tests)
- withFilter combinator (no dedicated tests)

Affected: SiftTests/*.lean

Effort: Medium

## Progress
- [2026-02-02T04:03:38] Explored test suite: confirmed endBy/endBy1, sepEndBy/sepEndBy1, skipMany/skipMany1, withFilter all lack dedicated tests. UTF-8 coverage is good. Empty input and stress tests are sparse.
- [2026-02-02T04:05:32] Closed: Added 20 edge case tests: endBy/endBy1, sepEndBy/sepEndBy1, skipMany/skipMany1, withFilter, empty input primitives, and stress tests for many/sepBy
