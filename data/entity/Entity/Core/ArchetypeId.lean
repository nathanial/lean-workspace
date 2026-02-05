/-
  ArchetypeId - Identifier for component combinations (archetypes).

  Uses a sorted array of ComponentIds for canonical representation.
  Provides efficient subset/superset checks for query matching.
-/
import Entity.Core.ComponentId

namespace Entity

/-- Identifier for an archetype - a specific combination of component types.
    Represented as a sorted array of ComponentIds for canonical comparison. -/
structure ArchetypeId where
  /-- Sorted array of component IDs in this archetype -/
  components : Array ComponentId
  deriving Repr, Inhabited

namespace ArchetypeId

/-- Empty archetype (no components) -/
def empty : ArchetypeId := { components := #[] }

/-- Create from an array of component IDs (will be sorted) -/
def ofComponents (ids : Array ComponentId) : ArchetypeId :=
  let sorted := ids.qsort (fun a b => a.id < b.id)
  -- Remove duplicates
  let deduped := sorted.foldl (init := #[]) fun acc cid =>
    if acc.isEmpty || acc.back! != cid then acc.push cid else acc
  { components := deduped }

/-- Create from a list of component IDs -/
def ofList (ids : List ComponentId) : ArchetypeId :=
  ofComponents ids.toArray

/-- Number of components in this archetype -/
def size (aid : ArchetypeId) : Nat := aid.components.size

/-- Check if this archetype is empty -/
def isEmpty (aid : ArchetypeId) : Bool := aid.components.isEmpty

/-- Check if this archetype has a specific component -/
def hasComponent (aid : ArchetypeId) (cid : ComponentId) : Bool :=
  -- Binary search since components are sorted
  aid.components.binSearch cid (fun a b => a.id < b.id) |>.isSome

/-- Check if this archetype has all components in another archetype -/
def hasAll (aid : ArchetypeId) (other : ArchetypeId) : Bool :=
  other.components.all aid.hasComponent

/-- Check if this archetype has none of the components in another archetype -/
def hasNone (aid : ArchetypeId) (other : ArchetypeId) : Bool :=
  other.components.all (!aid.hasComponent ·)

/-- Add a component to the archetype, returning a new archetype -/
def addComponent (aid : ArchetypeId) (cid : ComponentId) : ArchetypeId :=
  if aid.hasComponent cid then aid
  else ofComponents (aid.components.push cid)

/-- Remove a component from the archetype, returning a new archetype -/
def removeComponent (aid : ArchetypeId) (cid : ComponentId) : ArchetypeId :=
  { components := aid.components.filter (· != cid) }

/-- Get the index of a component in the archetype, if present -/
def indexOf (aid : ArchetypeId) (cid : ComponentId) : Option Nat :=
  aid.components.findIdx? (· == cid)

instance : BEq ArchetypeId where
  beq a b := a.components == b.components

instance : Hashable ArchetypeId where
  hash a := a.components.foldl (init := 0) fun h c => mixHash h (hash c)

instance : ToString ArchetypeId where
  toString a :=
    let ids := a.components.map (·.id) |>.toList
    s!"Archetype{ids}"

end ArchetypeId

end Entity
