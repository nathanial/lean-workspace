# Improve Atomic Write Robustness

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description

`writeFile` uses temp file + rename, but doesn't handle:
- Cleanup of temp files on crash
- Cross-filesystem moves (rename fails)
- fsync for durability

## Proposed Changes

```lean
-- Add fsync before rename for durability
IO.FS.Handle.sync handle

-- Handle cross-filesystem case
if sameFilesystem tmpPath path then
  IO.FS.rename tmpPath path
else
  -- Fall back to copy + delete
  IO.FS.writeBinFile path data
  deleteFile tmpPath
```

## Benefits

More robust cache operations, especially for production use.

## Affected Files

- `Cellar/IO.lean`
