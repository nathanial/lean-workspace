/-
  Trellis Layout Result
  Output types from layout computation.
-/
import Trellis.Types
import Std.Data.HashMap

namespace Trellis

/-- A computed rectangle with position and size. -/
structure LayoutRect where
  x : Length
  y : Length
  width : Length
  height : Length
deriving Repr, BEq, Inhabited

namespace LayoutRect

def zero : LayoutRect := ⟨0, 0, 0, 0⟩

def mk' (x y width height : Length) : LayoutRect := ⟨x, y, width, height⟩

/-- Create from position and size. -/
def fromPosSize (x y : Length) (width height : Length) : LayoutRect :=
  ⟨x, y, width, height⟩

/-- Get the right edge x coordinate. -/
def right (r : LayoutRect) : Length := r.x + r.width

/-- Get the bottom edge y coordinate. -/
def bottom (r : LayoutRect) : Length := r.y + r.height

/-- Get the center point. -/
def center (r : LayoutRect) : Length × Length :=
  (r.x + r.width / 2, r.y + r.height / 2)

/-- Check if a point is inside this rect. -/
def contains (r : LayoutRect) (px py : Length) : Bool :=
  px >= r.x && px <= r.right && py >= r.y && py <= r.bottom

/-- Translate by an offset. -/
def translate (r : LayoutRect) (dx dy : Length) : LayoutRect :=
  ⟨r.x + dx, r.y + dy, r.width, r.height⟩

/-- Inset by edge amounts. -/
def inset (r : LayoutRect) (insets : EdgeInsets) : LayoutRect :=
  ⟨r.x + insets.left,
   r.y + insets.top,
   r.width - insets.horizontal,
   r.height - insets.vertical⟩

/-- Expand by edge amounts (opposite of inset). -/
def expand (r : LayoutRect) (insets : EdgeInsets) : LayoutRect :=
  ⟨r.x - insets.left,
   r.y - insets.top,
   r.width + insets.horizontal,
   r.height + insets.vertical⟩

end LayoutRect

/-- Computed layout for a single node. -/
structure ComputedLayout where
  nodeId : Nat
  /-- Border box (includes margin area for positioning). -/
  borderRect : LayoutRect
  /-- Content box (actual drawable area after padding). -/
  contentRect : LayoutRect
deriving Repr, BEq, Inhabited

namespace ComputedLayout

/-- Create a computed layout with same rect for border and content. -/
def simple (nodeId : Nat) (rect : LayoutRect) : ComputedLayout :=
  { nodeId, borderRect := rect, contentRect := rect }

/-- Create with insets applied. -/
def withPadding (nodeId : Nat) (rect : LayoutRect) (padding : EdgeInsets) : ComputedLayout :=
  { nodeId, borderRect := rect, contentRect := rect.inset padding }

/-- Get the main rect for drawing. -/
def rect (cl : ComputedLayout) : LayoutRect := cl.borderRect

/-- Get x position. -/
def x (cl : ComputedLayout) : Length := cl.borderRect.x

/-- Get y position. -/
def y (cl : ComputedLayout) : Length := cl.borderRect.y

/-- Get width. -/
def width (cl : ComputedLayout) : Length := cl.borderRect.width

/-- Get height. -/
def height (cl : ComputedLayout) : Length := cl.borderRect.height

end ComputedLayout

/-- Complete layout result for a tree.
    Uses both an array for iteration and a HashMap for O(1) lookups. -/
structure LayoutResult where
  layouts : Array ComputedLayout
  layoutMap : Std.HashMap Nat ComputedLayout := {}
  /-- Deterministic fingerprint of all `layouts` entries in insertion order. -/
  fingerprint : UInt64 := 14695981039346656037
deriving Inhabited

namespace LayoutResult

private def fpPrime : UInt64 := 1099511628211

private def fpMixUInt64 (h v : UInt64) : UInt64 :=
  let x := v + 0x9e3779b97f4a7c15
  (h ^^^ x) * fpPrime

private def fpMixNat (h : UInt64) (n : Nat) : UInt64 :=
  fpMixUInt64 h (UInt64.ofNat n)

private def fpMixFloat (h : UInt64) (f : Float) : UInt64 :=
  fpMixUInt64 h f.toUInt64

private def fpMixRect (h : UInt64) (r : LayoutRect) : UInt64 :=
  let h1 := fpMixFloat h r.x
  let h2 := fpMixFloat h1 r.y
  let h3 := fpMixFloat h2 r.width
  fpMixFloat h3 r.height

private def fpMixLayout (h : UInt64) (cl : ComputedLayout) : UInt64 :=
  let h0 := fpMixUInt64 h 0xA1
  let h1 := fpMixNat h0 cl.nodeId
  let h2 := fpMixRect h1 cl.borderRect
  fpMixRect h2 cl.contentRect

def empty : LayoutResult := { layouts := #[], layoutMap := {} }

/-- Find layout by node ID. O(1) HashMap lookup. -/
def get (r : LayoutResult) (nodeId : Nat) : Option ComputedLayout :=
  r.layoutMap.get? nodeId

/-- Get layout, panicking if not found. -/
def get! (r : LayoutResult) (nodeId : Nat) : ComputedLayout :=
  match r.get nodeId with
  | some cl => cl
  | none => panic! s!"Layout not found for node {nodeId}"

/-- Add a computed layout. Maintains both array and HashMap. -/
def add (r : LayoutResult) (cl : ComputedLayout) : LayoutResult :=
  let layouts := r.layouts.push cl
  let layoutMap := r.layoutMap.insert cl.nodeId cl
  let fingerprint := fpMixLayout r.fingerprint cl
  match layouts, layoutMap, fingerprint with
  | layouts, layoutMap, fingerprint =>
    { layouts := layouts
      layoutMap := layoutMap
      fingerprint := fingerprint }

/-- Merge with another result. Maintains both array and HashMap. -/
def merge (r1 r2 : LayoutResult) : LayoutResult :=
  r2.layouts.foldl (init := r1) fun acc cl => acc.add cl

/-- Get all rects for rendering. -/
def allRects (r : LayoutResult) : Array LayoutRect :=
  r.layouts.map (·.borderRect)

/-- Map over all layouts. Maintains both array and HashMap. -/
def map (r : LayoutResult) (f : ComputedLayout → ComputedLayout) : LayoutResult :=
  r.layouts.foldl (init := LayoutResult.empty) fun acc cl => acc.add (f cl)

/-- Translate all layouts by an offset. -/
def translate (r : LayoutResult) (dx dy : Length) : LayoutResult :=
  r.map fun cl =>
    { cl with
      borderRect := cl.borderRect.translate dx dy
      contentRect := cl.contentRect.translate dx dy }

/-- Number of layouts. -/
def size (r : LayoutResult) : Nat := r.layouts.size

end LayoutResult

end Trellis
