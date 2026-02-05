/-
  Entity - An archetypal Entity-Component-System (ECS) library for Lean 4.

  ## Overview

  Entity provides a flexible ECS framework with:
  - Archetypal storage for entities with the same component set
  - Type-safe component access via the `Component` typeclass
  - Monadic `WorldM` interface for entity operations
  - Query system for filtering entities by components
  - System and schedule abstractions for game loops

  ## Quick Start

  ```lean
  import Entity

  -- Define components
  structure Position where x : Float; y : Float
  structure Velocity where dx : Float; dy : Float

  -- Register as ECS components
  instance : Entity.Component Position where
    componentId := .ofTypeName "Position"
    componentName := "Position"

  instance : Entity.Component Velocity where
    componentId := .ofTypeName "Velocity"
    componentName := "Velocity"

  -- Use WorldM for operations
  def example : Entity.WorldM Unit := do
    let eid ← Entity.WorldM.spawn
    -- Add components via your ComponentStore
    Entity.WorldM.setArchetype eid
      (Entity.ArchetypeId.ofList [
        Entity.Component.componentId (C := Position),
        Entity.Component.componentId (C := Velocity)
      ])
  ```

  ## Architecture

  - **Core**: EntityId, ComponentId, ArchetypeId
  - **Storage**: ComponentStore (typed), Archetype, ArchetypeRegistry
  - **World**: Entity lifecycle, archetype management
  - **Query**: Type-safe query builder with filters
  - **System**: WorldM monad, System type
  - **Schedule**: SystemSet, Schedule, App
-/

import Entity.Core
import Entity.Storage
import Entity.World
import Entity.Query
import Entity.System
import Entity.Schedule
