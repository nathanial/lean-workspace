# Remove Unused FFI Function

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
`legate_server_builder_register_handler` is declared in the header but never used; all registrations use type-specific functions (`legate_server_register_unary`, etc.).

## Rationale
Remove the unused declaration or implement if needed.

## Affected Files
- `ffi/include/legate_ffi.h` (lines 196-202)
