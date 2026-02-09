/-
  Trellis Layout Node
  Unified layout tree structure supporting flex and grid containers.
-/
import Trellis.Types
import Trellis.Flex
import Trellis.Grid
import Std.Data.HashMap

namespace Trellis

/-- The type of container a node represents. -/
inductive ContainerKind where
  | flex (props : FlexContainer)   -- Flexbox container
  | grid (props : GridContainer)   -- Grid container
  | none                           -- Not a container (leaf node)
deriving Repr, BEq

namespace ContainerKind

def isFlex : ContainerKind → Bool
  | .flex _ => true
  | _ => false

def isGrid : ContainerKind → Bool
  | .grid _ => true
  | _ => false

def isNone : ContainerKind → Bool
  | .none => true
  | _ => false

end ContainerKind

/-- Item properties based on parent container type. -/
inductive ItemKind where
  | flexChild (props : FlexItem)   -- Child of a flex container
  | gridChild (props : GridItem)   -- Child of a grid container
  | none                           -- No special item properties
deriving Repr, BEq

namespace ItemKind

def isFlex : ItemKind → Bool
  | .flexChild _ => true
  | _ => false

def isGrid : ItemKind → Bool
  | .gridChild _ => true
  | _ => false

/-- Get flex item properties if this is a flex child. -/
def flexItem? : ItemKind → Option FlexItem
  | .flexChild props => some props
  | _ => Option.none

/-- Get grid item properties if this is a grid child. -/
def gridItem? : ItemKind → Option GridItem
  | .gridChild props => some props
  | _ => Option.none

end ItemKind

/-- Intrinsic content size for leaf nodes. -/
structure ContentSize where
  width : Length
  height : Length
  /-- Distance from top to first text baseline. If not specified, defaults to height. -/
  baseline : Option Length := none
deriving Repr, BEq, Inhabited

namespace ContentSize

def zero : ContentSize := ⟨0, 0, none⟩

def mk' (w h : Length) : ContentSize := ⟨w, h, none⟩

/-- Create content size with explicit baseline. -/
def withBaseline (w h baseline : Length) : ContentSize := ⟨w, h, some baseline⟩

/-- Get the baseline, defaulting to height if not specified. -/
def getBaseline (cs : ContentSize) : Length :=
  cs.baseline.getD cs.height

end ContentSize

/-- A node in the layout tree. -/
inductive LayoutNode where
  | mk (id : Nat)
       (box : BoxConstraints)
       (container : ContainerKind)
       (item : ItemKind)
       (content : Option ContentSize)
       (children : Array LayoutNode)
deriving Repr

instance : Inhabited LayoutNode :=
  ⟨LayoutNode.mk 0 {} .none .none Option.none #[]⟩

namespace LayoutNode

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

private def localId : LayoutNode → Nat
  | .mk id .. => id

private def localChildren : LayoutNode → Array LayoutNode
  | .mk _ _ _ _ _ children => children

private def localLayoutSignature (node : LayoutNode) (childSigs : Array UInt64) : UInt64 :=
  match node with
  | .mk _ box container item content _ =>
    let sig0 := sigTag 0x4c41594f5554 -- "LAYOUT"
    let sig1 := sigCombine sig0 (sigHashRepr box)
    let sig2 := sigCombine sig1 (sigHashRepr container)
    let sig3 := sigCombine sig2 (sigHashRepr item)
    let sig4 := sigCombine sig3 (sigHashRepr content)
    let sig5 := sigCombine sig4 (UInt64.ofNat childSigs.size)
    childSigs.foldl sigCombine sig5

private inductive SignatureWorkItem where
  | visit (node : LayoutNode)
  | combine (node : LayoutNode)
deriving Inhabited

/-- Get the unique identifier of this node. -/
def id : LayoutNode → Nat
  | mk id .. => id

/-- Get box constraints. -/
def box : LayoutNode → BoxConstraints
  | mk _ box .. => box

/-- Get container kind. -/
def container : LayoutNode → ContainerKind
  | mk _ _ container .. => container

/-- Get item properties. -/
def item : LayoutNode → ItemKind
  | mk _ _ _ item .. => item

/-- Get content size for leaf nodes. -/
def content : LayoutNode → Option ContentSize
  | mk _ _ _ _ content _ => content

/-- Get children array. -/
def children : LayoutNode → Array LayoutNode
  | mk _ _ _ _ _ children => children

/-- Check if this is a leaf node (no children). -/
def isLeaf (n : LayoutNode) : Bool := n.children.isEmpty

/-- Check if this is a flex container. -/
def isFlex (n : LayoutNode) : Bool := n.container.isFlex

/-- Check if this is a grid container. -/
def isGrid (n : LayoutNode) : Bool := n.container.isGrid

/-- Get flex container properties if this is a flex container. -/
def flexContainer? : LayoutNode → Option FlexContainer
  | mk _ _ (.flex props) .. => some props
  | _ => none

/-- Get grid container properties if this is a grid container. -/
def gridContainer? : LayoutNode → Option GridContainer
  | mk _ _ (.grid props) .. => some props
  | _ => none

