# Progress Callbacks

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add upload/download progress reporting for large file transfers.

## Rationale
For large file uploads/downloads, progress feedback is essential for UX. libcurl supports progress callbacks that could be exposed.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/FFI/Easy.lean` - Add progress callback FFI
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean` - Expose progress in API
- `/Users/Shared/Projects/lean-workspace/wisp/native/src/wisp_ffi.c` - Implement progress callback wrapper
