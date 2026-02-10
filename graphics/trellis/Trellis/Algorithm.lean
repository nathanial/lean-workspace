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
import Trellis.LayoutCache
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

/-! ## Cached Layout Engine (M3) -/

private def sigTag (tag : Nat) : UInt64 :=
  UInt64.ofNat tag

private def sigHashRepr {α : Type} [Repr α] (value : α) : UInt64 :=
  hash (toString (repr value))

private def sigMix64 (x : UInt64) : UInt64 :=
  let z1 := x + (0x9e3779b97f4a7c15 : UInt64)
  let z2 := (z1 ^^^ (z1 >>> 30)) * (0xbf58476d1ce4e5b9 : UInt64)
  let z3 := (z2 ^^^ (z2 >>> 27)) * (0x94d049bb133111eb : UInt64)
  z3 ^^^ (z3 >>> 31)

private def sigCombine (a b : UInt64) : UInt64 :=
  let salt : UInt64 := 0x9e3779b97f4a7c15
  sigMix64 (a ^^^ (b + salt) ^^^ (a <<< 6) ^^^ (a >>> 2))

private def localLayoutSignature (node : LayoutNode) (childSigs : Array UInt64) : UInt64 :=
  let sig0 := sigTag 0x4c41594f5554 -- "LAYOUT"
  let sig1 := sigCombine sig0 (sigHashRepr node.box)
  let sig2 := sigCombine sig1 (sigHashRepr node.container)
  let sig3 := sigCombine sig2 (sigHashRepr node.item)
  let sig4 := sigCombine sig3 (sigHashRepr node.content)
  let sig5 := sigCombine sig4 (UInt64.ofNat childSigs.size)
  childSigs.foldl sigCombine sig5

private inductive SignatureWorkItem where
  | visit (node : LayoutNode)
  | combine (node : LayoutNode)
deriving Inhabited

