# Roadmap

This document outlines potential improvements, new features, and code cleanup opportunities for the Entity ECS library.

---

## Feature Proposals

### [Priority: High] Integrated Component Storage in World

**Description:** Currently, component data is stored externally in user-managed `ComponentStore` instances while the `World` only tracks archetype membership. Integrate type-erased component storage directly into archetypes for a more traditional ECS pattern.

**Rationale:** The current design requires users to manually manage component stores alongside the World, which adds complexity and can lead to desynchronization. Integrated storage would provide:
- Automatic component lifecycle management tied to entity lifecycle
- Better cache locality for archetype iteration
- Simplified API for adding/removing components

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Storage/ComponentColumn.lean` (currently a placeholder)
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Storage/Archetype.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/World.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/System/WorldM.lean`

**Estimated Effort:** Large

**Dependencies:** None

---

### [Priority: High] WorldM Component Add/Remove/Get Operations

**Description:** Add `WorldM.addComponent`, `WorldM.removeComponent`, and `WorldM.getComponent` operations that automatically manage archetype transitions.

**Rationale:** Currently, users must manually:
1. Store components in their own `ComponentStore`
2. Call `WorldM.setArchetype` with the new archetype

This is error-prone and verbose. Direct component operations would be more intuitive:
```lean
def spawn : WorldM EntityId := do
  let eid <- WorldM.spawn
  WorldM.addComponent eid (Position.mk 0 0)
  WorldM.addComponent eid (Velocity.mk 1 0)
  pure eid
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/System/WorldM.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/World.lean`

**Estimated Effort:** Medium (depends on integrated storage)

**Dependencies:** Integrated Component Storage in World

---

### [Priority: High] Query Iteration with Component Data

**Description:** Extend query iteration to yield actual component data, not just entity IDs.

**Rationale:** Currently, `WorldM.forEach` only provides `EntityId`, requiring users to look up component data manually from their external stores. A complete ECS pattern would yield component tuples:
```lean
-- Current pattern (verbose)
WorldM.forEach posVelQuery fun eid => do
  let pos <- getPosition eid  -- External lookup
  let vel <- getVelocity eid  -- External lookup
  setPosition eid { pos with x := pos.x + vel.dx }

-- Proposed pattern (ergonomic)
WorldM.forEach posVelQuery fun (eid, pos, vel) => do
  pure (eid, { pos with x := pos.x + vel.dx }, vel)
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Query.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/System/WorldM.lean`

**Estimated Effort:** Large

**Dependencies:** Integrated Component Storage in World

---

### [Priority: Medium] Optional Components in Queries

**Description:** Add `Query.optional` for components that are fetched if present but do not filter entities.

**Rationale:** Many game systems need to handle entities that may or may not have certain components:
```lean
-- Fetch Position, optionally fetch Velocity
let q := Query.one (C := Position) |>.optional (C := Velocity)
-- Results: (EntityId, Position, Option Velocity)
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Spec.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Query.lean`

**Estimated Effort:** Medium

**Dependencies:** Query Iteration with Component Data

---

### [Priority: Medium] Changed/Added Component Queries

**Description:** Add filters for entities whose components were added or changed this tick.

**Rationale:** Common ECS pattern for reactive systems:
```lean
-- Only process entities whose Position changed
let q := Query.one (C := Position) |>.changed (C := Position)

-- Only process newly added entities
let q := Query.one (C := Position) |>.added (C := Position)
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Spec.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Query.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/World.lean` (change tracking)

**Estimated Effort:** Large

**Dependencies:** None (can be implemented with current design)

---

### [Priority: Medium] Resources (Singleton Components)

**Description:** Add support for singleton "resources" - global state accessible in systems.

**Rationale:** Games often need global state like time, input, configuration:
```lean
structure DeltaTime where seconds : Float

def movementSystem : System := System.create "movement" do
  let dt <- WorldM.getResource (R := DeltaTime)
  WorldM.forEach posVelQuery fun eid => do
    -- Use dt.seconds for frame-independent movement
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/World.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/System/WorldM.lean`
- New file: `Entity/Resource.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Parallel System Execution

**Description:** Add support for running systems in parallel when they have non-conflicting component access.

**Rationale:** Performance improvement for systems that access disjoint component sets. The `Access` enum in `QuerySpec` already distinguishes read/write access but is not utilized.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Spec.lean` (Access enum)
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Schedule/Schedule.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Schedule/SystemSet.lean`

**Estimated Effort:** Large

**Dependencies:** Conduit library (for parallel execution)

---

### [Priority: Medium] System Ordering Constraints

**Description:** Add declarative system ordering (before/after relationships).

**Rationale:** Allow systems to declare ordering without explicit stage placement:
```lean
let sys1 := System.create "physics" do ...
let sys2 := System.create "render" do ...
  |>.after sys1  -- Ensures physics runs before render

