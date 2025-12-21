# Consistent Naming Convention for Proto Types

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Some scalar wrapper types use camelCase (SInt32, SFixed32) while proto types use consistent casing.

## Rationale
Consider whether wrapper types should mirror proto naming exactly (sint32 -> Sint32 or SInt32).

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Scalar.lean`
