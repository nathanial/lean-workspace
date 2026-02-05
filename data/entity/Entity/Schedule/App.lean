/-
  App - Application builder for ECS applications.
-/
import Entity.Schedule.Schedule

namespace Entity

/-- An ECS application with a world and schedule. -/
structure App where
  /-- The world containing all entities -/
  world : World
  /-- The execution schedule -/
  schedule : Schedule
  deriving Inhabited

namespace App

/-- Create a new empty application -/
def create : App :=
  { world := World.empty
  , schedule := Schedule.empty }

/-- Create an application with a pre-configured world -/
def withWorld (world : World) : App :=
  { world, schedule := Schedule.empty }

/-- Add a stage to the schedule -/
def addStage (app : App) (name : String) : App :=
  { app with schedule := app.schedule.addStage name }

/-- Add a system to a named stage -/
def addSystem (app : App) (stageName : String) (sys : System) : App :=
  { app with schedule := app.schedule.addSystem stageName sys }

/-- Add a system to the last stage -/
def addSystemToLast (app : App) (sys : System) : App :=
  { app with schedule := app.schedule.addSystemToLast sys }

/-- Run one tick of the application -/
def tick (app : App) : IO App := do
  let ((), world') ← app.schedule.run.run app.world
  pure { app with world := world' }

/-- Run the application for a fixed number of ticks -/
def runFor (app : App) (ticks : Nat) : IO App := do
  let mut app := app
  for _ in [0:ticks] do
    app ← app.tick
  pure app

/-- Run the application continuously until a condition is met -/
partial def runUntil (app : App) (shouldStop : App → IO Bool) : IO App := do
  if ← shouldStop app then
    pure app
  else
    let app' ← app.tick
    runUntil app' shouldStop

/-- Run a WorldM action on the app's world -/
def runWorldM (app : App) (action : WorldM α) : IO (α × App) := do
  let (result, world') ← action.run app.world
  pure (result, { app with world := world' })

/-- Execute a WorldM action on the app's world, updating the app -/
def execWorldM (app : App) (action : WorldM Unit) : IO App := do
  let world' ← WorldM.exec action app.world
  pure { app with world := world' }

end App

end Entity
