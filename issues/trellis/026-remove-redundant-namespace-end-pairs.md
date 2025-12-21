# Remove Redundant `namespace`/`end` Pairs

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Some small namespaces could be combined or simplified. For example, `ContainerKind` and `ItemKind` in Node.lean have very few members each.

## Rationale
Consider combining related types into a single namespace or using dot notation directly.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Node.lean`
