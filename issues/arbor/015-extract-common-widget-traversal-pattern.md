# Extract Common Widget Traversal Pattern

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Multiple functions implement the same tree traversal pattern with slight variations (collect, hit test, measure, etc.).

Proposed change: Create a generic `foldWidget` or `traverseWidget` combinator:
```lean
def Widget.fold {M : Type -> Type} [Monad M] {α : Type}
    (f : α -> Widget -> M α) (init : α) (w : Widget) : M α
```

## Rationale
Reduces code duplication, makes traversal patterns consistent.

## Affected Files
- `Arbor/Widget/Core.lean` - add fold/traverse
- Refactor dependent files
