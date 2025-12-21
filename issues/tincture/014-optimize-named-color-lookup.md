# Optimize Named Color Lookup

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`namedColors` is a `List (String x Color)` and lookup is O(n) via `List.find?`.

## Rationale
Use a `HashMap` or `RBMap` for O(log n) or O(1) lookup. The list has 147+ entries.

Faster color name lookups.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Named.lean`
