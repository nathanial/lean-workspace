---
id: 452
title: Add matchAt/matchPrefix to public API
status: closed
priority: medium
created: 2026-01-25T02:49:27
updated: 2026-01-25T02:52:52
labels: []
assignee: 
project: rune
blocks: []
blocked_by: []
---

# Add matchAt/matchPrefix to public API

## Description
The internal `findMatchAt` function in Match/Simulation.lean matches starting at a specific position, but this isn't exposed in the public Regex API.

Needed for Sift parser combinator integration (issue #226). Sift needs to match a regex at the current parse position and advance by the match length.

Proposed additions to Rune/API.lean:

```lean
/-- Find a match starting at a specific position (does not search further) -/
def matchAt (re : Regex) (input : String) (startPos : Nat) : Option Match :=
Match.findMatchAt re.nfa input startPos

/-- Match at the start of the string (position 0) -/  
def matchPrefix (re : Regex) (input : String) : Option Match :=
matchAt re input 0
```

This exposes the existing `findMatchAt` functionality without any new implementation work.

## Progress
- [2026-01-25T02:52:52] Closed: Implemented matchAt and matchPrefix in Rune/API.lean with 8 new tests. These expose the internal findMatchAt function for position-specific matching.
