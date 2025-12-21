# Extract Lean Object Helpers to Separate Module

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
The FFI implementation (`legate_ffi.cpp`) contains many helper functions for Lean object construction (`mk_pair`, `mk_except_ok`, `mk_option_some`, etc.) mixed with gRPC logic.

## Rationale
Extract Lean FFI helpers to a separate header file (`lean_helpers.h`) for reusability and clarity.

Cleaner separation of concerns, potentially reusable across projects.

## Affected Files
- `ffi/src/legate_ffi.cpp` - extract helpers
- New file: `ffi/include/lean_helpers.h`
