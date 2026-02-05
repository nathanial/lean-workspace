/-
  ComponentStore - Type-safe component storage using HashMaps.

  Each component type has its own dedicated store, providing type safety
  while allowing efficient per-entity lookups.
-/
import Entity.Core
import Std.Data.HashMap

namespace Entity

/-- A typed store for components of a single type.
    Maps EntityId to component values. -/
structure ComponentStore (C : Type) where
  /-- Component data indexed by entity -/
  data : Std.HashMap UInt32 C
  deriving Inhabited

namespace ComponentStore

/-- Create an empty component store -/
def empty : ComponentStore C := { data := {} }

/-- Get a component for an entity -/
def get (store : ComponentStore C) (eid : EntityId) : Option C :=
  store.data[eid.index]?

/-- Set a component for an entity -/
def set (store : ComponentStore C) (eid : EntityId) (val : C) : ComponentStore C :=
  { data := store.data.insert eid.index val }

/-- Remove a component from an entity -/
def remove (store : ComponentStore C) (eid : EntityId) : ComponentStore C :=
  { data := store.data.erase eid.index }

/-- Check if an entity has this component -/
def contains (store : ComponentStore C) (eid : EntityId) : Bool :=
  store.data.contains eid.index

/-- Get all entity indices that have this component -/
def entities (store : ComponentStore C) : Array UInt32 :=
  store.data.toArray.map (·.1)

/-- Number of components in the store -/
def size (store : ComponentStore C) : Nat :=
  store.data.size

/-- Iterate over all (entity index, component) pairs -/
def toArray (store : ComponentStore C) : Array (UInt32 × C) :=
  store.data.toArray

end ComponentStore

end Entity
