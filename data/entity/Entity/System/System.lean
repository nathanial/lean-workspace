/-
  System - ECS system definitions.

  A system is a function that operates on the world, typically
  processing entities that match certain queries.
-/
import Entity.System.WorldM

namespace Entity

/-- A system is a named WorldM action that processes entities. -/
structure System where
  /-- System name for debugging and scheduling -/
  name : String
  /-- The system's main logic -/
  run : WorldM Unit
  deriving Inhabited

namespace System

/-- Create a system from a name and WorldM action -/
def create (name : String) (action : WorldM Unit) : System :=
  { name, run := action }

/-- Create a query-based system that processes matching entities -/
def forQuery (name : String) (q : Query Cs) (f : EntityId → WorldM Unit) : System :=
  { name, run := WorldM.forEach q f }

/-- Run a system -/
def execute (sys : System) : WorldM Unit := sys.run

/-- Combine two systems sequentially -/
def andThen (sys1 sys2 : System) : System :=
  { name := s!"{sys1.name} >> {sys2.name}"
  , run := do sys1.run; sys2.run }

instance : Append System where
  append := andThen

end System

end Entity
