/-
  CoreTests - Tests for Entity.Core types.
-/
import Entity
import Crucible

namespace CoreTests

open Crucible Entity

testSuite "CoreTests"

test "EntityId null is null" := do
  (EntityId.null.isNull) ≡ true

test "EntityId new is not null" := do
  let eid := EntityId.new 1 1
  eid.isNull ≡ false

test "EntityId equality" := do
  let e1 := EntityId.new 1 1
  let e2 := EntityId.new 1 1
  let e3 := EntityId.new 1 2
  (e1 == e2) ≡ true
  (e1 == e3) ≡ false

test "ComponentId from type name" := do
  let c1 := ComponentId.ofTypeName "Position"
  let c2 := ComponentId.ofTypeName "Position"
  let c3 := ComponentId.ofTypeName "Velocity"
  (c1 == c2) ≡ true
  (c1 == c3) ≡ false

test "ArchetypeId empty" := do
  let a := ArchetypeId.empty
  a.isEmpty ≡ true
  a.size ≡ 0

test "ArchetypeId from components" := do
  let c1 := ComponentId.ofTypeName "Position"
  let c2 := ComponentId.ofTypeName "Velocity"
  let a := ArchetypeId.ofComponents #[c1, c2]
  a.size ≡ 2
  a.hasComponent c1 ≡ true
  a.hasComponent c2 ≡ true

test "ArchetypeId add component" := do
  let c1 := ComponentId.ofTypeName "Position"
  let c2 := ComponentId.ofTypeName "Velocity"
  let a1 := ArchetypeId.ofComponents #[c1]
  let a2 := a1.addComponent c2
  a1.size ≡ 1
  a2.size ≡ 2
  a2.hasComponent c2 ≡ true

test "ArchetypeId remove component" := do
  let c1 := ComponentId.ofTypeName "Position"
  let c2 := ComponentId.ofTypeName "Velocity"
  let a1 := ArchetypeId.ofComponents #[c1, c2]
  let a2 := a1.removeComponent c1
  a2.size ≡ 1
  a2.hasComponent c1 ≡ false
  a2.hasComponent c2 ≡ true

test "ArchetypeId deduplication" := do
  let c1 := ComponentId.ofTypeName "Position"
  let a := ArchetypeId.ofComponents #[c1, c1, c1]
  a.size ≡ 1

end CoreTests
