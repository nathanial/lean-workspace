# Zero-Copy Decoding

**Priority:** Low
**Section:** Performance Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Avoid copying bytes during string/bytes field decoding where possible.

## Rationale
`/Users/Shared/Projects/lean-workspace/protolean/Protolean/Decoder.lean` copies bytes via `extract`. Return views/slices for read-only access scenarios.

Benefits: Reduced memory allocations for read-heavy workloads

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Decoder.lean`
