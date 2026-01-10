---
id: 349
title: Nested container children get zero height due to missing intrinsic sizing
status: in-progress
priority: high
created: 2026-01-10T13:21:07
updated: 2026-01-10T13:22:58
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Nested container children get zero height due to missing intrinsic sizing

## Description
When a row container is nested inside a column container, the row's children are computed with height=0, causing them to not render correctly in consumers like Terminus.


In `Algorithm.lean`, `getContentSize` returns `(0, 0)` for container nodes:

```lean
def getContentSize (node : LayoutNode) : Length × Length :=
match node.content with
| some cs => (cs.width, cs.height)
| none => (0, 0)  -- Containers return 0!
```

When a column lays out a row child:
1. `getContentSize(row)` returns `(0, 0)`
2. The row gets `hypotheticalCrossSize = 0`
3. When recursively laying out the row's children, they inherit `availableHeight = 0`
4. Text nodes inside the row end up with `resolvedHeight = 0`


```lean
-- Row at root level: children get correct height
let row := LayoutNode.row 0 #[textNode1, textNode2]
let result := layout row 20 5
-- textNode1 gets height = 5 (full available height) ✓

-- Row nested in column: children get height 0
let col := LayoutNode.column 0 #[headerNode, row]
let result := layout col 20 5  
-- headerNode gets height = 1 ✓
-- row's children get height = 0 ✗
```


Implement intrinsic sizing for containers as noted in ROADMAP.md under "Dependency Injection for Content Measurement":

1. Add a `measureIntrinsicSize` function that recursively computes container sizes from children
2. For rows: width = sum of children widths + gaps, height = max of children heights
3. For columns: width = max of children widths, height = sum of children heights + gaps
4. Update `getContentSize` to call this for containers

Alternatively, implement the `ContentMeasurer` typeclass approach suggested in the ROADMAP.


- "Dependency Injection for Content Measurement" (Architecture Considerations)
- "Add Tests for Edge Cases" - specifically "Deeply nested containers"


Terminus has a workaround in `Terminus/Reactive/Render.lean` that renders text regardless of computed height:

```lean
def renderText (content : String) (style : Style) (rect : Terminus.Rect) (buf : Buffer) : Buffer :=
if rect.width == 0 then buf  -- Removed height check as workaround
else ...
```

Once this issue is fixed in Trellis, the workaround can be removed and the height check restored.

