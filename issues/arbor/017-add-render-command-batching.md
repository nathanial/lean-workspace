# Add Render Command Batching

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Render commands are collected into a flat array. Backends may benefit from batched commands (e.g., batch all fills of the same color).

Proposed change: Add optional command batching/optimization pass:
```lean
def optimizeCommands (cmds : RenderCommands) : RenderCommands :=
  cmds
  |> batchSimilarFills
  |> eliminateNoOps
  |> mergeClipRegions
```

## Rationale
Potential rendering performance improvements.

## Affected Files
- `Arbor/Render/Optimize.lean` (new file)
