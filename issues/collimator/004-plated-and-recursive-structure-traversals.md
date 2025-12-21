# Plated and Recursive Structure Traversals

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Implement `Plated` typeclass for recursive data structure traversals, enabling operations like `cosmos`, `para`, and `transform` for generic recursion.

## Rationale
Recursive traversals are essential for AST manipulation, tree transformations, and similar use cases. The `examples/TreeTraversal.lean` example demonstrates manual tree traversal; `Plated` would generalize this.

## Affected Files
- New: `Collimator/Plated.lean`
- New: Tests and examples
