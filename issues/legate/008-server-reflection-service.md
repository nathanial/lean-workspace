# Server Reflection Service

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** Protolean descriptor support

## Description
Implement the gRPC server reflection protocol for service introspection.

## Rationale
Server reflection enables tools like `grpcurl` and gRPC UI to discover available services and methods without prior knowledge of the `.proto` files.

## Affected Files
- New module: `Legate/Reflection.lean`
- Integration with Protolean for descriptor access
