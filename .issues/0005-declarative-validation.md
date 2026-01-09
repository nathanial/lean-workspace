---
id: 5
title: Declarative validation
status: closed
priority: high
created: 2026-01-06T14:47:03
updated: 2026-01-09T01:47:10
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Declarative validation

## Description
Add support for custom validation functions on arguments. Current validation is limited to type parsing. Proposed API: Cmd.flag "port" (argType := .nat) (validate := fun n => if n < 65536 then .ok else .error "Port must be < 65536"). Affects: Core/Types.lean, Parse/Parser.lean

## Progress
- [2026-01-09T01:47:10] Closed: Implemented declarative validation with custom validators. Added validate field to Flag and Arg structures, created Validate module with typed helpers (nat, int, string, port, range validators), and integrated validation into the parsing flow. All 126 tests pass.