let app := App.create
  |>.addSystem sys1
  |>.addSystem sys2  -- Automatically ordered
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/System/System.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Schedule/Schedule.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Entity Commands / Deferred Operations

**Description:** Add a command buffer for deferred entity operations.

**Rationale:** During iteration, spawning/despawning entities can invalidate iterators. Commands allow deferring these operations:
```lean
WorldM.forEach query fun eid => do
  if shouldDespawn eid then
    WorldM.commands.despawn eid  -- Deferred
  if shouldSpawn then
    WorldM.commands.spawn        -- Deferred

-- Commands automatically applied after iteration
```

**Affected Files:**
- New file: `Entity/Commands.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/System/WorldM.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Schedule/Schedule.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Low] Events System

**Description:** Add typed events for cross-system communication.

**Rationale:** Decouple systems that need to communicate:
```lean
structure CollisionEvent where
  entity1 : EntityId
  entity2 : EntityId

def collisionSystem : System := System.create "collision" do
  for (e1, e2) in collisions do
    WorldM.sendEvent (CollisionEvent.mk e1 e2)

def damageSystem : System := System.create "damage" do
  WorldM.forEvent (E := CollisionEvent) fun ev => do
    applyDamage ev.entity1 ev.entity2
```

**Affected Files:**
- New file: `Entity/Events.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/World.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/System/WorldM.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Low] Entity Relations

**Description:** Add support for relationships between entities (parent-child, references).

**Rationale:** Many games need hierarchical relationships:
```lean
-- Create parent-child relationship
WorldM.addRelation child (Parent parent)

-- Query children of an entity
WorldM.queryChildren parent
```

**Affected Files:**
- New file: `Entity/Relation.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Core/`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/World.lean`

**Estimated Effort:** Large

**Dependencies:** None

---

### [Priority: Low] World Serialization

**Description:** Add serialization/deserialization of world state.

**Rationale:** Enable save/load functionality for games and debugging.

**Affected Files:**
- New file: `Entity/Serialize.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/World.lean`

**Estimated Effort:** Large

**Dependencies:** Integrated Component Storage in World

---

### [Priority: Low] Component Derive Macro

**Description:** Add a derive macro for automatic Component instance generation.

**Rationale:** Reduce boilerplate:
```lean
-- Current
structure Position where x : Float; y : Float

instance : Entity.Component Position where
  componentId := .ofTypeName "Position"
  componentName := "Position"

-- Proposed
structure Position where x : Float; y : Float
  deriving Entity.Component
```

**Affected Files:**
- New file: `Entity/Derive.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Core/ComponentId.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

## Code Improvements

### [Priority: High] Complete ComponentColumn Implementation

**Current State:** `ComponentColumn` in `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Storage/ComponentColumn.lean` is a placeholder with `Array UInt8` storage and no actual type-erased storage implementation.

**Proposed Change:** Implement proper type-erased storage using Lean's FFI or runtime type information:
- Use `lean_object*` arrays for dynamic component storage
- Implement type-safe get/set operations
- Add proper memory management

**Benefits:** Enables integrated component storage, better cache performance.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Storage/ComponentColumn.lean`

**Estimated Effort:** Large

---

### [Priority: Medium] Utilize Access Enum in QuerySpec

**Current State:** The `Access` enum (read/write) in `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Spec.lean` (lines 8-12) is defined but never used.

**Proposed Change:** Either:
1. Remove the unused `Access` enum if not planned for use
2. Integrate it into query building for parallel system analysis

**Benefits:** Cleaner code or enabled parallel execution.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Spec.lean`
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Query.lean`

**Estimated Effort:** Small (removal) or Medium (integration)

---

### [Priority: Medium] EntityMeta.kill Should Increment Generation

**Current State:** In `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/EntityMeta.lean` (line 32-33), `kill` only sets `alive := false` without incrementing generation.

**Proposed Change:** Increment generation on kill to ensure old references become stale immediately:
```lean
def kill (self : EntityMeta) : EntityMeta :=
  { self with alive := false, generation := self.generation + 1 }
```

**Benefits:** Stronger stale reference detection, prevents edge cases where a despawned entity at the same generation could be incorrectly validated.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/EntityMeta.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Improve World.spawn Efficiency

**Current State:** In `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/World.lean` (lines 70-92), spawning creates padding arrays via `List.replicate(...).toArray` which is inefficient.

**Proposed Change:** Use `Array.mkArray` directly and avoid intermediate list:
```lean
let padArr := Array.mkArray padding EntityMeta.dead
```

**Benefits:** Better performance for initial entity allocation.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/World.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] QuerySpec Deduplication

**Current State:** `QuerySpec.requiredComponents` can return duplicates if the same component is both fetched and added via `with_` filter.

**Proposed Change:** Deduplicate the result array or prevent duplicate additions during query building.

**Benefits:** Correct query matching, avoid redundant archetype checks.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Spec.lean` (lines 45-51)

