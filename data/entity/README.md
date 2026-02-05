# Entity

An archetypal Entity-Component-System (ECS) library for Lean 4.

Entity provides a foundation for building games, simulations, and other applications that benefit from the ECS architectural pattern. Entities with the same component set are stored together for cache-friendly iteration.

*Developed in collaboration with [Claude](https://claude.ai).*

## Installation

Add to your `lakefile.lean`:

```lean
require entity from git "https://github.com/nathanial/entity" @ "v0.0.1"
```

Then run:

```bash
lake update
lake build
```

**Requirements:** Lean 4.26.0 or compatible version.

## Quick Start

```lean
import Entity

open Entity

-- Define components
structure Position where
  x : Float
  y : Float

structure Velocity where
  dx : Float
  dy : Float

instance : Component Position where
  componentId := .ofTypeName "Position"
  componentName := "Position"

instance : Component Velocity where
  componentId := .ofTypeName "Velocity"
  componentName := "Velocity"

-- Spawn entities
def setup : WorldM Unit := do
  let eid ← WorldM.spawn
  let posId := Component.componentId (C := Position)
  let velId := Component.componentId (C := Velocity)
  WorldM.setArchetype eid (ArchetypeId.ofComponents #[posId, velId])

-- Create systems
def movementSystem : System :=
  System.create "movement" do
    let posId := Component.componentId (C := Position)
    let entities ← WorldM.queryEntities #[posId]
    for eid in entities do
      -- Process each entity with Position
      pure ()

-- Build and run application
def main : IO Unit := do
  let app := App.create
    |>.addStage "update"
    |>.addSystem "update" movementSystem
  let _ ← app.runFor 60  -- Run 60 ticks
```

## Core Concepts

### Entities

Entities are lightweight identifiers with a generation counter for safe reuse:

```lean
let eid ← WorldM.spawn      -- Create entity
WorldM.despawn eid          -- Destroy entity
let alive ← WorldM.isAlive eid  -- Check if valid
```

### Components

Components are plain data types registered via the `Component` typeclass:

```lean
structure Health where
  current : Nat
  maximum : Nat

instance : Component Health where
  componentId := .ofTypeName "Health"
  componentName := "Health"
```

### Archetypes

Archetypes identify entities with the same component set:

```lean
let arch := ArchetypeId.ofComponents #[posId, velId]
WorldM.setArchetype eid arch
```

### Queries

Type-safe queries with filters:

```lean
-- Query builder API
let q : Query [Position] :=
  Query.one
    |>.with_ (C := Player)    -- Must have Player
    |>.without (C := Dead)    -- Must not have Dead

-- Check if archetype matches
q.spec.matchesArchetype someArchetype
```

### Systems

Systems are named `WorldM` actions:

```lean
let sys := System.create "mySystem" do
  -- WorldM operations here
  pure ()
```

### Scheduling

Organize systems into stages:

```lean
let app := App.create
  |>.addStage "input"
  |>.addStage "update"
  |>.addStage "render"
  |>.addSystem "input" inputSystem
  |>.addSystem "update" physicsSystem
  |>.addSystem "update" aiSystem
  |>.addSystem "render" renderSystem
```

## Architecture

```
Entity/
├── Core/
│   ├── EntityId.lean      -- Entity identifier with generation
│   ├── ComponentId.lean   -- Component type identifier
│   └── ArchetypeId.lean   -- Archetype (component set) identifier
├── Storage/
│   ├── ComponentStore.lean    -- Typed component storage
│   └── Archetype.lean         -- Archetype and registry
├── World/
│   ├── EntityMeta.lean    -- Per-entity metadata
│   └── World.lean         -- Central ECS container
├── Query/
│   ├── Spec.lean          -- Query specification
│   └── Query.lean         -- Type-safe query builder
├── System/
│   ├── WorldM.lean        -- StateT World IO monad
│   └── System.lean        -- System type
└── Schedule/
    ├── SystemSet.lean     -- System grouping
    ├── Schedule.lean      -- Stage ordering
    └── App.lean           -- Application builder
```

## API Reference

### WorldM Operations

| Operation | Description |
|-----------|-------------|
| `WorldM.spawn` | Create a new entity |
| `WorldM.despawn eid` | Destroy an entity |
| `WorldM.isAlive eid` | Check if entity is valid |
| `WorldM.setArchetype eid arch` | Set entity's archetype |
| `WorldM.queryEntities cids` | Find entities with components |
| `WorldM.entityCount` | Count living entities |
| `WorldM.forEach cids f` | Iterate over matching entities |

### Query Builder

| Method | Description |
|--------|-------------|
| `Query.one (C := T)` | Start query requiring component T |
| `.and (C := T)` | Also require component T |
| `.with_ (C := T)` | Filter: must have T |
| `.without (C := T)` | Filter: must not have T |

### App Builder

| Method | Description |
|--------|-------------|
| `App.create` | Create empty application |
| `.addStage name` | Add execution stage |
| `.addSystem stage sys` | Add system to stage |
| `.tick` | Run one frame |
| `.runFor n` | Run n frames |

## Building & Testing

```bash
# Build the library
lake build

# Run tests (31 tests across 4 suites)
lake test
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## References

- [ECS Back and Forth](https://skypjack.github.io/2019-02-14-ecs-baf-part-1/) - Michele Caini
- [Building an ECS](https://ajmmertens.medium.com/building-an-ecs-1-where-are-my-entities-and-components-63d07c7da742) - Sander Mertens (flecs author)
