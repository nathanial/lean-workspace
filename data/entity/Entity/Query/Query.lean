/-
  Query - Type-safe query builder.

  Queries are built using a fluent API and executed against the world.
-/
import Entity.Core
import Entity.Query.Spec
import Entity.World
import Entity.Storage

namespace Entity

/-- A query for entities with specific components.
    The type parameter `Cs` tracks which component types are queried. -/
structure Query (Cs : List Type) where
  /-- The underlying query specification -/
  spec : QuerySpec
  deriving Inhabited

namespace Query

/-- Create a query for a single component type -/
def one [Component C] : Query [C] :=
  { spec := QuerySpec.empty.addFetch (Component.componentId (C := C)) }

/-- Add another component type to the query -/
def «and» [Component C] (q : Query Cs) : Query (C :: Cs) :=
  { spec := q.spec.addFetch (Component.componentId (C := C)) }

/-- Add a With filter (entity must have this component, but it won't be fetched) -/
def with_ [Component C] (q : Query Cs) : Query Cs :=
  { spec := q.spec.addWith (Component.componentId (C := C)) }

/-- Add a Without filter (entity must not have this component) -/
def without [Component C] (q : Query Cs) : Query Cs :=
  { spec := q.spec.addWithout (Component.componentId (C := C)) }

/-- Get the query specification -/
def toSpec (q : Query Cs) : QuerySpec := q.spec

/-- Get matching entity IDs from a world -/
def matchingEntities (q : Query Cs) (w : World) : Array EntityId :=
  w.queryEntities q.spec.requiredComponents q.spec.excludedComponents

end Query

/-- Result of iterating over a query.
    Contains the entity ID and can be used to fetch components. -/
structure QueryResult where
  /-- The entity being processed -/
  entity : EntityId
  deriving Repr, Inhabited

end Entity
