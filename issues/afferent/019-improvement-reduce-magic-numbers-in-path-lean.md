# Reduce Magic Numbers in Path.lean

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Pi is defined as a literal constant (3.14159265358979323846) and the bezier approximation constant (0.5522847498) appears multiple times.

## Rationale
Define named constants for pi and the bezier circle approximation factor.

Benefits: Improved readability, single source of truth.

## Affected Files
- `Afferent/Core/Path.lean` (lines 165-166, 112, 127, 142)
