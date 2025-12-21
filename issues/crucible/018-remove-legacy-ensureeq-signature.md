# Remove Legacy ensureEq Signature

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description

The `ensureEq` function at line 20 has a non-standard parameter order (`msg, expected, actual`) compared to modern assertions (`actual, expected`). The comment says "legacy signature for backwards compatibility."

## Affected Files

- `/Users/Shared/Projects/lean-workspace/crucible/Crucible/Core.lean` line 19-22

## Action Required

1. Evaluate if any dependents still use this
2. Add deprecation warning
3. Eventually remove or rename to `ensureEqLegacy`
