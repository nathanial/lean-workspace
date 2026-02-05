/-
  EntityMeta - Metadata for each entity slot in the world.
-/
import Entity.Core

namespace Entity

/-- Metadata for a single entity slot.
    Tracks whether the slot is alive and which archetype the entity belongs to. -/
structure EntityMeta where
  /-- Current generation (for stale reference detection) -/
  generation : UInt32
  /-- Archetype this entity belongs to -/
  archetype : ArchetypeId
  /-- Whether this slot is alive -/
  alive : Bool
  deriving Repr, Inhabited

namespace EntityMeta

/-- Default dead entity metadata -/
def dead : EntityMeta :=
  { generation := 0
  , archetype := ArchetypeId.empty
  , alive := false }

/-- Create alive metadata for a new entity -/
def create (generation : UInt32) (archetype : ArchetypeId := .empty) : EntityMeta :=
  { generation, archetype, alive := true }

/-- Mark as dead, incrementing generation -/
def kill (self : EntityMeta) : EntityMeta :=
  { self with alive := false }

/-- Update the archetype -/
def setArchetype (self : EntityMeta) (arch : ArchetypeId) : EntityMeta :=
  { self with archetype := arch }

end EntityMeta

end Entity
