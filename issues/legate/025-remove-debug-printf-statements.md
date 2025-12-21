# Remove Debug Printf Statements

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
The FFI contains conditional debug output via `debug_server_io_enabled()` controlled by environment variable. This is fine for development but the debug code could be cleaned up.

## Rationale
Consider adding a proper logging interface or documenting the debug environment variable in README.

## Affected Files
- `ffi/src/legate_ffi.cpp` - multiple `std::fprintf(stderr, ...)` calls
