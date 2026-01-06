---
id: 67
title: Centralized Error Handling
status: open
priority: medium
created: 2026-01-06T22:46:11
updated: 2026-01-06T22:46:11
labels: [improvement]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Centralized Error Handling

## Description
FFI functions return IO errors but error messages are hardcoded strings. Define a TerminalError inductive type with structured error information. Better error handling, testability, and user feedback. Affects: new Terminus/Core/Error.lean, Terminus/Backend/Raw.lean, ffi/terminus.c

