# Add Missing Hashable Instances

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Map key types should have Hashable instances for use in HashMap.

## Rationale
Ensure all scalar types that can be map keys have appropriate Hashable instances.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Map.lean` relies on user providing Hashable