/-- Get flex item properties if this is a flex child. -/
def flexItem? (n : LayoutNode) : Option FlexItem := n.item.flexItem?

/-- Get grid item properties if this is a grid child. -/
def gridItem? (n : LayoutNode) : Option GridItem := n.item.gridItem?

/-! ## Builder Functions -/

/-- Create a leaf node with intrinsic content size. -/
def leaf (id : Nat) (content : ContentSize)
    (box : BoxConstraints := {})
    (item : ItemKind := .none) : LayoutNode :=
  mk id box .none item (some content) #[]

/-- Create a leaf node with width and height. -/
def leaf' (id : Nat) (width height : Length)
    (box : BoxConstraints := {})
    (item : ItemKind := .none) : LayoutNode :=
  leaf id (ContentSize.mk' width height) box item

/-- Create a flex container node. -/
def flexBox (id : Nat) (props : FlexContainer)
    (children : Array LayoutNode)
    (box : BoxConstraints := {})
    (item : ItemKind := .none) : LayoutNode :=
  mk id box (.flex props) item none children

/-- Create a flex row container. -/
def row (id : Nat) (children : Array LayoutNode)
    (gap : Length := 0)
    (box : BoxConstraints := {})
    (item : ItemKind := .none) : LayoutNode :=
  flexBox id (FlexContainer.row gap) children box item

/-- Create a flex column container. -/
def column (id : Nat) (children : Array LayoutNode)
    (gap : Length := 0)
    (box : BoxConstraints := {})
    (item : ItemKind := .none) : LayoutNode :=
  flexBox id (FlexContainer.column gap) children box item

/-- Create a grid container node. -/
def gridBox (id : Nat) (props : GridContainer)
    (children : Array LayoutNode)
    (box : BoxConstraints := {})
    (item : ItemKind := .none) : LayoutNode :=
  mk id box (.grid props) item none children

/-- Create a simple grid with n columns. -/
def grid (id : Nat) (columns : Nat) (children : Array LayoutNode)
    (gap : Length := 0)
    (box : BoxConstraints := {})
    (item : ItemKind := .none) : LayoutNode :=
  gridBox id (GridContainer.columns columns gap) children box item

/-! ## Modification Functions -/

/-- Set box constraints on a node. -/
def withBox (n : LayoutNode) (box : BoxConstraints) : LayoutNode :=
  match n with
  | mk id _ container item content children =>
    mk id box container item content children

/-- Set item kind on a node. -/
def withItem (n : LayoutNode) (item : ItemKind) : LayoutNode :=
  match n with
  | mk id box container _ content children =>
    mk id box container item content children

/-- Add a child to a container node. -/
def addChild (n : LayoutNode) (child : LayoutNode) : LayoutNode :=
  match n with
  | mk id box container item content children =>
    mk id box container item content (children.push child)

/-- Set children of a container node. -/
def withChildren (n : LayoutNode) (children : Array LayoutNode) : LayoutNode :=
  match n with
  | mk id box container item content _ =>
    mk id box container item content children

/-- Map a function over children. -/
def mapChildren (n : LayoutNode) (f : LayoutNode → LayoutNode) : LayoutNode :=
  n.withChildren (n.children.map f)

/-- Stable signature for the subtree based only on layout-affecting fields. -/
def layoutSignature (root : LayoutNode) : UInt64 := Id.run do
  let mut signatures : Std.HashMap Nat UInt64 := {}
  let mut stack : Array SignatureWorkItem := #[.visit root]

  while !stack.isEmpty do
    let item := stack.back!
    stack := stack.pop
    match item with
    | .visit node =>
      if signatures.contains (localId node) then
        continue
      if (localChildren node).isEmpty then
        signatures := signatures.insert (localId node) (localLayoutSignature node #[])
      else
        stack := stack.push (.combine node)
        for child in (localChildren node).reverse do
          stack := stack.push (.visit child)
    | .combine node =>
      let childSigs := (localChildren node).map fun child =>
        signatures.getD (localId child) 0
      signatures := signatures.insert (localId node) (localLayoutSignature node childSigs)

  signatures.getD (localId root) 0

/-- Count total nodes in tree using iterative DFS to stay stack-safe on deep trees. -/
def nodeCount (n : LayoutNode) : Nat := Id.run do
  let mut count := 0
  let mut stack : Array LayoutNode := #[n]
  while !stack.isEmpty do
    let node := stack.back!
    stack := stack.pop
    count := count + 1
    for child in node.children.reverse do
      stack := stack.push child
  return count

/-- Get all node IDs in pre-order using iterative DFS to stay stack-safe on deep trees. -/
def allIds (n : LayoutNode) : Array Nat := Id.run do
  let mut ids : Array Nat := #[]
  let mut stack : Array LayoutNode := #[n]
  while !stack.isEmpty do
    let node := stack.back!
    stack := stack.pop
    ids := ids.push node.id
    for child in node.children.reverse do
      stack := stack.push child
  return ids

end LayoutNode

end Trellis
