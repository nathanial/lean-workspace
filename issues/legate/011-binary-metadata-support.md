# Binary Metadata Support

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add explicit support for binary metadata keys (suffixed with `-bin`).

## Rationale
Some metadata values (like trace context, structured error details) are binary and require base64 encoding. Currently this is not explicitly handled.

## Affected Files
- `Legate/Metadata.lean` - add `addBinary` / `getBinary` helpers
