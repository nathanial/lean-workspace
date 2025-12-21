# Lazy Gradient Sampling

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`Gradient.sample` eagerly computes all colors into an Array.

## Rationale
Add a lazy/iterator-based API for sampling gradients, useful when only a few samples are needed from a potentially large gradient.

Better memory efficiency for large sample counts.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Gradient.lean`