/-- Compute subtree layout signatures for all nodes in one post-order pass. -/
private def measureAllLayoutSignatures (root : LayoutNode) : Std.HashMap Nat UInt64 := Id.run do
  let estimatedNodes := max 8 root.nodeCount
  let mut signatures : Std.HashMap Nat UInt64 := Std.HashMap.emptyWithCapacity estimatedNodes
  let mut stack : Array SignatureWorkItem := (Array.mkEmpty estimatedNodes).push (.visit root)
  while !stack.isEmpty do
    let item := stack.back!
    stack := stack.pop
    match item with
    | .visit node =>
      if signatures.contains node.id then
        continue
      if node.children.isEmpty then
        signatures := signatures.insert node.id (localLayoutSignature node #[])
      else
        stack := stack.push (.combine node)
        for child in node.children.reverse do
          stack := stack.push (.visit child)
    | .combine node =>
      let childSigs := node.children.map fun child =>
        signatures.getD child.id 0
      signatures := signatures.insert node.id (localLayoutSignature node childSigs)
  signatures

private def subgridContextSignature (subgridContext : Option SubgridContext) : UInt64 :=
  sigHashRepr subgridContext

private def buildLayoutCacheKey (signatures : Std.HashMap Nat UInt64)
    (item : LayoutWorkItem) : LayoutCacheKey :=
  { subtreeId := item.node.id
    signature := signatures.getD item.node.id 0
    availableWidth := item.availableWidth
    availableHeight := item.availableHeight
    subgridSignature := subgridContextSignature item.subgridContext }

private def appendTranslatedLayouts
    (target : Array ComputedLayout)
    (source : Array ComputedLayout)
    (dx dy : Length)
    (skipRoot : Bool := false) : Array ComputedLayout := Id.run do
  let mut out := target
  let start := if skipRoot then min 1 source.size else 0
  for i in [start:source.size] do
    let cl := source[i]!
    out := out.push {
      cl with
      borderRect := cl.borderRect.translate dx dy
      contentRect := cl.contentRect.translate dx dy
    }
  out

private def findLayoutByNodeId (layouts : Array ComputedLayout) (nodeId : Nat) : Option ComputedLayout := Id.run do
  for cl in layouts do
    if cl.nodeId == nodeId then
      return some cl
  none

private structure PendingCacheBuild where
  nodeId : Nat
  cacheKey : LayoutCacheKey
  rootLocal : ComputedLayout
  childLayoutsLocal : Array ComputedLayout
  nonLeafChildIds : Array Nat
deriving Inhabited

private inductive CachedLayoutWorkItem where
  | visit (item : LayoutWorkItem)
  | complete (pending : PendingCacheBuild)
deriving Inhabited

/-- Internal cache-pass stats before timing/validation decoration. -/
private structure CachePassStats where
  layoutCacheHits : Nat := 0
  layoutCacheMisses : Nat := 0
  reusedNodeCount : Nat := 0
  recomputedNodeCount : Nat := 0

/-- Cached tracked layout pass. Uses LRU subtree cache and returns updated state. -/
private def layoutWithCacheState (cache : LayoutCache)
    (root : LayoutNode) (availableWidth availableHeight : Length)
    : LayoutResult × CachePassStats × LayoutCache := Id.run do
  let allSizes := measureAllIntrinsicSizes root
  let allSignatures := measureAllLayoutSignatures root
  let getSize : LayoutNode → Length × Length := fun node =>
    allSizes.getD node.id (0, 0)

  let estimatedNodes := max 8 allSizes.size
  let mut resultLayouts : Array ComputedLayout := Array.mkEmpty estimatedNodes
  let mut stack : Array CachedLayoutWorkItem :=
    (Array.mkEmpty estimatedNodes).push (.visit ⟨root, availableWidth, availableHeight, 0, 0, true, none⟩)
  let mut cacheState := cache
  let mut localSubtrees : Std.HashMap Nat (Array ComputedLayout) :=
    Std.HashMap.emptyWithCapacity estimatedNodes
  let mut hits := 0
  let mut misses := 0
  let mut reusedNodes := 0

  while !stack.isEmpty do
    let work := stack.back!
    stack := stack.pop
    match work with
    | .visit item =>
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
      let rootLocal :=
        ComputedLayout.withPadding node.id (LayoutRect.mk' 0 0 width height) box.padding

      if node.isLeaf then
        if item.addOwnLayout then
          resultLayouts := resultLayouts.push {
            rootLocal with
            borderRect := rootLocal.borderRect.translate item.offsetX item.offsetY
            contentRect := rootLocal.contentRect.translate item.offsetX item.offsetY
          }
      else
        let cacheKey := buildLayoutCacheKey allSignatures item
        match cacheState.find? cacheKey with
        | some cached =>
          hits := hits + 1
          let skipRoot := !item.addOwnLayout
          let reusedNow :=
            if skipRoot then
              cached.layouts.size - min 1 cached.layouts.size
            else
              cached.layouts.size
          reusedNodes := reusedNodes + reusedNow
          resultLayouts := appendTranslatedLayouts resultLayouts cached.layouts item.offsetX item.offsetY skipRoot
          localSubtrees := localSubtrees.insert node.id cached.layouts
          cacheState := cacheState.touch cacheKey
        | none =>
          misses := misses + 1
          if item.addOwnLayout then
            resultLayouts := resultLayouts.push {
              rootLocal with
              borderRect := rootLocal.borderRect.translate item.offsetX item.offsetY
              contentRect := rootLocal.contentRect.translate item.offsetX item.offsetY
            }
          match node.container with
          | .flex props =>
            let childResult := layoutFlexContainer props node.children width height box.padding getSize
            resultLayouts := appendTranslatedLayouts resultLayouts childResult.layouts item.offsetX item.offsetY
            let nonLeafChildIds := node.children.foldl (init := #[]) fun acc child =>
              if child.isLeaf then acc else acc.push child.id
            stack := stack.push (.complete {
              nodeId := node.id
              cacheKey := cacheKey
              rootLocal := rootLocal
              childLayoutsLocal := childResult.layouts
              nonLeafChildIds := nonLeafChildIds
            })
            for child in node.children.reverse do
              if !child.isLeaf then
                if let some cl := childResult.get child.id then
                  stack := stack.push (.visit ⟨child, cl.borderRect.width, cl.borderRect.height,
                    cl.borderRect.x + item.offsetX, cl.borderRect.y + item.offsetY, false, none⟩)
          | .grid props =>
            let childLayout := layoutGridContainerInternal props node.children width height box.padding
              getSize item.subgridContext false
            let childResult := childLayout.result
            resultLayouts := appendTranslatedLayouts resultLayouts childResult.layouts item.offsetX item.offsetY
            let nonLeafChildIds := node.children.foldl (init := #[]) fun acc child =>
              if child.isLeaf then acc else acc.push child.id
            stack := stack.push (.complete {
              nodeId := node.id
              cacheKey := cacheKey
              rootLocal := rootLocal
              childLayoutsLocal := childResult.layouts
              nonLeafChildIds := nonLeafChildIds
            })
            for child in node.children.reverse do
              if !child.isLeaf then
                if let some cl := childResult.get child.id then
                  let subgridCtx := findSubgridContext childLayout.subgridContexts child.id
                  stack := stack.push (.visit ⟨child, cl.borderRect.width, cl.borderRect.height,
                    cl.borderRect.x + item.offsetX, cl.borderRect.y + item.offsetY, false, subgridCtx⟩)
          | .none =>
            let localLayouts := #[rootLocal]
            localSubtrees := localSubtrees.insert node.id localLayouts
            cacheState := cacheState.insert cacheKey { layouts := localLayouts }

    | .complete pending =>
      let mut localLayouts : Array ComputedLayout := Array.mkEmpty (pending.childLayoutsLocal.size + 1)
      localLayouts := localLayouts.push pending.rootLocal
      for cl in pending.childLayoutsLocal do
        localLayouts := localLayouts.push cl
      for childId in pending.nonLeafChildIds do
        match localSubtrees[childId]? with
        | some childLocal =>
          localSubtrees := localSubtrees.erase childId
          if let some childDirect := findLayoutByNodeId pending.childLayoutsLocal childId then
            for i in [1:childLocal.size] do
              let cl := childLocal[i]!
              localLayouts := localLayouts.push {
                cl with
                borderRect := cl.borderRect.translate childDirect.borderRect.x childDirect.borderRect.y
                contentRect := cl.contentRect.translate childDirect.borderRect.x childDirect.borderRect.y
              }
        | none =>
          pure ()
      localSubtrees := localSubtrees.insert pending.nodeId localLayouts
      cacheState := cacheState.insert pending.cacheKey { layouts := localLayouts }

  let totalNodes := root.nodeCount
  let reusedNodeCount := min reusedNodes totalNodes
  let recomputedNodeCount := totalNodes - reusedNodeCount
  let stats : CachePassStats := {
    layoutCacheHits := hits
    layoutCacheMisses := misses
    reusedNodeCount := reusedNodeCount
    recomputedNodeCount := recomputedNodeCount
  }
  (LayoutResult.ofLayouts resultLayouts, stats, cacheState)

/-! ## Layout Cache Instrumentation -/

/-- Runtime controls for layout instrumentation/caching. -/
structure LayoutInstrumentationConfig where
  /-- Enable subtree layout cache path in `layoutTrackedIO`. -/
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

initialize layoutCacheRef : IO.Ref LayoutCache ←
  IO.mkRef LayoutCache.empty

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

/-- Clear persistent subtree layout cache entries. -/
def resetLayoutCache : IO Unit :=
  layoutCacheRef.set LayoutCache.empty

/-- Record a layout stats sample into cumulative counters. -/
def recordLayoutInstrumentation (stats : LayoutInstrumentationStats) : IO Unit :=
  layoutInstrumentationStatsRef.modify (·.add stats)

/-- Pure instrumentation helper.
    Cache-enabled mode uses an empty cache state (single-call simulation). -/
def layoutWithInstrumentation (root : LayoutNode) (availableWidth availableHeight : Length)
    (config : LayoutInstrumentationConfig := {}) : LayoutResult × LayoutInstrumentationStats :=
  if config.layoutCacheEnabled then
    let (result, cacheStats, _cache') := layoutWithCacheState LayoutCache.empty root availableWidth availableHeight
    let stats : LayoutInstrumentationStats := {
      layoutCacheHits := cacheStats.layoutCacheHits
      layoutCacheMisses := cacheStats.layoutCacheMisses
      reusedNodeCount := cacheStats.reusedNodeCount
      recomputedNodeCount := cacheStats.recomputedNodeCount
    }
    (result, stats)
  else
    let result := layout root availableWidth availableHeight
    (result, {
      layoutCacheHits := 0
      layoutCacheMisses := 0
      reusedNodeCount := 0
      recomputedNodeCount := root.nodeCount
    })

/-- IO wrapper that applies active runtime config, optional strict validation,
    and records cumulative instrumentation. -/
def layoutTrackedIO (root : LayoutNode) (availableWidth availableHeight : Length)
    : IO (LayoutResult × LayoutInstrumentationStats) := do
  let config ← getLayoutInstrumentationConfig
  let t0 ← IO.monoNanosNow
  let (result, baseStats) ←
    if config.layoutCacheEnabled then
      let cacheState ← layoutCacheRef.get
      let (result, cacheStats, cacheState') := layoutWithCacheState cacheState root availableWidth availableHeight
      layoutCacheRef.set cacheState'
      let stats : LayoutInstrumentationStats := {
        layoutCacheHits := cacheStats.layoutCacheHits
        layoutCacheMisses := cacheStats.layoutCacheMisses
        reusedNodeCount := cacheStats.reusedNodeCount
        recomputedNodeCount := cacheStats.recomputedNodeCount
      }
      pure (result, stats)
    else
      pure (layoutWithInstrumentation root availableWidth availableHeight config)
  let t1 ← IO.monoNanosNow
  let mut stats := { baseStats with totalLayoutNanos := t1 - t0 }
  if config.strictValidationMode then
    let tVal0 ← IO.monoNanosNow
    let baseline := layout root availableWidth availableHeight
    let tVal1 ← IO.monoNanosNow
    let failed := if baseline.layouts == result.layouts then 0 else 1
    let validationNanos := max 1 (tVal1 - tVal0)
    stats := { stats with
      strictValidationChecks := 1
      strictValidationFailures := failed
      strictValidationNanos := validationNanos
    }
  recordLayoutInstrumentation stats
  pure (result, stats)

end Trellis
