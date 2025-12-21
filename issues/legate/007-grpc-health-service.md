# gRPC Health Service

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** Protolean for message types

## Description
Implement the standard gRPC health checking protocol (`grpc.health.v1.Health`).

## Rationale
Health checking is essential for production deployments with load balancers and container orchestrators (Kubernetes, etc.).

## Affected Files
- New module: `Legate/Health.lean`
- Proto file: `Proto/health.proto` (or use grpc's built-in)
