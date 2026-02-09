/-
  Arbor Widget Hit Testing
  Map screen coordinates to widget IDs with proper Z-order.
-/
import Afferent.UI.Arbor.Widget.Core
import Linalg.Spatial.Grid
import Linalg.Geometry.AABB2D
import Linalg.Vec2
import Std.Data.HashMap
import Trellis

namespace Afferent.Arbor

/-- Result of hit testing. -/
structure HitTestResult where
  /-- The hit widget ID (topmost widget at coordinates). -/
  widgetId : WidgetId
  /-- Path from root to hit widget (for bubbling). -/
  path : Array WidgetId
  /-- The widget's computed layout. -/
  layout : Trellis.ComputedLayout
deriving Repr, Inhabited

/-- Scroll offset for coordinate adjustment in nested scroll containers. -/
structure ScrollOffset where
  x : Float := 0
  y : Float := 0
deriving Repr, Inhabited

namespace ScrollOffset

def zero : ScrollOffset := {}

def add (a b : ScrollOffset) : ScrollOffset :=
  { x := a.x + b.x, y := a.y + b.y }

end ScrollOffset

/-- Transform for hit testing that includes scroll offset.
    Used to track cumulative transforms when descending into containers. -/
structure HitTransform where
  scrollX : Float := 0
  scrollY : Float := 0
deriving Repr, Inhabited

namespace HitTransform

def zero : HitTransform := {}

/-- Add scroll offset. -/
def addScroll (t : HitTransform) (dx dy : Float) : HitTransform :=
  { t with scrollX := t.scrollX + dx, scrollY := t.scrollY + dy }

/-- Transform screen coordinates to child coordinates.
    Applies scroll adjustment. -/
def transformPoint (t : HitTransform) (x y : Float) : Float × Float :=
  -- First apply scroll offset
  let scrolledX := x + t.scrollX
  let scrolledY := y + t.scrollY
  (scrolledX, scrolledY)

end HitTransform

def isAbsoluteWidgetForHit (w : Widget) : Bool :=
  match w.style? with
  | some style => style.position == .absolute
  | none => false

def isOverlayWidgetForHit (w : Widget) : Bool :=
  match w.style? with
  | some style => style.position == .absolute && style.layer == .overlay
  | none => false

def orderChildrenForHit (children : Array Widget) : Array Widget := Id.run do
  let mut flow : Array Widget := #[]
  let mut abs : Array Widget := #[]
  for child in children do
    if isAbsoluteWidgetForHit child then
      abs := abs.push child
    else
      flow := flow.push child
  flow ++ abs

/-- Information about an overlay widget for priority hit testing. -/
structure OverlayWidgetInfo where
  widget : Widget
  path : Array WidgetId
  transform : HitTransform
deriving Inhabited

/-- Collect all overlay widgets from the tree with their paths.
    Returns them in document order (later = rendered on top). -/
partial def collectOverlayWidgets (widget : Widget) (layouts : Trellis.LayoutResult)
    : Array OverlayWidgetInfo :=
  collectHelper widget #[] HitTransform.zero
