# Add Documentation for Public API

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Medium
**Dependencies:** None

## Description
While there are doc comments on major types, many public functions lack documentation.

Action required:
1. Add module-level documentation to each file
2. Document all public functions with usage examples
3. Add cross-references between related concepts

## Rationale
Better developer experience, clearer API understanding.

## Affected Files
- `Arbor/Widget/DSL.lean` - DSL functions have minimal docs
- `Arbor/App/UI.lean` - `EventResult`, `Handler` types need examples
- `Arbor/Event/Types.lean` - Event variants could use more context
