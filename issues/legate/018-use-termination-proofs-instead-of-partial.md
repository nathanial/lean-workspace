# Use Termination Proofs Instead of partial

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Several functions use `partial` annotation (`waitForReady`, `readAll`, `forEach`, `fold`).

## Rationale
Where possible, provide termination proofs or refactor to avoid `partial`.

Stronger guarantees, better alignment with Lean idioms.

## Affected Files
- `Legate/Channel.lean` - `waitForReady`
- `Legate/Stream.lean` - `readAll`, `forEach`, `fold`
