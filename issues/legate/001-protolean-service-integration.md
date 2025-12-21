# Protolean Service Integration

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** Protolean service codegen infrastructure

## Description
Provide first-class integration with Protolean's service code generation to allow automatic client stub and server handler generation from `.proto` service definitions.

## Rationale
Currently, users must manually construct method paths (e.g., `/package.Service/Method`) and handle serialization/deserialization. Integration with Protolean's `Protolean/Service/Types.lean` would enable type-safe generated stubs that handle marshalling automatically.

## Affected Files
- New module: `Legate/Codegen/Client.lean`
- New module: `Legate/Codegen/Server.lean`
- Updates to `Legate.lean` for re-exports
