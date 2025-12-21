# Persistence Layer

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Implement durable storage with disk-based persistence, append-only transaction log, and crash recovery.

## Rationale
Currently, all data is in-memory and lost on process termination. For production use, the database needs:
- Append-only log file for durability
- Periodic snapshots for faster recovery
- Memory-mapped indexes for large datasets
- Crash recovery from log replay

## Affected Files
- New file: `Ledger/Storage/Log.lean`
- New file: `Ledger/Storage/Snapshot.lean`
- New file: `Ledger/Storage/Recovery.lean`
- Modify: `Ledger/Db/Connection.lean` (add persistence to Connection)
