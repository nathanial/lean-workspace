/-
  QueryTests - Tests for Entity.Query.
-/
import Entity
import Crucible

namespace QueryTests

open Crucible Entity

-- Test component types
structure TestPosition where
  x : Float := 0
  y : Float := 0

structure TestVelocity where
  dx : Float := 0
  dy : Float := 0
structure TestPlayer
structure TestEnemy

instance : Component TestPosition where
  componentId := .ofTypeName "TestPosition"
  componentName := "TestPosition"

instance : Component TestVelocity where
  componentId := .ofTypeName "TestVelocity"
  componentName := "TestVelocity"

instance : Component TestPlayer where
  componentId := .ofTypeName "TestPlayer"
  componentName := "TestPlayer"

instance : Component TestEnemy where
  componentId := .ofTypeName "TestEnemy"
  componentName := "TestEnemy"

testSuite "QueryTests"

test "Query one component" := do
  let q : Query [TestPosition] := Query.one
  q.spec.fetch.size ≡ 1

test "Query multiple components" := do
  let q : Query [TestVelocity, TestPosition] :=
    Query.one (C := TestPosition) |>.and (C := TestVelocity)
  q.spec.fetch.size ≡ 2

test "Query with filter" := do
  let q : Query [TestPosition] :=
    Query.one (C := TestPosition) |>.with_ (C := TestPlayer)
  q.spec.filters.size ≡ 1

test "Query without filter" := do
  let q : Query [TestPosition] :=
    Query.one (C := TestPosition) |>.without (C := TestEnemy)
  q.spec.filters.size ≡ 1

test "QuerySpec matches archetype" := do
  let posId := Component.componentId (C := TestPosition)
  let velId := Component.componentId (C := TestVelocity)
  let arch := ArchetypeId.ofComponents #[posId, velId]

  -- Query for Position should match
  let q1 : Query [TestPosition] := Query.one
  q1.spec.matchesArchetype arch ≡ true

  -- Query for Position+Velocity should match
  let q2 : Query [TestVelocity, TestPosition] :=
    Query.one (C := TestPosition) |>.and (C := TestVelocity)
  q2.spec.matchesArchetype arch ≡ true

test "QuerySpec excludes non-matching" := do
  let posId := Component.componentId (C := TestPosition)
  let enemyId := Component.componentId (C := TestEnemy)
  let arch := ArchetypeId.ofComponents #[posId]

  -- Query for Velocity should not match (not present)
  let q1 : Query [TestVelocity] := Query.one
  q1.spec.matchesArchetype arch ≡ false

  -- Query without Enemy should match (Enemy not present)
  let q2 : Query [TestPosition] :=
    Query.one (C := TestPosition) |>.without (C := TestEnemy)
  q2.spec.matchesArchetype arch ≡ true

  -- Add Enemy to archetype
  let archWithEnemy := arch.addComponent enemyId

  -- Now without Enemy should not match
  q2.spec.matchesArchetype archWithEnemy ≡ false

end QueryTests
