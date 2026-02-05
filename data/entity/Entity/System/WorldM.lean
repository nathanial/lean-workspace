/-
  WorldM - Monadic interface for ECS operations.

  WorldM is a StateT monad over World, providing convenient methods
  for entity and component manipulation.
-/
import Entity.Core
import Entity.Storage
import Entity.World
import Entity.Query

namespace Entity

/-- The World monad for ECS operations.
    Provides mutable access to the world via StateT. -/
abbrev WorldM := StateT World IO

namespace WorldM

/-- Get the current world state -/
def getWorld : WorldM World := get

/-- Set the world state -/
def setWorld (w : World) : WorldM Unit := set w

/-- Modify the world state -/
def modifyWorld (f : World → World) : WorldM Unit := modify f

/-- Spawn a new entity with no components -/
def spawn : WorldM EntityId := do
  let w ← get
  let (w', eid) := w.spawn
  set w'
  pure eid

/-- Despawn an entity -/
def despawn (eid : EntityId) : WorldM Unit :=
  modify (·.despawn eid)

/-- Check if an entity is alive -/
def isAlive (eid : EntityId) : WorldM Bool := do
  let w ← get
  pure (w.isAlive eid)

/-- Get an entity's archetype -/
def getArchetype (eid : EntityId) : WorldM (Option ArchetypeId) := do
  let w ← get
  pure (w.getArchetype eid)

/-- Update an entity's archetype (used after component changes) -/
def setArchetype (eid : EntityId) (arch : ArchetypeId) : WorldM Unit :=
  modify (·.setEntityArchetype eid arch)

/-- Query for entities matching the given requirements -/
def queryEntities (required : Array ComponentId) (excluded : Array ComponentId := #[]) : WorldM (Array EntityId) := do
  let w ← get
  pure (w.queryEntities required excluded)

/-- Get entities matching a query -/
def queryMatching (q : Query Cs) : WorldM (Array EntityId) := do
  let w ← get
  pure (q.matchingEntities w)

/-- Iterate over entities matching a query -/
def forEach (q : Query Cs) (f : EntityId → WorldM Unit) : WorldM Unit := do
  let entities ← queryMatching q
  for eid in entities do
    f eid

/-- Get entity count -/
def entityCount : WorldM Nat := do
  let w ← get
  pure w.entityCount

/-- Run a WorldM computation with an initial world -/
def runWith (m : WorldM α) (w : World := World.empty) : IO (α × World) :=
  StateT.run m w

/-- Run a WorldM computation, returning only the result -/
def run' (m : WorldM α) (w : World := World.empty) : IO α :=
  Prod.fst <$> StateT.run m w

/-- Run a WorldM computation, returning only the final world -/
def exec (m : WorldM α) (w : World := World.empty) : IO World :=
  Prod.snd <$> StateT.run m w

end WorldM

end Entity