where
  collectHelper (w : Widget) (path : Array WidgetId) (transform : HitTransform)
      : Array OverlayWidgetInfo :=
    let currentPath := path.push w.id

    -- Collect from children, keeping overlay widgets separate
    w.children.foldl (init := #[]) fun acc child =>
      let childTransform := match layouts.get w.id with
        | some _layout =>
          match w with
          | .scroll _ _ _ scrollState _ _ _ _ =>
            if isOverlayWidgetForHit child then transform
            else transform.addScroll scrollState.offsetX scrollState.offsetY
          | _ => transform
        | none => transform
      -- Recursively collect from child
      let childOverlays := collectHelper child currentPath childTransform
      let acc := acc ++ childOverlays
      -- If this child is overlay, add it to the result (after its children for z-order)
      if isOverlayWidgetForHit child then
        acc.push { widget := child, path := currentPath, transform := childTransform }
      else
        acc

/-- Perform hit testing on a widget tree.
    Returns the topmost widget at (x, y) in canvas coordinates.

    Z-order is determined by render order: children are rendered after parents,
    and later children are rendered after earlier children (thus appear on top).

    Overlay elements are rendered on top of normal content, so we
    check all overlay elements first (in reverse document order for z-priority),
    then fall back to normal tree traversal. -/
partial def hitTest (widget : Widget) (layouts : Trellis.LayoutResult)
    (x y : Float) : Option HitTestResult :=
  -- First pass: check all overlay widgets (they render on top)
  let overlays := collectOverlayWidgets widget layouts
  -- Check in reverse order (last in document = topmost)
  let rec checkOverlays (i : Nat) : Option HitTestResult :=
    if i >= overlays.size then
      none
    else
      let idx := overlays.size - 1 - i
      match overlays[idx]? with
      | some info =>
        match hitTestOverlay info.widget layouts x y info.path info.transform with
        | some result => some result
        | none => checkOverlays (i + 1)
      | none => checkOverlays (i + 1)

  match checkOverlays 0 with
  | some result => some result
  | none =>
    -- Second pass: normal tree traversal (excluding overlay widgets we already checked)
    hitTestHelper widget layouts x y #[] HitTransform.zero true
where
  /-- Hit test an overlay widget and its children. -/
  hitTestOverlay (w : Widget) (layouts : Trellis.LayoutResult)
      (x y : Float) (parentPath : Array WidgetId) (transform : HitTransform)
      : Option HitTestResult := do
    let layout ← layouts.get w.id
    let (adjX, adjY) := transform.transformPoint x y

    -- Check if point is inside this overlay widget's bounds
    let inside := match w with
      | .custom _ _ _ spec =>
          match spec.hitTest with
          | some hit => hit layout ⟨adjX, adjY⟩
          | none => layout.borderRect.contains adjX adjY
      | _ => layout.borderRect.contains adjX adjY

    if !inside then
      none

    let currentPath := parentPath.push w.id

    -- Compute child transform
    let childTransform := match w with
      | .scroll _ _ _ scrollState _ _ _ _ =>
        transform.addScroll scrollState.offsetX scrollState.offsetY
      | _ => transform

    -- Check children (use normal hit test helper for children)
    let children := orderChildrenForHit w.children
    let rec checkChildren (i : Nat) : Option HitTestResult :=
      if i >= children.size then
        none
      else
        let childIdx := children.size - 1 - i
        match children[childIdx]? with
        | some child =>
          match hitTestHelper child layouts x y currentPath childTransform true with
          | some result => some result
          | none => checkChildren (i + 1)
        | none => checkChildren (i + 1)

    match checkChildren 0 with
    | some result => some result
    | none => some { widgetId := w.id, path := currentPath, layout }

  /-- Normal tree traversal hit test.
      skipOverlay: if true, skip overlay widgets (they were already checked in first pass) -/
  hitTestHelper (w : Widget) (layouts : Trellis.LayoutResult)
      (x y : Float) (path : Array WidgetId) (transform : HitTransform)
      (skipOverlay : Bool) : Option HitTestResult := do
    -- Get this widget's layout
    let layout ← layouts.get w.id

    -- Transform coordinates using current transform
    let (adjX, adjY) := transform.transformPoint x y

    -- Check if point is within this widget's bounds
    let inside := match w with
      | .custom _ _ _ spec =>
          match spec.hitTest with
          | some hit => hit layout ⟨adjX, adjY⟩
          | none => layout.borderRect.contains adjX adjY
      | _ => layout.borderRect.contains adjX adjY

    -- Clip to bounds (restore original behavior for normal traversal)
    if !inside then
      none

    let currentPath := path.push w.id

    -- Compute child transform based on widget type
    let childTransform := match w with
      | .scroll _ _ _ scrollState _ _ _ _ =>
        transform.addScroll scrollState.offsetX scrollState.offsetY
      | _ => transform

    -- Check children in reverse order (last rendered = topmost)
    -- Skip overlay children if we already checked them in the first pass
    let children := if skipOverlay then
      w.children.filter (fun c => !isOverlayWidgetForHit c)
    else
      orderChildrenForHit w.children

    let rec checkChildren (i : Nat) : Option HitTestResult :=
      if i >= children.size then
        none
      else
        let childIdx := children.size - 1 - i
        match children[childIdx]? with
        | some child =>
          match hitTestHelper child layouts x y currentPath childTransform skipOverlay with
          | some result => some result
          | none => checkChildren (i + 1)
        | none => checkChildren (i + 1)

    match checkChildren 0 with
    | some result => some result
    | none => some { widgetId := w.id, path := currentPath, layout }

/-- Hit test and return just the path for bubbling (root to target). -/
def hitTestPath (widget : Widget) (layouts : Trellis.LayoutResult)
    (x y : Float) : Array WidgetId :=
  match hitTest widget layouts x y with
  | some result => result.path
  | none => #[]

/-- Hit test and return just the widget ID. -/
def hitTestId (widget : Widget) (layouts : Trellis.LayoutResult)
    (x y : Float) : Option WidgetId :=
  (hitTest widget layouts x y).map (·.widgetId)

/-- Find all widgets at a point (all overlapping widgets, topmost first).
    This can be useful for debugging or for events that affect multiple layers. -/
partial def hitTestAll (widget : Widget) (layouts : Trellis.LayoutResult)
    (x y : Float) : Array HitTestResult :=
  collectHits widget layouts x y #[] HitTransform.zero
where
  collectHits (w : Widget) (layouts : Trellis.LayoutResult)
      (x y : Float) (path : Array WidgetId) (transform : HitTransform)
      : Array HitTestResult :=
    match layouts.get w.id with
    | none => #[]
    | some layout =>
      let (adjX, adjY) := transform.transformPoint x y

      let inside := match w with
        | .custom _ _ _ spec =>
            match spec.hitTest with
            | some hit => hit layout ⟨adjX, adjY⟩
            | none => layout.borderRect.contains adjX adjY
        | _ => layout.borderRect.contains adjX adjY
      if !inside then
        #[]
      else
        let currentPath := path.push w.id

        -- Compute child transform based on widget type
        let childTransform := match w with
          | .scroll _ _ _ scrollState _ _ _ _ =>
            transform.addScroll scrollState.offsetX scrollState.offsetY
          | _ => transform

        -- Collect hits from children (in reverse order, topmost first)
        let children := orderChildrenForHit w.children
        let rec collectFromChildren (i : Nat) (acc : Array HitTestResult) : Array HitTestResult :=
          if i >= children.size then
            acc
          else
            let childIdx := children.size - 1 - i
            match children[childIdx]? with
            | some child =>
              let childHits := collectHits child layouts x y currentPath childTransform
              collectFromChildren (i + 1) (childHits ++ acc)
            | none => collectFromChildren (i + 1) acc

        -- Start with this widget, then add child hits in front
        let thisHit : HitTestResult := { widgetId := w.id, path := currentPath, layout }
        collectFromChildren 0 #[thisHit]

/-- Check if a point is within a specific widget's bounds. -/
def isPointInWidget (layouts : Trellis.LayoutResult)
    (widgetId : WidgetId) (x y : Float) : Bool :=
  match layouts.get widgetId with
  | some layout => layout.borderRect.contains x y
  | none => false

/-- Get the path from root to a specific widget ID. -/
partial def pathToWidget (widget : Widget) (targetId : WidgetId) : Option (Array WidgetId) :=
  findPath widget targetId #[]
where
  findPath (w : Widget) (targetId : WidgetId) (path : Array WidgetId) : Option (Array WidgetId) :=
    let currentPath := path.push w.id
    if w.id == targetId then
      some currentPath
    else
      let rec searchChildren (children : Array Widget) (i : Nat) : Option (Array WidgetId) :=
        if i >= children.size then
          none
        else
          match children[i]? with
          | some child =>
            match findPath child targetId currentPath with
            | some result => some result
            | none => searchChildren children (i + 1)
          | none => searchChildren children (i + 1)
      searchChildren w.children 0

/-- Spatial hit test index item. -/
structure HitTestIndexItem where
  widget : Widget
  layout : Trellis.ComputedLayout
  transform : HitTransform
  screenBounds : Linalg.AABB2D
  isAbsolute : Bool
  inOverlay : Bool
  zOrder : Nat
deriving Inhabited

/-- Spatial hit test index built from a widget tree + layouts. -/
structure HitTestIndex where
  items : Array HitTestIndexItem
  grid : Linalg.Spatial.Grid2D
  names : Array String
  nameMap : Std.HashMap String WidgetId
  parentMap : Std.HashMap WidgetId WidgetId
deriving Inhabited

/-- Reusable scratch buffers for hit-test index construction. -/
structure HitTestBuildScratch where
  bounds : Array Linalg.AABB2D := Array.mkEmpty 1024
  nameMapCapacity : Nat := 1024
  parentMapCapacity : Nat := 1024
deriving Inhabited

private def toScreenPoint (t : HitTransform) (x y : Float) : Float × Float :=
  let screenX := x - t.scrollX
  let screenY := y - t.scrollY
  (screenX, screenY)

private def localHitRect (layout : Trellis.ComputedLayout) : Trellis.LayoutRect :=
  layout.borderRect

private def rectToScreenBounds (t : HitTransform) (r : Trellis.LayoutRect) : Linalg.AABB2D :=
  let (x1, y1) := toScreenPoint t r.x r.y
  let (x2, y2) := toScreenPoint t (r.x + r.width) (r.y + r.height)
  let minX := min x1 x2
  let maxX := max x1 x2
  let minY := min y1 y2
  let maxY := max y1 y2
  Linalg.AABB2D.fromMinMax (Linalg.Vec2.mk minX minY) (Linalg.Vec2.mk maxX maxY)

private def childTransformFor (w : Widget) (_layout : Trellis.ComputedLayout)
    (_layouts : Trellis.LayoutResult) (transform : HitTransform) : HitTransform :=
  match w with
  | .scroll _ _ _ scrollState _ _ _ _ =>
    transform.addScroll scrollState.offsetX scrollState.offsetY
  | _ => transform

private def isPointInsideWidget (w : Widget) (layout : Trellis.ComputedLayout) (adjX adjY : Float) : Bool :=
  match w with
  | .custom _ _ _ spec =>
      match spec.hitTest with
      | some hit => hit layout ⟨adjX, adjY⟩
      | none => layout.borderRect.contains adjX adjY
  | _ => layout.borderRect.contains adjX adjY

private structure HitTestBuildState where
  items : Array HitTestIndexItem := #[]
  bounds : Array Linalg.AABB2D := #[]
  zOrder : Nat := 0
  names : Array String := #[]
  nameMap : Std.HashMap String WidgetId := {}
  parentMap : Std.HashMap WidgetId WidgetId := {}
deriving Inhabited

private def overlayZBoost : Nat := 1000000000

/-- Build a spatial index for hit testing.
    This is a broad-phase accelerator; exact checks still use widget hit logic. -/
partial def buildHitTestIndexWithScratch (root : Widget) (layouts : Trellis.LayoutResult)
    (reuseIndex : Option HitTestIndex) (scratch : HitTestBuildScratch)
    : HitTestIndex × HitTestBuildScratch :=
  let rec go (w : Widget) (path : Array WidgetId) (parentId : Option WidgetId) (transform : HitTransform)
      (parentClip : Option Linalg.AABB2D) (clippedNonAbs : Bool) (inOverlay : Bool)
      : StateM HitTestBuildState Unit := do
    match layouts.get w.id with
    | none => pure ()
    | some layout =>
      match parentId with
      | some pid =>
          modify fun state => { state with parentMap := state.parentMap.insert w.id pid }
      | none => pure ()
      let isAbs := isOverlayWidgetForHit w
      let overlayLayer := inOverlay || isAbs
      let currentPath := path.push w.id
      let hitRect := localHitRect layout
      let screenBounds := rectToScreenBounds transform hitRect
      let effectiveClip :=
        if isAbs then
          some screenBounds
        else
          match parentClip with
          | some clip => Linalg.AABB2D.intersection clip screenBounds
          | none => some screenBounds
      let shouldAdd := isAbs || (!clippedNonAbs && effectiveClip.isSome)
      if shouldAdd then
        let bounds := match effectiveClip with
          | some b => b
          | none => screenBounds
        let state ← get
        let item := {
          widget := w
          layout := layout
          transform := transform
          screenBounds := bounds
          isAbsolute := isAbs
          inOverlay := overlayLayer
          -- Overlay widgets must always win z-order over normal-flow widgets.
          zOrder := if overlayLayer then state.zOrder + overlayZBoost else state.zOrder
        }
        set {
          state with
          items := state.items.push item
          bounds := state.bounds.push bounds
          zOrder := state.zOrder + 1
        }

      match Widget.name? w with
      | some name =>
          modify fun state =>
            let (existing, nameMap) := state.nameMap.getThenInsertIfNew? name w.id
            let names := if existing.isSome then state.names else state.names.push name
            { state with
              names := names
              nameMap := nameMap
            }
      | none => pure ()

      let nextClipped := clippedNonAbs || (!isAbs && effectiveClip.isNone)
      let childClip := if isAbs then some screenBounds else effectiveClip
      -- Traverse in flow-first, absolute-second order without materializing a reordered array.
      for child in w.children do
        if !isAbsoluteWidgetForHit child then
          let childTransform :=
            if isOverlayWidgetForHit child then transform
            else childTransformFor w layout layouts transform
          go child currentPath (some w.id) childTransform childClip nextClipped overlayLayer
      for child in w.children do
        if isAbsoluteWidgetForHit child then
          let childTransform :=
            if isOverlayWidgetForHit child then transform
            else childTransformFor w layout layouts transform
          go child currentPath (some w.id) childTransform childClip nextClipped overlayLayer

  let initialCapacity := max 8 layouts.layouts.size
  let reusedItems := match reuseIndex with
    | some idx => idx.items.shrink 0
    | none => Array.mkEmpty initialCapacity
  let reusedNames := match reuseIndex with
    | some idx => idx.names.shrink 0
    | none => Array.mkEmpty initialCapacity
  let reusedNameMapCap := match reuseIndex with
    | some idx => max scratch.nameMapCapacity (max initialCapacity idx.nameMap.size)
    | none => max scratch.nameMapCapacity initialCapacity
  let reusedParentMapCap := match reuseIndex with
    | some idx => max scratch.parentMapCapacity (max initialCapacity idx.parentMap.size)
    | none => max scratch.parentMapCapacity initialCapacity
  let initialState : HitTestBuildState := {
    items := reusedItems
    bounds := scratch.bounds.shrink 0
    names := reusedNames
    nameMap := Std.HashMap.emptyWithCapacity reusedNameMapCap
    parentMap := Std.HashMap.emptyWithCapacity reusedParentMapCap
  }
  let (_, state) := (go root #[] none HitTransform.zero none false false).run initialState

  let grid := Linalg.Spatial.Grid2D.buildAuto state.bounds
  let index := {
    items := state.items
    grid := grid
    names := state.names
    nameMap := state.nameMap
    parentMap := state.parentMap
  }
  let nextScratch : HitTestBuildScratch := {
    bounds := state.bounds.shrink 0
    nameMapCapacity := max scratch.nameMapCapacity state.nameMap.size
    parentMapCapacity := max scratch.parentMapCapacity state.parentMap.size
  }
  (index, nextScratch)

/-- Build a spatial index for hit testing.
    This is a broad-phase accelerator; exact checks still use widget hit logic. -/
partial def buildHitTestIndex (root : Widget) (layouts : Trellis.LayoutResult) : HitTestIndex :=
  (buildHitTestIndexWithScratch root layouts none {}).1

/-- Reconstruct root-to-target path for an indexed hit from parent links. -/
private def reconstructIndexedPath (index : HitTestIndex) (wid : WidgetId) : Array WidgetId :=
  Id.run do
    let mut acc : Array WidgetId := #[]
    let mut current : Option WidgetId := some wid
    let mut fuel := index.parentMap.size + 1
    while fuel > 0 do
      match current with
      | some id =>
          acc := acc.push id
          current := index.parentMap.get? id
          fuel := fuel - 1
      | none =>
          fuel := 0
    acc.reverse

/-- Hit test using a pre-built spatial index (fast broad-phase). -/
def hitTestPathIndexed (index : HitTestIndex) (x y : Float) : Array WidgetId := Id.run do
  let p := Linalg.Vec2.mk x y
  let query := Linalg.AABB2D.fromPoint p
  let candidates := Linalg.Spatial.Grid2D.queryRect index.grid query
  let mut best : Option HitTestIndexItem := none
  for idx in candidates do
    match index.items[idx]? with
    | some item =>
        if item.screenBounds.containsPoint p then
          let (adjX, adjY) := item.transform.transformPoint x y
          if isPointInsideWidget item.widget item.layout adjX adjY then
            match best with
            | none => best := some item
            | some current =>
                if item.zOrder > current.zOrder then
                  best := some item
    | none => pure ()
  match best with
  | some item => reconstructIndexedPath index item.widget.id
  | none => #[]

/-- Hit test ID using a pre-built spatial index. -/
def hitTestIdIndexed (index : HitTestIndex) (x y : Float) : Option WidgetId :=
  let path := hitTestPathIndexed index x y
  if path.isEmpty then none else some path.back!

end Afferent.Arbor
