# Consistent Error Handling in Parsing

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Parsing functions return `Option Color` but do not provide error messages. Users cannot distinguish between different types of parse failures.

## Rationale
Consider adding an `Except String Color` variant that provides error messages, or at minimum document what types of inputs are rejected.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Parse.lean`
