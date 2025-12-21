# Type-Safe Field Numbers

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Use a dedicated FieldNumber type with validation instead of raw UInt32.

## Rationale
`/Users/Shared/Projects/lean-workspace/protolean/Protolean/WireFormat.lean` (line 43) defines `abbrev FieldNumber := UInt32`. Create a proper structure with smart constructor that validates field numbers are in range 1 to 2^29-1 and not in reserved range 19000-19999.

Benefits: Compile-time or construction-time validation of field numbers

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/WireFormat.lean`
