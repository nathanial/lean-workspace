/-
  Archetype - Storage for entities with the same component set.

  In this simplified design, archetypes track which entities belong to them,
  while actual component data is stored in per-type ComponentStores.
-/
import Entity.Core
import Std.Data.HashMap
import Std.Data.HashSet

namespace Entity

/-- An archetype represents a set of entities that share the same component types.
    This is a lightweight structure that tracks membership; actual component
    data is stored in separate typed ComponentStores. -/
structure Archetype where
  /-- The archetype's unique identifier (component set) -/
  id : ArchetypeId
  /-- Entity indices belonging to this archetype -/
  entities : Std.HashSet UInt32
  deriving Inhabited

namespace Archetype

/-- Create an empty archetype -/
def empty (id : ArchetypeId) : Archetype :=
  { id, entities := {} }

/-- Add an entity to this archetype -/
def addEntity (arch : Archetype) (eid : EntityId) : Archetype :=
  { arch with entities := arch.entities.insert eid.index }

/-- Remove an entity from this archetype -/
def removeEntity (arch : Archetype) (eid : EntityId) : Archetype :=
  { arch with entities := arch.entities.erase eid.index }

/-- Check if an entity belongs to this archetype -/
def hasEntity (arch : Archetype) (eid : EntityId) : Bool :=
  arch.entities.contains eid.index

/-- Number of entities in this archetype -/
def size (arch : Archetype) : Nat :=
  arch.entities.size

/-- Check if archetype is empty -/
def isEmpty (arch : Archetype) : Bool :=
  arch.entities.isEmpty

/-- Get all entity indices in this archetype -/
def entityIndices (arch : Archetype) : Array UInt32 :=
  arch.entities.toArray

end Archetype

/-- Registry of all archetypes in the world -/
structure ArchetypeRegistry where
  /-- All archetypes by their ID -/
  archetypes : Std.HashMap ArchetypeId Archetype
  deriving Inhabited

namespace ArchetypeRegistry

/-- Create an empty registry -/
def empty : ArchetypeRegistry := { archetypes := {} }

/-- Get or create an archetype -/
def getOrCreate (reg : ArchetypeRegistry) (id : ArchetypeId) : ArchetypeRegistry × Archetype :=
  match reg.archetypes[id]? with
  | some arch => (reg, arch)
  | none =>
    let arch := Archetype.empty id
    ({ archetypes := reg.archetypes.insert id arch }, arch)

/-- Update an archetype in the registry -/
def update (reg : ArchetypeRegistry) (arch : Archetype) : ArchetypeRegistry :=
  { archetypes := reg.archetypes.insert arch.id arch }

/-- Get an archetype by ID -/
def get (reg : ArchetypeRegistry) (id : ArchetypeId) : Option Archetype :=
  reg.archetypes[id]?

/-- Get all archetypes that have a specific component -/
def withComponent (reg : ArchetypeRegistry) (cid : ComponentId) : Array Archetype :=
  reg.archetypes.toArray.filterMap fun (id, arch) =>
    if id.hasComponent cid then some arch else none

/-- Get all archetypes matching a query (has all required, has none of excluded) -/
def matching (reg : ArchetypeRegistry) (required : Array ComponentId) (excluded : Array ComponentId) : Array Archetype :=
  reg.archetypes.toArray.filterMap fun (id, arch) =>
    let hasAll := required.all id.hasComponent
    let hasNone := excluded.all (!id.hasComponent ·)
    if hasAll && hasNone then some arch else none

end ArchetypeRegistry

end Entity
