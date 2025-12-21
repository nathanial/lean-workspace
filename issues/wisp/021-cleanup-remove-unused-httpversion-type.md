# Remove Unused HttpVersion Type

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
The `HttpVersion` type is defined in `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Types.lean` (lines 38-44) but is never used anywhere in the codebase.

## Rationale
Either:
1. Remove the unused type, or
2. Implement HTTP version configuration using this type (preferred)

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Types.lean:38-44`
