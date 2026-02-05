/-
  EntityId - Unique identifier for entities in the ECS world.

  Uses a generation counter to detect stale references after entity reuse.
-/
namespace Entity

/-- Unique identifier for an entity in the world.
    Combines an index with a generation counter for safe reuse. -/
structure EntityId where
  /-- Index into the entity storage -/
  index : UInt32
  /-- Generation counter to detect stale references -/
  generation : UInt32
  deriving Repr, BEq, Hashable, Inhabited

namespace EntityId

instance : Ord EntityId where
  compare a b :=
    match compare a.index b.index with
    | .eq => compare a.generation b.generation
    | o => o

instance : ToString EntityId where
  toString e := s!"Entity({e.index}v{e.generation})"

/-- The null/invalid entity -/
def null : EntityId := { index := 0, generation := 0 }

/-- Check if entity is null -/
def isNull (e : EntityId) : Bool := e == null

/-- Create a new entity ID -/
def new (index : UInt32) (generation : UInt32 := 1) : EntityId :=
  { index, generation }

end EntityId

end Entity
