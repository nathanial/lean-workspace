# Builder Do-Notation Sugar

**Priority:** Low
**Section:** API Ergonomics
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Building complex widget trees requires explicit `#[...]` arrays.

Action required: Explore do-notation builder pattern:
```lean
-- Current
row {} #[box a, box b, box c]
-- Potential
row {} do
  box a
  box b
  box c
```

## Rationale
More ergonomic widget tree construction.

## Affected Files
- `Arbor/Widget/DSL.lean`
