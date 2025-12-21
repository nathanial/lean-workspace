# Add Typeclass Constraints Documentation

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description

Functions require `[BEq K] [Hashable K]` but don't explain why.

## Proposed Change

Add doc comments explaining the typeclass requirements and their purpose.

## Affected Files

- `Cellar/Config.lean`
- `Cellar/LRU.lean`
