---
id: 228
title: ByteArray/binary parsing
status: open
priority: medium
created: 2026-01-07T03:51:21
updated: 2026-01-07T03:51:21
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# ByteArray/binary parsing

## Description
Add support for parsing binary data from ByteArray instead of String.

Rationale: Many formats are binary (images, protocols, archives). Current string-based parser cannot handle null bytes or binary data efficiently.

Proposed API:
def BinaryParser (α : Type) := ByteArray → Nat → Except ParseError (α × Nat)

namespace BinaryParser
  def byte : BinaryParser UInt8
  def bytes (n : Nat) : BinaryParser ByteArray
  def uint16LE : BinaryParser UInt16
  def uint32BE : BinaryParser UInt32
  -- etc.
end BinaryParser

Affected: New Sift/Binary.lean

Effort: Large

