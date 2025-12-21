# Streaming API Ergonomics: Iterator/ForIn Support

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Stream reading requires manual loops or `readAll`/`forEach` helpers.

## Rationale
Implement `ForIn` typeclass for `ServerStreamReader` and `BidiStream` to enable `for msg in stream do ...` syntax.

More idiomatic Lean code, cleaner user code.

## Affected Files
- `Legate/Stream.lean` - add `ForIn` instances
