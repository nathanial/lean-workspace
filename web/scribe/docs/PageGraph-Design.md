# PageGraph: Reified HTMX Interaction Model

## Goal

Represent an HTMX-enhanced page as a first-class data structure that can be:
- **Analyzed** - Query the interaction graph
- **Verified** - Prove properties (all targets exist, no orphans, etc.)
- **Manipulated** - Transform, compose, generate docs/tests

## Core Model

```lean
-- Regions are the "nodes" of the page
structure Region where
  id : String
  kind : RegionKind
  deriving Repr, BEq

inductive RegionKind where
  | stable    -- Contains ephemeral user state, never HTMX-refreshed
  | volatile  -- Can be updated via HTMX swap
  deriving Repr, BEq

-- Interactions are the "edges" - connecting triggers to targets via routes
structure Interaction where
  id : String              -- Unique interaction identifier
  triggerElement : String  -- Element ID or description
  sourceRegion : String    -- Region containing the trigger
  method : HttpMethod
  route : String           -- Route path
  targetRegion : String    -- Region that gets updated
  swap : SwapMode
  trigger : TriggerEvent   -- What triggers this (click, submit, load, etc.)
  deriving Repr

inductive HttpMethod where
  | get | post | put | patch | delete
  deriving Repr, BEq

inductive SwapMode where
  | innerHTML | outerHTML | beforebegin | afterbegin
  | beforeend | afterend | delete | none
  deriving Repr, BEq

inductive TriggerEvent where
  | click | submit | load | revealed | intersect
  | every (seconds : Nat)
  | custom (event : String)
  deriving Repr

-- The complete page graph
structure PageGraph where
  name : String
  regions : List Region
  interactions : List Interaction
  deriving Repr
```

## Verifiable Properties

```lean
namespace PageGraph

-- All interaction targets reference existing regions
def allTargetsExist (pg : PageGraph) : Prop :=
  ∀ i ∈ pg.interactions, ∃ r ∈ pg.regions, r.id = i.targetRegion

-- All interaction sources reference existing regions
def allSourcesExist (pg : PageGraph) : Prop :=
  ∀ i ∈ pg.interactions, ∃ r ∈ pg.regions, r.id = i.sourceRegion

-- Targets are always volatile (stable regions shouldn't be swapped)
def targetsAreVolatile (pg : PageGraph) : Prop :=
  ∀ i ∈ pg.interactions,
    ∀ r ∈ pg.regions, r.id = i.targetRegion → r.kind = .volatile

-- No region targets itself (potential infinite loop)
def noSelfTargeting (pg : PageGraph) : Prop :=
  ∀ i ∈ pg.interactions, i.sourceRegion ≠ i.targetRegion

-- Every non-root region is reachable (no orphans)
def noOrphanedRegions (pg : PageGraph) (root : String) : Prop :=
  ∀ r ∈ pg.regions,
    r.id = root ∨ ∃ i ∈ pg.interactions, i.targetRegion = r.id

-- Well-formedness combines all properties
structure WellFormed (pg : PageGraph) (root : String) : Prop where
  targetsExist : pg.allTargetsExist
  sourcesExist : pg.allSourcesExist
  targetsVolatile : pg.targetsAreVolatile
  noSelfTarget : pg.noSelfTargeting
  noOrphans : pg.noOrphanedRegions root

end PageGraph
```

## Graph Analysis

```lean
namespace PageGraph

-- Find all regions reachable from a given region
def reachableFrom (pg : PageGraph) (regionId : String) : List String :=
  -- Transitive closure of: region → interactions from region → target regions
  sorry

-- Find all interactions that can update a region
def incomingInteractions (pg : PageGraph) (regionId : String) : List Interaction :=
  pg.interactions.filter (·.targetRegion == regionId)

-- Find all interactions triggered from a region
def outgoingInteractions (pg : PageGraph) (regionId : String) : List Interaction :=
  pg.interactions.filter (·.sourceRegion == regionId)

-- Detect cycles in the interaction graph
def findCycles (pg : PageGraph) : List (List String) :=
  sorry

-- Find dead-end regions (no outgoing interactions)
def deadEnds (pg : PageGraph) : List Region :=
  pg.regions.filter fun r =>
    pg.outgoingInteractions r.id |>.isEmpty

end PageGraph
```

