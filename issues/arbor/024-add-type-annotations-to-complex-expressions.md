# Add Type Annotations to Complex Expressions

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Some complex expressions rely on type inference, making code harder to read.

Action required: Add explicit type annotations for clarity.

## Rationale
More readable, self-documenting code.

## Affected Files
- `Arbor/Widget/Measure.lean` - various tuple constructions
- `Arbor/Text/Renderer.lean` - fold operations
