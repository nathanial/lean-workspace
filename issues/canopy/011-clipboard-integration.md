# Clipboard Integration

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None (but may need native FFI code)

## Description
Add clipboard read/write operations for cut, copy, and paste.

## Rationale
Text editing and data manipulation require clipboard access. This needs FFI to system clipboard APIs.

## Affected Files
- `Canopy/Clipboard/Core.lean` (new)
- `Canopy/Clipboard/FFI.lean` (new)
