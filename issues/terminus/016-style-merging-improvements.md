# Style Merging Improvements

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`Style.merge` in `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Core/Style.lean` has simple override semantics that may not match user expectations.

## Rationale
Implement more nuanced style merging with explicit inheritance rules, possibly using a `StyleDiff` type.

More predictable style composition for complex UIs.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Core/Style.lean`
