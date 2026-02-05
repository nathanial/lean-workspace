/-
  SystemSet - Grouping of related systems (a stage).
-/
import Entity.System

namespace Entity

/-- A system set groups related systems that run together.
    Also known as a "stage" in some ECS frameworks. -/
structure SystemSet where
  /-- Name of the system set -/
  name : String
  /-- Systems in this set, executed in order -/
  systems : Array System
  deriving Inhabited

namespace SystemSet

/-- Create an empty system set -/
def empty (name : String) : SystemSet :=
  { name, systems := #[] }

/-- Add a system to the set -/
def add (ss : SystemSet) (sys : System) : SystemSet :=
  { ss with systems := ss.systems.push sys }

/-- Add multiple systems to the set -/
def addMany (ss : SystemSet) (syss : Array System) : SystemSet :=
  { ss with systems := ss.systems ++ syss }

/-- Run all systems in the set sequentially -/
def run (ss : SystemSet) : WorldM Unit := do
  for sys in ss.systems do
    sys.execute

/-- Number of systems in the set -/
def size (ss : SystemSet) : Nat := ss.systems.size

/-- Check if the set is empty -/
def isEmpty (ss : SystemSet) : Bool := ss.systems.isEmpty

end SystemSet

end Entity