**Estimated Effort:** Small

---

### [Priority: Low] Add World Statistics/Debugging

**Current State:** Limited introspection capabilities.

**Proposed Change:** Add methods for debugging and profiling:
- `World.archetypeCount` - number of archetypes
- `World.archetypeStats` - entities per archetype
- `World.debugPrint` - formatted world state dump

**Benefits:** Easier debugging and performance analysis.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/World/World.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Use Array.binSearchWithIndex for ArchetypeId.indexOf

**Current State:** `ArchetypeId.indexOf` uses linear `findIdx?` despite components being sorted.

**Proposed Change:** Use binary search for O(log n) lookup:
```lean
def indexOf (aid : ArchetypeId) (cid : ComponentId) : Option Nat :=
  aid.components.binSearchWithIndex cid (fun a b => a.id < b.id) |>.map (·.1)
```

**Benefits:** Better performance for large archetypes.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Core/ArchetypeId.lean` (lines 63-65)

**Estimated Effort:** Small

---

## Code Cleanup

### [Priority: Medium] Document Access Enum Purpose or Remove

**Issue:** The `Access` enum in `Entity/Query/Spec.lean` is defined but unused.

**Location:** `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Spec.lean` lines 8-12

**Action Required:**
1. Add documentation explaining planned usage
2. Or remove if not planned for parallel system execution

**Estimated Effort:** Small

---

### [Priority: Low] Consistent Query Builder Naming

**Issue:** Query builder uses both `and` and `with_` patterns with subtle semantic differences that may confuse users.

**Location:** `/Users/Shared/Projects/lean-workspace/data/entity/Entity/Query/Query.lean`

**Action Required:** Add clear documentation distinguishing:
- `and` - adds component to fetch list (will be returned)
- `with_` - adds filter only (not returned, just required to match)
- `without` - excludes entities with component

**Estimated Effort:** Small

---

### [Priority: Low] Add Missing EntityTests.lean Module File

**Issue:** There is no `EntityTests.lean` root module file; tests are imported directly in `Main.lean`.

**Location:** `/Users/Shared/Projects/lean-workspace/data/entity/EntityTests/`

**Action Required:** Add `EntityTests.lean` for consistency with library structure:
```lean
import EntityTests.CoreTests
import EntityTests.WorldTests
import EntityTests.QueryTests
import EntityTests.SystemTests
```

**Estimated Effort:** Small

---

### [Priority: Low] Add Tests for Edge Cases

**Issue:** Missing test coverage for:
- EntityId overflow/wraparound
- Very large entity counts
- Despawn during iteration
- Empty query results

**Location:** `/Users/Shared/Projects/lean-workspace/data/entity/EntityTests/`

**Action Required:** Add tests for edge cases and error conditions.

**Estimated Effort:** Medium

---

### [Priority: Low] Add Tests for Schedule Edge Cases

**Issue:** No tests for:
- Adding systems to non-existent stages
- Empty schedule execution
- `runUntil` termination

**Location:** `/Users/Shared/Projects/lean-workspace/data/entity/EntityTests/SystemTests.lean`

**Action Required:** Expand test coverage for Schedule and App.

**Estimated Effort:** Small

---

### [Priority: Low] Add README.md

**Issue:** No user-facing README documentation.

**Location:** `/Users/Shared/Projects/lean-workspace/data/entity/`

**Action Required:** Create README.md with:
- Project overview
- Installation instructions
- Quick start guide
- API overview
- Example code

**Estimated Effort:** Small

---

## Summary

### High Priority Items
1. Integrated Component Storage in World
2. WorldM Component Add/Remove/Get Operations
3. Query Iteration with Component Data
4. Complete ComponentColumn Implementation

### Quick Wins (Small Effort, Medium+ Priority)
1. EntityMeta.kill generation increment
2. World.spawn efficiency improvement
3. QuerySpec deduplication
4. Document or remove Access enum

### Future Vision
The library has a solid foundation with archetypal storage, queries, and scheduling. The main gap is the lack of integrated component storage - the current design pushes component management to users. Addressing this would transform the library from a "bring your own storage" framework to a complete ECS solution.

Key milestones:
1. **v0.1** - Current state (archetype tracking only)
2. **v0.2** - Integrated component storage, component operations in WorldM
3. **v0.3** - Resources, Events, Entity Commands
4. **v0.4** - Parallel execution, System ordering
5. **v1.0** - Relations, Serialization, Change detection
