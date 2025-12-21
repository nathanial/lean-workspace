# Re-export Arbor and Trellis Types

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Core.lean imports Arbor but doesn't re-export useful types.

Proposed change: Selectively re-export commonly-used Arbor and Trellis types so users can import only Canopy.

## Rationale
Cleaner imports for downstream users, single import for common use cases.

## Affected Files
- `Canopy/Core.lean`
