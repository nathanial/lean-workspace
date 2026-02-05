/-
  SystemTests - Tests for Entity.System and Entity.Schedule.
-/
import Entity
import Crucible

namespace SystemTests

open Crucible Entity

testSuite "SystemTests"

test "WorldM spawn and count" := do
  let action : WorldM Nat := do
    let _ ← WorldM.spawn
    let _ ← WorldM.spawn
    let _ ← WorldM.spawn
    WorldM.entityCount
  let count ← WorldM.run' action
  count ≡ 3

test "WorldM spawn and despawn" := do
  let action : WorldM Nat := do
    let e1 ← WorldM.spawn
    let _ ← WorldM.spawn
    WorldM.despawn e1
    WorldM.entityCount
  let count ← WorldM.run' action
  count ≡ 1

test "WorldM isAlive" := do
  let action : WorldM (Bool × Bool) := do
    let e1 ← WorldM.spawn
    let alive1 ← WorldM.isAlive e1
    WorldM.despawn e1
    let alive2 ← WorldM.isAlive e1
    pure (alive1, alive2)
  let (before, after) ← WorldM.run' action
  before ≡ true
  after ≡ false

test "System create and run" := do
  let counter : IO.Ref Nat ← IO.mkRef 0
  let sys := System.create "counter" do
    counter.modify (· + 1)
  let _ ← WorldM.exec sys.run
  let count ← counter.get
  count ≡ 1

test "SystemSet run multiple systems" := do
  let counter : IO.Ref Nat ← IO.mkRef 0
  let sys1 := System.create "inc1" do counter.modify (· + 1)
  let sys2 := System.create "inc2" do counter.modify (· + 10)
  let ss := SystemSet.empty "test"
    |>.add sys1
    |>.add sys2
  let _ ← WorldM.exec ss.run
  let count ← counter.get
  count ≡ 11

test "Schedule run stages" := do
  let log : IO.Ref (Array String) ← IO.mkRef #[]
  let sys1 := System.create "first" do log.modify (·.push "first")
  let sys2 := System.create "second" do log.modify (·.push "second")
  let sched := Schedule.empty
    |>.addStage "stage1"
    |>.addStage "stage2"
    |>.addSystem "stage1" sys1
    |>.addSystem "stage2" sys2
  let _ ← WorldM.exec sched.run
  let result ← log.get
  result ≡ #["first", "second"]

test "App tick" := do
  let counter : IO.Ref Nat ← IO.mkRef 0
  let sys := System.create "inc" do counter.modify (· + 1)
  let app := App.create
    |>.addStage "update"
    |>.addSystem "update" sys
  let _ ← app.tick
  let count ← counter.get
  count ≡ 1

test "App runFor" := do
  let counter : IO.Ref Nat ← IO.mkRef 0
  let sys := System.create "inc" do counter.modify (· + 1)
  let app := App.create
    |>.addStage "update"
    |>.addSystem "update" sys
  let _ ← app.runFor 5
  let count ← counter.get
  count ≡ 5

end SystemTests
