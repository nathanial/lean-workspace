/-
  Query.Spec - Query specification types.
-/
import Entity.Core

namespace Entity

/-- Access mode for a component in a query -/
inductive Access where
  | read   -- Read-only access
  | write  -- Read-write access
  deriving Repr, BEq, Inhabited

/-- Filter type for queries -/
inductive Filter where
  | with_    : ComponentId → Filter  -- Must have component
  | without  : ComponentId → Filter  -- Must not have component
  deriving Repr, BEq, Inhabited

/-- Query specification describing which components to fetch and filter. -/
structure QuerySpec where
  /-- Components to fetch (required) -/
  fetch : Array ComponentId
  /-- Additional filters -/
  filters : Array Filter := #[]
  deriving Repr, Inhabited

namespace QuerySpec

/-- Create an empty query spec -/
def empty : QuerySpec := { fetch := #[], filters := #[] }

/-- Add a component to fetch -/
def addFetch (q : QuerySpec) (cid : ComponentId) : QuerySpec :=
  { q with fetch := q.fetch.push cid }

/-- Add a With filter -/
def addWith (q : QuerySpec) (cid : ComponentId) : QuerySpec :=
  { q with filters := q.filters.push (.with_ cid) }

/-- Add a Without filter -/
def addWithout (q : QuerySpec) (cid : ComponentId) : QuerySpec :=
  { q with filters := q.filters.push (.without cid) }

/-- Get all required component IDs (fetch + with filters) -/
def requiredComponents (q : QuerySpec) : Array ComponentId :=
  let withComps := q.filters.filterMap fun f =>
    match f with
    | .with_ cid => some cid
    | .without _ => none
  q.fetch ++ withComps

/-- Get all excluded component IDs (without filters) -/
def excludedComponents (q : QuerySpec) : Array ComponentId :=
  q.filters.filterMap fun f =>
    match f with
    | .without cid => some cid
    | .with_ _ => none

/-- Check if an archetype matches this query -/
def matchesArchetype (q : QuerySpec) (archId : ArchetypeId) : Bool :=
  let required := q.requiredComponents
  let excluded := q.excludedComponents
  required.all archId.hasComponent && excluded.all (!archId.hasComponent ·)

end QuerySpec

end Entity
