/-
  Schedule - System execution scheduling.
-/
import Entity.Schedule.SystemSet

namespace Entity

/-- A schedule defines the execution order of system sets. -/
structure Schedule where
  /-- Ordered list of system sets (stages) -/
  stages : Array SystemSet
  deriving Inhabited

namespace Schedule

/-- Create an empty schedule -/
def empty : Schedule := { stages := #[] }

/-- Add a new stage to the schedule -/
def addStage (sched : Schedule) (name : String) : Schedule :=
  { stages := sched.stages.push (SystemSet.empty name) }

/-- Add a system to a named stage -/
def addSystem (sched : Schedule) (stageName : String) (sys : System) : Schedule :=
  let stages := sched.stages.map fun ss =>
    if ss.name == stageName then ss.add sys else ss
  { stages }

/-- Add a system to the last stage -/
def addSystemToLast (sched : Schedule) (sys : System) : Schedule :=
  if sched.stages.isEmpty then sched
  else
    let idx := sched.stages.size - 1
    let ss := sched.stages[idx]!
    { stages := sched.stages.set! idx (ss.add sys) }

/-- Get a stage by name -/
def getStage (sched : Schedule) (name : String) : Option SystemSet :=
  sched.stages.find? (·.name == name)

/-- Run the full schedule -/
def run (sched : Schedule) : WorldM Unit := do
  for stage in sched.stages do
    stage.run

/-- Number of stages -/
def stageCount (sched : Schedule) : Nat := sched.stages.size

/-- Total number of systems across all stages -/
def systemCount (sched : Schedule) : Nat :=
  sched.stages.foldl (init := 0) fun count ss => count + ss.size

end Schedule

end Entity
