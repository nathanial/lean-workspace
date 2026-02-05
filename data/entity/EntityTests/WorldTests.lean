/-
  WorldTests - Tests for Entity.World operations.
-/
import Entity
import Crucible

namespace WorldTests

open Crucible Entity

testSuite "WorldTests"

test "World empty" := do
  let w := World.empty
  w.entityCount ≡ 0

test "World spawn entity" := do
  let w := World.empty
  let (w', eid) := w.spawn
  w'.isAlive eid ≡ true
  w'.entityCount ≡ 1

test "World spawn multiple entities" := do
  let w := World.empty
  let (w1, e1) := w.spawn
  let (w2, e2) := w1.spawn
  let (w3, e3) := w2.spawn
  w3.entityCount ≡ 3
  w3.isAlive e1 ≡ true
  w3.isAlive e2 ≡ true
  w3.isAlive e3 ≡ true
  -- Different entities
  (e1 == e2) ≡ false
  (e2 == e3) ≡ false

test "World despawn entity" := do
  let w := World.empty
  let (w1, eid) := w.spawn
  let w2 := w1.despawn eid
  w2.isAlive eid ≡ false
  w2.entityCount ≡ 0

test "World entity reuse" := do
  let w := World.empty
  let (w1, e1) := w.spawn
  let w2 := w1.despawn e1
  let (_, e2) := w2.spawn
  -- Same index, different generation
  e1.index ≡ e2.index
  (e1.generation == e2.generation) ≡ false

test "World stale entity reference" := do
  let w := World.empty
  let (w1, e1) := w.spawn
  let w2 := w1.despawn e1
  let (w3, _) := w2.spawn
  -- Old reference is no longer valid
  w3.isAlive e1 ≡ false

test "World set archetype" := do
  let c1 := ComponentId.ofTypeName "Position"
  let arch := ArchetypeId.ofComponents #[c1]
  let w := World.empty
  let (w1, eid) := w.spawn
  let w2 := w1.setEntityArchetype eid arch
  w2.getArchetype eid ≡ some arch

test "World query entities by component" := do
  let c1 := ComponentId.ofTypeName "Position"
  let c2 := ComponentId.ofTypeName "Velocity"
  let arch1 := ArchetypeId.ofComponents #[c1]
  let arch2 := ArchetypeId.ofComponents #[c1, c2]

  let w := World.empty
  let (w1, e1) := w.spawn
  let w2 := w1.setEntityArchetype e1 arch1
  let (w3, e2) := w2.spawn
  let w4 := w3.setEntityArchetype e2 arch2

  -- Query for Position: should find both
  let withPos := w4.queryEntities #[c1]
  withPos.size ≡ 2

  -- Query for Velocity: should find only e2
  let withVel := w4.queryEntities #[c2]
  withVel.size ≡ 1

end WorldTests
