# WebSocket Support

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** libcurl 7.86+ with WebSocket support

## Description
Add WebSocket client capabilities using libcurl's websocket support (available in curl 7.86+).

## Rationale
WebSocket is essential for real-time applications. libcurl now supports WebSocket connections. This would enable:
- Bidirectional communication
- Real-time updates without polling
- Integration with modern APIs that use WebSocket

## Affected Files
- New file: `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/WebSocket.lean`
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/FFI/Easy.lean` - Add websocket FFI bindings
- `/Users/Shared/Projects/lean-workspace/wisp/native/src/wisp_ffi.c` - Add curl_ws_* functions
