/-
  ComponentColumn - Type-erased column storage for components.

  Uses unsafe casts internally but provides a type-safe external API.
-/
import Entity.Core

namespace Entity

/-- Type-erased component data storage.
    Internally stores an Array of components with runtime type checking. -/
opaque ComponentColumnData : Type

/-- A column of components of a single type within an archetype. -/
structure ComponentColumn where
  /-- Component type ID for runtime type checking -/
  componentId : ComponentId
  /-- Component type name for debugging -/
  componentName : String
  /-- Type-erased component data -/
  private data : Array UInt8  -- Placeholder for actual storage
  /-- Number of components stored -/
  len : Nat
  deriving Inhabited

namespace ComponentColumn

/-- Create an empty column for a component type -/
def empty [Component C] : ComponentColumn :=
  { componentId := Component.componentId (C := C)
  , componentName := Component.componentName (C := C)
  , data := #[]
  , len := 0 }

/-- Check if the column is for a specific component type -/
def isType [Component C] (col : ComponentColumn) : Bool :=
  col.componentId == Component.componentId (C := C)

end ComponentColumn

end Entity
