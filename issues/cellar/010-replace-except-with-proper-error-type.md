# Replace Except with Proper Error Type

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description

Functions in `Cellar/IO.lean` return `Except String Unit` or `Except String ByteArray`, losing structured error information.

## Proposed Change

Define a proper error ADT for cache operations:

```lean
inductive CacheError
  | fileNotFound (path : String)
  | ioError (message : String)
  | permissionDenied (path : String)
  | diskFull
  | corruptedData (path : String)
  deriving Repr, Inhabited

abbrev CacheIO := ExceptT CacheError IO
```

## Benefits

Better error handling, pattern matching on error types, clearer API contracts.

## Affected Files

- `Cellar/IO.lean`
- All modules using IO functions
