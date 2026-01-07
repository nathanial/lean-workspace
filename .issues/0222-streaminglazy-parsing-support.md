---
id: 222
title: Streaming/lazy parsing support
status: open
priority: high
created: 2026-01-07T03:50:59
updated: 2026-01-07T03:50:59
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Streaming/lazy parsing support

## Description
Add support for parsing input incrementally or lazily, rather than requiring entire input string upfront.

Rationale: Parsing large files or network streams requires incremental processing.

Proposed API:
structure StreamState where
  buffer : String
  bufferPos : Nat
  isComplete : Bool

def Parser.runStreaming : Parser α → (Unit → IO (Option String)) → IO (Except ParseError α)

Affected: Sift/Core.lean, new Sift/Streaming.lean

Effort: Large

