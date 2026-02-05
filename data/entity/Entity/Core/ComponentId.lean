/-
  ComponentId - Type-based component identification.

  Each component type is assigned a unique ID based on its type name hash.
-/
namespace Entity

/-- Unique identifier for a component type, derived from type name. -/
structure ComponentId where
  id : UInt64
  deriving Repr, BEq, Hashable, Inhabited

namespace ComponentId

instance : Ord ComponentId where
  compare a b := compare a.id b.id

instance : ToString ComponentId where
  toString c := s!"ComponentId({c.id})"

/-- Generate ComponentId from type name hash -/
def ofTypeName (name : String) : ComponentId :=
  { id := name.hash }

end ComponentId

/-- Typeclass for types that can be used as ECS components.

    Components must provide a unique identifier and optionally a name for debugging. -/
class Component (C : Type) where
  /-- Unique identifier for this component type -/
  componentId : ComponentId
  /-- Component name for debugging -/
  componentName : String := "Component"

namespace Component

/-- Get the component ID for a type -/
def getId [Component C] : ComponentId := componentId (C := C)

/-- Get the component name for a type -/
def getName [Component C] : String := componentName (C := C)

end Component

end Entity
