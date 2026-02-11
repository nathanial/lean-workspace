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

/-- Spatial hit test index item. -/
structure HitTestIndexItem where
  widget : Widget
  layout : Trellis.ComputedLayout
  /-- Index into `HitTestIndex.pathNodes` for this widget's full ancestry path. -/
  pathNode : Nat
  transform : HitTransform
  screenBounds : Linalg.AABB2D
  isAbsolute : Bool
  inOverlay : Bool
  zOrder : Nat
deriving Inhabited

/-- Compact linked representation of widget ancestry path. -/
structure HitPathNode where
  widgetId : WidgetId
  parent : Option Nat := none
deriving Inhabited

/-- Spatial hit test index built from a widget tree + layouts. -/
structure HitTestIndex where
  items : Array HitTestIndexItem
  pathNodes : Array HitPathNode
  grid : Linalg.Spatial.Grid2D
  componentMap : Std.HashMap ComponentId WidgetId
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
  | .scroll _ _ _ scrollState _ _ _ _ _ =>
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
  pathNodes : Array HitPathNode := #[]
  zOrder : Nat := 0
  componentMap : Std.HashMap ComponentId WidgetId := {}
deriving Inhabited

/-- Build a spatial index for hit testing.
    This is a broad-phase accelerator; exact checks still use widget hit logic. -/
partial def buildHitTestIndex (root : Widget) (layouts : Trellis.LayoutResult) : HitTestIndex :=
  let rec go (w : Widget) (parentPathNode : Option Nat) (transform : HitTransform)
      (parentClip : Option Linalg.AABB2D) (clippedNonAbs : Bool) (inOverlay : Bool)
      : StateM HitTestBuildState Unit := do
    match layouts.get w.id with
    | none => pure ()
    | some layout =>
      let pathNode ← do
        let state ← get
        let idx := state.pathNodes.size
        let pathEntry : HitPathNode := { widgetId := w.id, parent := parentPathNode }
        set { state with pathNodes := state.pathNodes.push pathEntry }
        pure idx
      let isAbs := isOverlayWidgetForHit w
      let overlayLayer := inOverlay || isAbs
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
          pathNode := pathNode
          transform := transform
          screenBounds := bounds
          isAbsolute := isAbs
          inOverlay := overlayLayer
          zOrder := state.zOrder
        }
        set { state with items := state.items.push item, zOrder := state.zOrder + 1 }

      match Widget.componentId? w with
      | some componentId =>
          modify fun state => { state with componentMap := state.componentMap.insert componentId w.id }
      | none => pure ()

      let nextClipped := clippedNonAbs || (!isAbs && effectiveClip.isNone)
      let childClip := if isAbs then some screenBounds else effectiveClip
      let children := orderChildrenForHit w.children
      for child in children do
        let childTransform :=
          if isOverlayWidgetForHit child then transform
          else childTransformFor w layout layouts transform
        go child (some pathNode) childTransform childClip nextClipped overlayLayer

  let (_, state) := (go root none HitTransform.zero none false false).run {}

  -- Ensure overlay widgets sort above non-overlay widgets.
  let maxNonOverlay := state.items.foldl (init := 0) fun acc item =>
    if item.inOverlay then acc else max acc item.zOrder
  let absBase := maxNonOverlay + 1
  let items' := state.items.map fun item =>
    if item.inOverlay then { item with zOrder := item.zOrder + absBase } else item

  let bounds := items'.map (fun item => item.screenBounds)
  let grid := Linalg.Spatial.Grid2D.buildAuto bounds
  { items := items', pathNodes := state.pathNodes, grid := grid, componentMap := state.componentMap }

private def reconstructPath (index : HitTestIndex) (pathNode : Nat) : Array WidgetId := Id.run do
  let mut revPath : Array WidgetId := #[]
  let mut cursor : Option Nat := some pathNode
  while cursor.isSome do
    match cursor with
    | some nodeIdx =>
      match index.pathNodes[nodeIdx]? with
      | some node =>
        revPath := revPath.push node.widgetId
        cursor := node.parent
      | none =>
        cursor := none
    | none => pure ()
  let mut path : Array WidgetId := Array.mkEmpty revPath.size
  let mut i := revPath.size
  while i > 0 do
    i := i - 1
    path := path.push revPath[i]!
  path

/-- Hit test using a pre-built spatial index (fast broad-phase). -/
def hitTestPathIndexed (index : HitTestIndex) (x y : Float) : Array WidgetId := Id.run do
  let p := Linalg.Vec2.mk x y
  let query := Linalg.AABB2D.fromPoint p
  let candidates := Linalg.Spatial.Grid2D.queryRect index.grid query
  let mut bestIdx : Option Nat := none
  for idx in candidates do
    match index.items[idx]? with
    | some item =>
        if item.screenBounds.containsPoint p then
          let (adjX, adjY) := item.transform.transformPoint x y
          if isPointInsideWidget item.widget item.layout adjX adjY then
            match bestIdx with
            | none => bestIdx := some idx
            | some currentIdx =>
                if let some current := index.items[currentIdx]? then
                  if item.zOrder > current.zOrder then
                    bestIdx := some idx
                else
                  bestIdx := some idx
    | none => pure ()
  match bestIdx with
  | some idx =>
    match index.items[idx]? with
    | some item => reconstructPath index item.pathNode
    | none => #[]
  | none => #[]

/-- Hit test ID using a pre-built spatial index. -/
def hitTestIdIndexed (index : HitTestIndex) (x y : Float) : Option WidgetId :=
  let path := hitTestPathIndexed index x y
  if path.isEmpty then none else some path.back!

end Afferent.Arbor
