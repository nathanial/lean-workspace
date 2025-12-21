# Better Error Messages in Parser

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add source location information to parse errors.

## Rationale
`/Users/Shared/Projects/lean-workspace/protolean/Protolean/Parser/Proto.lean` (line 333) returns errors without position info. Track position during parsing and include line/column in error messages.

Benefits: Easier debugging of proto file syntax errors

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Parser/Proto.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Parser/Lexer.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Syntax/Position.lean`
