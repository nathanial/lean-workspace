/-
  Trellis Layout Algorithm
  CSS Flexbox and Grid layout computation.

  This module provides iterative (stack-based) layout algorithms that can handle
  arbitrarily deep nesting without stack overflow. Uses O(n) complexity by
  pre-computing intrinsic sizes in a single pass.
-/
import Std.Data.HashMap
import Trellis.Types
import Trellis.Flex
import Trellis.Grid
import Trellis.Node
import Trellis.Axis
import Trellis.Result
import Trellis.Debug
import Trellis.FlexAlgorithm
import Trellis.GridAlgorithm

namespace Trellis

/-! ## Iterative Intrinsic Size Measurement

Uses explicit stack for post-order traversal to measure content sizes bottom-up.
Pre-computes all sizes in a single O(n) pass.
-/

/-- Work item for iterative intrinsic size measurement. -/
private inductive MeasureWorkItem where
  /-- Visit node - push children first, then mark for combining. -/
  | visit (node : LayoutNode)
  /-- Combine children's sizes into parent's size. -/
  | combine (node : LayoutNode)
deriving Inhabited

/-- Pre-compute intrinsic sizes for all nodes in the tree.
    Returns a HashMap from node ID to (width, height).
    Uses explicit stack to avoid stack overflow with deep nesting. -/
