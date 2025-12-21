# Debug/Introspection API

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add an API to inspect intermediate layout state (flex lines, track sizes, item measurements) for debugging purposes.

## Rationale
Debugging layout issues is challenging without visibility into intermediate calculations.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean` (new debug result types)
- New file: `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Debug.lean`
