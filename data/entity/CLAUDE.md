# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Build Commands

```bash
cd data/entity
lake build                    # Build library
lake test                     # Run tests
lake build entity_tests && .lake/build/bin/entity_tests  # Run tests directly
```

## Overview

Entity is an archetypal Entity-Component-System (ECS) library for Lean 4. It provides:

- **Archetypal storage**: Entities with the same component set are grouped together
- **Type-safe components**: Components are registered via the `Component` typeclass
- **Monadic API**: `WorldM` monad (StateT World IO) for entity operations
- **Query system**: Type-safe queries with With/Without filters
- **Scheduling**: Systems, stages, and application loops

## Architecture

### Core Types (`Entity/Core/`)

| Type | Description |
|------|-------------|
| `EntityId` | Entity identifier with index + generation for safe reuse |
| `ComponentId` | Type-based component identifier (hash of type name) |
| `ArchetypeId` | Sorted array of ComponentIds identifying a component set |
| `Component` | Typeclass for registering component types |

### Storage Layer (`Entity/Storage/`)

| Type | Description |
|------|-------------|
| `ComponentStore C` | Typed HashMap storage for component type C |
| `Archetype` | Tracks entities with the same component set |
| `ArchetypeRegistry` | Collection of all archetypes |

### World (`Entity/World/`)

| Type | Description |
|------|-------------|
| `EntityMeta` | Per-entity metadata (generation, archetype, alive) |
| `World` | Central container with entity array and archetype registry |

### Query System (`Entity/Query/`)

| Type | Description |
|------|-------------|
| `QuerySpec` | Query specification with fetch/with/without filters |
| `Query Cs` | Type-safe query builder parameterized by component list |

### System Layer (`Entity/System/`)

| Type | Description |
|------|-------------|
| `WorldM` | StateT World IO monad for ECS operations |
| `System` | Named WorldM action |

### Schedule (`Entity/Schedule/`)

| Type | Description |
|------|-------------|
| `SystemSet` | Group of systems (a stage) |
| `Schedule` | Ordered list of stages |
| `App` | Application with world + schedule |

## Key Patterns

### Defining Components

```lean
structure Position where x : Float; y : Float

instance : Entity.Component Position where
  componentId := .ofTypeName "Position"
  componentName := "Position"
```

### WorldM Operations

```lean
open Entity in
def setup : WorldM Unit := do
  let eid ← WorldM.spawn
  -- Components stored in your own ComponentStores
  WorldM.setArchetype eid (ArchetypeId.ofList [Component.getId (C := Position)])
```

### Building Queries

```lean
open Entity in
def positionQuery : Query [Position] :=
  Query.one
    |>.with_ (C := Player)      -- Must have Player
    |>.without (C := Dead)      -- Must not have Dead
```

### Defining Systems

```lean
open Entity in
def movementSystem : System :=
  System.create "movement" do
    let entities ← WorldM.queryEntities #[Component.getId (C := Position)]
    for eid in entities do
      -- Process each entity
      pure ()
```

### Building Applications

```lean
open Entity in
def main : IO Unit := do
  let app := App.create
    |>.addStage "update"
    |>.addSystem "update" movementSystem
  let _ ← app.runFor 60  -- Run 60 ticks
```

## Component Storage Pattern

Since Lean is a dependently-typed language, component data is stored in typed `ComponentStore C` instances. Users maintain their own stores:

```lean
structure GameComponents where
  positions : Entity.ComponentStore Position
  velocities : Entity.ComponentStore Velocity

def getPosition (comps : GameComponents) (eid : EntityId) : Option Position :=
  comps.positions.get eid
```

## Dependencies

- `crucible` - Test framework (dev dependency)

## Key Files

- `Entity.lean` - Root module
- `Entity/Core/EntityId.lean` - Entity identifier with generation
- `Entity/World/World.lean` - Central ECS container
- `Entity/System/WorldM.lean` - Monadic API
- `Entity/Schedule/App.lean` - Application builder