def measureAllIntrinsicSizes (root : LayoutNode) : Std.HashMap Nat (Length × Length) := Id.run do
  let estimatedNodes := max 8 root.nodeCount
  let mut sizes : Std.HashMap Nat (Length × Length) := Std.HashMap.emptyWithCapacity estimatedNodes
  let mut stack : Array MeasureWorkItem := (Array.mkEmpty estimatedNodes).push (.visit root)

  while !stack.isEmpty do
    let item := stack.back!
    stack := stack.pop

    match item with
    | .visit node =>
      -- Check if already computed (handles DAGs if any)
      if sizes.contains node.id then
        continue

      -- Store intrinsic size based on content or computed from children
      match node.content with
      | some cs =>
        -- Node has pre-computed content size (e.g., from afferent's measureWidget)
        sizes := sizes.insert node.id (cs.width, cs.height)
        -- IMPORTANT: Still visit children so their sizes are in the HashMap!
        -- This is needed because layoutFlexContainer/layoutGridContainer call
        -- getContentSize on children, which looks them up in the HashMap.
        if !node.isLeaf then
          for child in node.children.reverse do
            stack := stack.push (.visit child)
      | none =>
        if node.isLeaf then
          sizes := sizes.insert node.id (0, 0)
        else
          -- Container without preset content: compute from children
          stack := stack.push (.combine node)
          for child in node.children.reverse do
            stack := stack.push (.visit child)

    | .combine node =>
      -- All children should be measured now, combine their sizes
      let childSizes := node.children.map fun child =>
        sizes.getD child.id (0, 0)

      let padding := node.box.padding
      let size := match node.container with
        | .flex props => measureFlexIntrinsic props node.children childSizes padding
        | .grid props => measureGridIntrinsic props childSizes node.children.size padding
        | .none => (0, 0)

      sizes := sizes.insert node.id size

  sizes
where
  measureFlexIntrinsic (props : FlexContainer) (children : Array LayoutNode)
      (childSizes : Array (Length × Length)) (padding : EdgeInsets) : Length × Length := Id.run do
    if childSizes.isEmpty then
      return (padding.horizontal, padding.vertical)

    let mut visibleSizes : Array (Length × Length) := Array.mkEmpty childSizes.size
    for idx in [:childSizes.size] do
      let child := children[idx]!
      let size := childSizes[idx]!
      let isCollapsed := match child.flexItem? with
        | some props => props.visibility == .collapse
        | none => false
      if !isCollapsed then
        visibleSizes := visibleSizes.push size

    let visibleCount := visibleSizes.size
    let gapCount := if visibleCount > 0 then (visibleCount - 1).toFloat else 0
    if props.direction.isHorizontal then
      let width := visibleSizes.foldl (fun acc sz => acc + sz.1) 0 + props.gap * gapCount
      let height := childSizes.foldl (fun acc sz => max acc sz.2) 0
      return (width + padding.horizontal, height + padding.vertical)
    else
      let width := childSizes.foldl (fun acc sz => max acc sz.1) 0
      let height := visibleSizes.foldl (fun acc sz => acc + sz.2) 0 + props.gap * gapCount
      return (width + padding.horizontal, height + padding.vertical)

  measureGridIntrinsic (props : GridContainer) (childSizes : Array (Length × Length))
      (childCount : Nat) (padding : EdgeInsets) : Length × Length := Id.run do
    if childSizes.isEmpty then
      return (padding.horizontal, padding.vertical)

    let areaRows := props.templateAreas.rowCount
    let areaCols := props.templateAreas.colCount
    let explicitRows :=
      if areaRows > 0 then areaRows
      else (getExpandedSizes props.templateRows 0 props.rowGap).size
    let explicitCols :=
      if areaCols > 0 then areaCols
      else (getExpandedSizes props.templateColumns 0 props.columnGap).size

    let ceilDiv := fun (n d : Nat) => if d == 0 then 0 else (n + d - 1) / d

    let (rowCount, colCount) := match props.autoFlow with
      | .row | .rowDense =>
        let colCount := if explicitCols > 0 then explicitCols
          else if explicitRows > 0 then max 1 (ceilDiv childCount explicitRows)
          else max 1 childCount
        let rowCount := if explicitRows > 0 then max explicitRows (ceilDiv childCount colCount)
          else max 1 (ceilDiv childCount colCount)
        (rowCount, colCount)
      | .column | .columnDense =>
        let rowCount := if explicitRows > 0 then explicitRows
          else if explicitCols > 0 then max 1 (ceilDiv childCount explicitCols)
          else max 1 childCount
        let colCount := if explicitCols > 0 then max explicitCols (ceilDiv childCount rowCount)
          else max 1 (ceilDiv childCount rowCount)
        (rowCount, colCount)

    let mut rowHeights : Array Length := (List.replicate rowCount 0).toArray
    let mut colWidths : Array Length := (List.replicate colCount 0).toArray

    for idx in [:childCount] do
      if h : idx < childSizes.size then
        let size := childSizes[idx]
        let (rowIdx, colIdx) := match props.autoFlow with
          | .row | .rowDense => (idx / colCount, idx % colCount)
          | .column | .columnDense => (idx % rowCount, idx / rowCount)
        if rowIdx < rowHeights.size then
          rowHeights := rowHeights.set! rowIdx (max rowHeights[rowIdx]! size.2)
        if colIdx < colWidths.size then
          colWidths := colWidths.set! colIdx (max colWidths[colIdx]! size.1)

    let rowGapCount := if rowCount > 0 then (rowCount - 1).toFloat else 0
    let colGapCount := if colCount > 0 then (colCount - 1).toFloat else 0
    let width := colWidths.foldl (· + ·) 0 + props.columnGap * colGapCount
    let height := rowHeights.foldl (· + ·) 0 + props.rowGap * rowGapCount
    return (width + padding.horizontal, height + padding.vertical)

/-- Measure intrinsic size of a single node (traverses subtree).
    For single-node queries. For bulk computation, use measureAllIntrinsicSizes. -/
def measureIntrinsicSize (root : LayoutNode) : Length × Length :=
  (measureAllIntrinsicSizes root).getD root.id (0, 0)

/-- Get the content size of a node. -/
def getContentSize (node : LayoutNode) : Length × Length :=
  measureIntrinsicSize node

/-! ## Iterative Layout Algorithm

Uses explicit stack for top-down traversal to compute layouts without recursion.
Pre-computes all intrinsic sizes once for O(n) total complexity.
-/

/-- Work item for iterative layout computation. -/
private structure LayoutWorkItem where
  node : LayoutNode
  availableWidth : Length
  availableHeight : Length
  offsetX : Length
  offsetY : Length
  /-- Whether to add this node's own layout (true for root, false for children
      since their layouts are already added by parent's layoutFlexContainer/layoutGridContainer) -/
  addOwnLayout : Bool := true
  /-- Optional subgrid context passed from a parent grid. -/
  subgridContext : Option SubgridContext := none
deriving Inhabited

/-- Iteratively layout a tree starting from the root.
    Uses explicit stack to avoid stack overflow with deep nesting.
    Pre-computes all intrinsic sizes once for O(n) total complexity. -/
def layout (root : LayoutNode) (availableWidth availableHeight : Length) : LayoutResult := Id.run do
  -- Pre-compute all intrinsic sizes in one O(n) pass
  let allSizes := measureAllIntrinsicSizes root

  -- Create lookup function that uses pre-computed sizes
  let getSize : LayoutNode → Length × Length := fun node =>
    allSizes.getD node.id (0, 0)

  let mut resultLayouts : Array ComputedLayout := Array.mkEmpty allSizes.size
  let mut stack : Array LayoutWorkItem := (Array.mkEmpty allSizes.size).push ⟨root, availableWidth, availableHeight, 0, 0, true, none⟩

  while !stack.isEmpty do
    let item := stack.back!
    stack := stack.pop
    let node := item.node
    let box := node.box

    -- Resolve node dimensions using pre-computed sizes (O(1) lookup)
    let contentSize := getSize node
    let isContainer := !node.isLeaf
    let resolvedWidth := match box.width with
      | .auto => if isContainer then item.availableWidth else contentSize.1
      | dim => dim.resolve item.availableWidth contentSize.1
    let resolvedHeight := match box.height with
      | .auto => if isContainer then item.availableHeight else contentSize.2
      | dim => dim.resolve item.availableHeight contentSize.2
    -- Apply aspect-ratio if one dimension is auto
    let (resolvedWidth, resolvedHeight) := applyAspectRatio resolvedWidth resolvedHeight
      box.width.isAuto box.height.isAuto box.aspectRatio
    let width := box.clampWidth resolvedWidth
    let height := box.clampHeight resolvedHeight

    -- Create layout for this node (only for root; children are added by parent's container layout)
    if item.addOwnLayout then
      let nodeRect := LayoutRect.mk' item.offsetX item.offsetY width height
      resultLayouts := resultLayouts.push (ComputedLayout.withPadding node.id nodeRect box.padding)

    -- Layout children based on container type
    match node.container with
    | .flex props =>
      let childResult := layoutFlexContainer props node.children width height box.padding getSize
      let translateLayout := fun (cl : ComputedLayout) =>
        { cl with
          borderRect := cl.borderRect.translate item.offsetX item.offsetY
          contentRect := cl.contentRect.translate item.offsetX item.offsetY
        }
      -- Add translated child layouts directly to avoid translate/merge allocations
      for cl in childResult.layouts do
        resultLayouts := resultLayouts.push (translateLayout cl)

      -- Push non-leaf children onto stack (their layouts are already in childResult)
      for child in node.children.reverse do
        if !child.isLeaf then
          if let some cl := childResult.get child.id then
            let cl := translateLayout cl
            stack := stack.push ⟨child, cl.borderRect.width, cl.borderRect.height,
                                 cl.borderRect.x, cl.borderRect.y, false, none⟩

    | .grid props =>
      let childLayout := layoutGridContainerInternal props node.children width height box.padding
        getSize item.subgridContext false
      let childResult := childLayout.result
      let translateLayout := fun (cl : ComputedLayout) =>
        { cl with
          borderRect := cl.borderRect.translate item.offsetX item.offsetY
          contentRect := cl.contentRect.translate item.offsetX item.offsetY
        }
      -- Add translated child layouts directly to avoid translate/merge allocations
      for cl in childResult.layouts do
        resultLayouts := resultLayouts.push (translateLayout cl)

      -- Push non-leaf children onto stack (their layouts are already in childResult)
      for child in node.children.reverse do
        if !child.isLeaf then
          if let some cl := childResult.get child.id then
            let cl := translateLayout cl
            let subgridCtx := findSubgridContext childLayout.subgridContexts child.id
            stack := stack.push ⟨child, cl.borderRect.width, cl.borderRect.height,
                                 cl.borderRect.x, cl.borderRect.y, false, subgridCtx⟩

    | .none =>
      -- Leaf node, no children to layout
      pure ()

  LayoutResult.ofLayouts resultLayouts

/-! ## Layout With Debug -/

/-- Iteratively layout a tree starting from the root, collecting debug info. -/
def layoutDebug (root : LayoutNode) (availableWidth availableHeight : Length) : LayoutDebugResult := Id.run do
  let allSizes := measureAllIntrinsicSizes root
  let getSize : LayoutNode → Length × Length := fun node =>
    allSizes.getD node.id (0, 0)

  let mut resultLayouts : Array ComputedLayout := Array.mkEmpty allSizes.size
  let mut debug : LayoutDebug := { intrinsicSizes := allSizes }
  let mut stack : Array LayoutWorkItem := (Array.mkEmpty allSizes.size).push ⟨root, availableWidth, availableHeight, 0, 0, true, none⟩

  while !stack.isEmpty do
    let item := stack.back!
    stack := stack.pop
    let node := item.node
    let box := node.box

    let contentSize := getSize node
    let isContainer := !node.isLeaf
    let resolvedWidth := match box.width with
      | .auto => if isContainer then item.availableWidth else contentSize.1
      | dim => dim.resolve item.availableWidth contentSize.1
    let resolvedHeight := match box.height with
      | .auto => if isContainer then item.availableHeight else contentSize.2
      | dim => dim.resolve item.availableHeight contentSize.2
    let (resolvedWidth, resolvedHeight) := applyAspectRatio resolvedWidth resolvedHeight
      box.width.isAuto box.height.isAuto box.aspectRatio
    let width := box.clampWidth resolvedWidth
    let height := box.clampHeight resolvedHeight

    if item.addOwnLayout then
      let nodeRect := LayoutRect.mk' item.offsetX item.offsetY width height
      resultLayouts := resultLayouts.push (ComputedLayout.withPadding node.id nodeRect box.padding)

    match node.container with
    | .flex props =>
      let (childResult, flexDebug) :=
        layoutFlexContainerDebug props node.children width height box.padding getSize
      debug := { debug with flex := debug.flex.insert node.id flexDebug }
      let translateLayout := fun (cl : ComputedLayout) =>
        { cl with
          borderRect := cl.borderRect.translate item.offsetX item.offsetY
          contentRect := cl.contentRect.translate item.offsetX item.offsetY
        }
      for cl in childResult.layouts do
        resultLayouts := resultLayouts.push (translateLayout cl)

      for child in node.children.reverse do
        if !child.isLeaf then
          if let some cl := childResult.get child.id then
            let cl := translateLayout cl
            stack := stack.push ⟨child, cl.borderRect.width, cl.borderRect.height,
                                 cl.borderRect.x, cl.borderRect.y, false, none⟩

    | .grid props =>
      let childLayout := layoutGridContainerInternal props node.children width height box.padding
        getSize item.subgridContext true
      let childResult := childLayout.result
      if let some gridDebug := childLayout.debug then
        debug := { debug with grid := debug.grid.insert node.id gridDebug }
      let translateLayout := fun (cl : ComputedLayout) =>
        { cl with
          borderRect := cl.borderRect.translate item.offsetX item.offsetY
          contentRect := cl.contentRect.translate item.offsetX item.offsetY
        }
      for cl in childResult.layouts do
        resultLayouts := resultLayouts.push (translateLayout cl)

      for child in node.children.reverse do
        if !child.isLeaf then
          if let some cl := childResult.get child.id then
            let cl := translateLayout cl
            let subgridCtx := findSubgridContext childLayout.subgridContexts child.id
            stack := stack.push ⟨child, cl.borderRect.width, cl.borderRect.height,
                                 cl.borderRect.x, cl.borderRect.y, false, subgridCtx⟩

    | .none =>
      pure ()

  { result := LayoutResult.ofLayouts resultLayouts, debug }

/-! ## Layout Cache Instrumentation (M0 scaffolding)

This section provides runtime toggles and counters used by the demo runner and
tests. Full subtree cache implementation is introduced in later milestones.
-/

/-- Runtime controls for layout instrumentation/caching. -/
structure LayoutInstrumentationConfig where
  /-- Enable layout cache path. M0 records misses/recompute counts only. -/
  layoutCacheEnabled : Bool := false
  /-- Run strict validation by comparing tracked layout result to baseline layout. -/
  strictValidationMode : Bool := false
deriving Repr, BEq, Inhabited

/-- Per-call or cumulative instrumentation stats for layout execution. -/
structure LayoutInstrumentationStats where
  layoutCacheHits : Nat := 0
  layoutCacheMisses : Nat := 0
  reusedNodeCount : Nat := 0
  recomputedNodeCount : Nat := 0
  totalLayoutNanos : Nat := 0
  strictValidationChecks : Nat := 0
  strictValidationFailures : Nat := 0
  strictValidationNanos : Nat := 0
deriving Repr, BEq, Inhabited

namespace LayoutInstrumentationStats

def add (a b : LayoutInstrumentationStats) : LayoutInstrumentationStats :=
  { layoutCacheHits := a.layoutCacheHits + b.layoutCacheHits
    layoutCacheMisses := a.layoutCacheMisses + b.layoutCacheMisses
    reusedNodeCount := a.reusedNodeCount + b.reusedNodeCount
    recomputedNodeCount := a.recomputedNodeCount + b.recomputedNodeCount
    totalLayoutNanos := a.totalLayoutNanos + b.totalLayoutNanos
    strictValidationChecks := a.strictValidationChecks + b.strictValidationChecks
    strictValidationFailures := a.strictValidationFailures + b.strictValidationFailures
    strictValidationNanos := a.strictValidationNanos + b.strictValidationNanos }

def diff (next prev : LayoutInstrumentationStats) : LayoutInstrumentationStats :=
  { layoutCacheHits := next.layoutCacheHits - prev.layoutCacheHits
    layoutCacheMisses := next.layoutCacheMisses - prev.layoutCacheMisses
    reusedNodeCount := next.reusedNodeCount - prev.reusedNodeCount
    recomputedNodeCount := next.recomputedNodeCount - prev.recomputedNodeCount
    totalLayoutNanos := next.totalLayoutNanos - prev.totalLayoutNanos
    strictValidationChecks := next.strictValidationChecks - prev.strictValidationChecks
    strictValidationFailures := next.strictValidationFailures - prev.strictValidationFailures
    strictValidationNanos := next.strictValidationNanos - prev.strictValidationNanos }

end LayoutInstrumentationStats

initialize layoutInstrumentationConfigRef : IO.Ref LayoutInstrumentationConfig ←
  IO.mkRef {}

initialize layoutInstrumentationStatsRef : IO.Ref LayoutInstrumentationStats ←
  IO.mkRef {}

/-- Get active layout instrumentation settings. -/
def getLayoutInstrumentationConfig : IO LayoutInstrumentationConfig :=
  layoutInstrumentationConfigRef.get

/-- Set layout instrumentation settings. -/
def setLayoutInstrumentationConfig (config : LayoutInstrumentationConfig) : IO Unit :=
  layoutInstrumentationConfigRef.set config

/-- Reset cumulative layout instrumentation counters. -/
def resetLayoutInstrumentation : IO Unit :=
  layoutInstrumentationStatsRef.set {}

/-- Snapshot cumulative layout instrumentation counters. -/
def snapshotLayoutInstrumentation : IO LayoutInstrumentationStats :=
  layoutInstrumentationStatsRef.get

/-- Record a layout stats sample into cumulative counters. -/
def recordLayoutInstrumentation (stats : LayoutInstrumentationStats) : IO Unit :=
  layoutInstrumentationStatsRef.modify (·.add stats)

/-- Run layout and return M0 instrumentation stats for this call.
    In M0, cache-enabled mode records misses/recomputed nodes only. -/
def layoutWithInstrumentation (root : LayoutNode) (availableWidth availableHeight : Length)
    (config : LayoutInstrumentationConfig := {}) : LayoutResult × LayoutInstrumentationStats :=
  let result := layout root availableWidth availableHeight
  let recomputed := root.nodeCount
  let misses := if config.layoutCacheEnabled then 1 else 0
  (result, {
    layoutCacheHits := 0
    layoutCacheMisses := misses
    reusedNodeCount := 0
    recomputedNodeCount := recomputed
  })

/-- IO wrapper that applies active runtime config, optional strict validation,
    and records cumulative instrumentation. -/
def layoutTrackedIO (root : LayoutNode) (availableWidth availableHeight : Length)
    : IO (LayoutResult × LayoutInstrumentationStats) := do
  let config ← getLayoutInstrumentationConfig
  let t0 ← IO.monoNanosNow
  let (result, baseStats) := layoutWithInstrumentation root availableWidth availableHeight config
  let t1 ← IO.monoNanosNow
  let mut stats := { baseStats with totalLayoutNanos := t1 - t0 }
  if config.strictValidationMode then
    let tVal0 ← IO.monoNanosNow
    let baseline := layout root availableWidth availableHeight
    let tVal1 ← IO.monoNanosNow
    let failed := if baseline.layouts == result.layouts then 0 else 1
    stats := { stats with
      strictValidationChecks := 1
      strictValidationFailures := failed
      strictValidationNanos := tVal1 - tVal0
    }
  recordLayoutInstrumentation stats
  pure (result, stats)

end Trellis
