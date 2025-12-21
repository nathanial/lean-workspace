# Make Content-Length Calculation More Robust

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
In `Client.lean`, content length is set using `content.length` which counts UTF-8 code points, not bytes.

## Rationale
Use `content.toUTF8.size` for accurate byte length:
```lean
-- Current (line 360):
Wisp.FFI.setoptLong easy Wisp.FFI.CurlOpt.POSTFIELDSIZE content.length.toInt64
-- Should be:
Wisp.FFI.setoptLong easy Wisp.FFI.CurlOpt.POSTFIELDSIZE content.toUTF8.size.toInt64
```

Benefits:
- Correct Content-Length for non-ASCII content
- Prevents potential truncation issues

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean` (lines 360, 364, 509, 513)
