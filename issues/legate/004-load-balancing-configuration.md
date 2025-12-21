# Load Balancing Configuration

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Expose gRPC load balancing configuration options (round-robin, pick-first, etc.).

## Rationale
Listed in README as a TODO. Production deployments often need load balancing across multiple server endpoints.

## Affected Files
- `Legate/Channel.lean` - add channel arguments for LB policy
- `ffi/src/legate_ffi.cpp` - pass channel args to `grpc::CreateCustomChannel`