## Integration Approaches

### Approach A: Graph-First (Generate HTML from Graph)

```lean
-- Define the graph declaratively
def kanbanPage : PageGraph := {
  name := "Kanban Board"
  regions := [
    { id := "board", kind := .volatile },
    { id := "column-form", kind := .stable },
    { id := "card-modal", kind := .stable }
  ]
  interactions := [
    { id := "load-board"
      triggerElement := "page"
      sourceRegion := "root"
      method := .get
      route := "/kanban/columns"
      targetRegion := "board"
      swap := .innerHTML
      trigger := .load },
    { id := "add-column"
      triggerElement := "add-column-btn"
      sourceRegion := "board"
      method := .post
      route := "/kanban/column"
      targetRegion := "board"
      swap := .beforeend
      trigger := .submit }
  ]
}

-- Prove it's well-formed
theorem kanbanPage_wellformed : kanbanPage.WellFormed "root" := by
  sorry

-- Generate HTML from the graph
def renderPage (pg : PageGraph) : Html := sorry
```

### Approach B: HTML-First (Extract Graph from HTML)

```lean
-- Build HTML as normal, but track interactions
def kanbanView : HtmlM .stable .toplevel PageGraph := do
  let board ← volatileRegion "board" [] do
    button [hx_post' Route.addColumn, hx_target_self, hx_swap "beforeend"]
      (text "Add Column")

  stableRegion "column-form" [] do
    form [hx_post' Route.createColumn, hx_target board] do
      input [name_ "title"]

  -- PageGraph is accumulated in the monad state
  getPageGraph

-- Extract and verify
#check kanbanView.run.2.wellFormed
```

### Approach C: Parallel Construction (Build Both, Prove Equivalence)

```lean
-- Define graph spec
def kanbanSpec : PageGraph := { ... }

-- Define HTML implementation
def kanbanHtml : HtmlM .stable .toplevel Unit := do ...

-- Prove they match
theorem kanban_matches_spec :
  extractGraph kanbanHtml = kanbanSpec := by
  sorry
```

## Route Integration

Connect routes to the regions they update:

```lean
-- Routes declare their target region
class RouteTarget (R : Type) where
  targetRegion : R → String
  contentKind : R → RegionKind  -- What kind of content does this route return?

-- Verify route returns content appropriate for target
def routeConsistent (pg : PageGraph) [HasPath R] [RouteTarget R] : Prop :=
  ∀ i ∈ pg.interactions,
    ∀ route : R, HasPath.path route = i.route →
      RouteTarget.contentKind route = .volatile  -- Route returns volatile content
```

## Visualization

```lean
-- Generate Mermaid diagram from graph
def PageGraph.toMermaid (pg : PageGraph) : String :=
  let nodes := pg.regions.map fun r =>
    s!"  {r.id}[{r.id}]:::{r.kind}"
  let edges := pg.interactions.map fun i =>
    s!"  {i.sourceRegion} -->|{i.method} {i.route}| {i.targetRegion}"
  s!"graph TD\n{String.intercalate "\n" nodes}\n{String.intercalate "\n" edges}"

-- Example output:
-- graph TD
--   board[board]:::volatile
--   column-form[column-form]:::stable
--   board -->|POST /kanban/column| board
--   column-form -->|POST /kanban/column| board
```

## Open Questions

1. **Granularity**: Should we track individual elements or just regions?

2. **Dynamic content**: How to model content that varies (e.g., list of cards)?

3. **Conditional interactions**: Some interactions only exist based on state?

4. **Composition**: How to compose sub-page graphs into full pages?

5. **Server state**: Should the graph model server-side state transitions too?

6. **SSE/WebSocket**: How to model push-based updates vs request-based?
