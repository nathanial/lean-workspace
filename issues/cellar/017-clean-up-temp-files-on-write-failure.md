# Clean Up Temp Files on Write Failure

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description

In `Cellar/IO.lean`, `writeFile` can leave orphaned temp files if the rename fails after the temp file is written.

## Affected Files

- `Cellar/IO.lean`, line 30-34

## Action Required

Add error handling to clean up temp file on rename failure:

```lean
try
  IO.FS.rename tmpPath path
  pure (.ok ())
catch e =>
  -- Clean up temp file before returning error
  try IO.FS.removeFile tmpPath catch _ => pure ()
  pure (.error (toString e))
```
