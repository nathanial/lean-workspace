/-
  World - The central container for all ECS data.

  The World owns entity metadata and archetype registry.
  Component data is stored in typed ComponentStores managed externally.
-/
import Entity.Core
import Entity.Storage
import Entity.World.EntityMeta

namespace Entity

/-- The World is the central container for ECS entity management.
    It tracks entity lifecycles and archetype membership.

    Component storage is handled via the `Components` typeclass,
    allowing type-safe access to component stores. -/
structure World where
  /-- Entity metadata indexed by entity index -/
  entities : Array EntityMeta
  /-- Free list of reusable entity indices -/
  freeList : Array UInt32
  /-- Next entity index to allocate -/
  nextIndex : UInt32
  /-- Archetype registry -/
  archetypes : ArchetypeRegistry
  deriving Inhabited

namespace World

/-- Create an empty world -/
def empty : World :=
  { entities := #[]
  , freeList := #[]
  , nextIndex := 1  -- Reserve 0 for null entity
  , archetypes := ArchetypeRegistry.empty }

/-- Check if an entity is alive -/
def isAlive (w : World) (eid : EntityId) : Bool :=
  if eid.isNull then false
  else match w.entities[eid.index.toNat]? with
    | some em => em.alive && em.generation == eid.generation
    | none => false

/-- Get entity metadata (only if alive) -/
def getMeta (w : World) (eid : EntityId) : Option EntityMeta :=
  if w.isAlive eid then w.entities[eid.index.toNat]? else none

/-- Get entity's archetype ID -/
def getArchetype (w : World) (eid : EntityId) : Option ArchetypeId :=
  w.getMeta eid |>.map (·.archetype)

/-- Allocate a new entity ID (internal) -/
private def allocateId (w : World) : World × EntityId :=
  if w.freeList.size > 0 then
    -- Reuse a freed index
    let idx := w.freeList.back!
    let oldMeta := w.entities[idx.toNat]?.getD EntityMeta.dead
    let newGen := oldMeta.generation + 1
    let eid := EntityId.new idx newGen
    let w' := { w with freeList := w.freeList.pop }
    (w', eid)
  else
    -- Allocate new index
    let idx := w.nextIndex
    let eid := EntityId.new idx 1
    let w' := { w with nextIndex := w.nextIndex + 1 }
    (w', eid)

/-- Spawn a new entity with no components -/
def spawn (w : World) : World × EntityId :=
  let (w', eid) := w.allocateId
  let newMeta := EntityMeta.create eid.generation ArchetypeId.empty

  -- Ensure entities array is large enough
  let entities :=
    if eid.index.toNat >= w'.entities.size then
      let padding := eid.index.toNat - w'.entities.size + 1
      let padArr : Array EntityMeta := (List.replicate padding EntityMeta.dead).toArray
      w'.entities ++ padArr
    else
      w'.entities

  let entities' := entities.set! eid.index.toNat newMeta

  -- Add to empty archetype
  let (archetypes', _) := w'.archetypes.getOrCreate ArchetypeId.empty
  let arch := (archetypes'.get ArchetypeId.empty).getD (Archetype.empty .empty)
  let arch' := arch.addEntity eid
  let archetypes'' := archetypes'.update arch'

  ({ w' with entities := entities', archetypes := archetypes'' }, eid)

/-- Despawn an entity -/
def despawn (w : World) (eid : EntityId) : World :=
  if !w.isAlive eid then w
  else
    match w.entities[eid.index.toNat]? with
    | some em =>
      -- Remove from current archetype
      let archetypes' := match w.archetypes.get em.archetype with
        | some arch =>
          let arch' := arch.removeEntity eid
          w.archetypes.update arch'
        | none => w.archetypes

      -- Mark as dead
      let em' := em.kill
      let entities' := w.entities.set! eid.index.toNat em'

      -- Add to free list
      { w with
        entities := entities'
        freeList := w.freeList.push eid.index
        archetypes := archetypes' }
    | none => w

/-- Update entity's archetype (used when components change) -/
def setEntityArchetype (w : World) (eid : EntityId) (newArch : ArchetypeId) : World :=
  match w.entities[eid.index.toNat]? with
  | some em =>
    if !em.alive || em.generation != eid.generation then w
    else
      let oldArch := em.archetype
      if oldArch == newArch then w
      else
        -- Remove from old archetype
        let archetypes' := match w.archetypes.get oldArch with
          | some arch => w.archetypes.update (arch.removeEntity eid)
          | none => w.archetypes

        -- Add to new archetype (create if needed)
        let (archetypes'', _) := archetypes'.getOrCreate newArch
        let archetypes''' := match archetypes''.get newArch with
          | some arch => archetypes''.update (arch.addEntity eid)
          | none => archetypes''

        -- Update entity metadata
        let em' := em.setArchetype newArch
        let entities' := w.entities.set! eid.index.toNat em'

        { w with entities := entities', archetypes := archetypes''' }
  | none => w

/-- Get all entities in archetypes matching the query -/
def queryEntities (w : World) (required : Array ComponentId) (excluded : Array ComponentId := #[]) : Array EntityId :=
  let matchingArchs := w.archetypes.matching required excluded
  matchingArchs.foldl (init := #[]) fun acc arch =>
    arch.entityIndices.foldl (init := acc) fun acc' idx =>
      match w.entities[idx.toNat]? with
      | some em =>
        if em.alive then
          acc'.push (EntityId.new idx em.generation)
        else acc'
      | none => acc'

/-- Number of alive entities -/
def entityCount (w : World) : Nat :=
  w.entities.foldl (init := 0) fun count em =>
    if em.alive then count + 1 else count

end World

end Entity
