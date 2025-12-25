# Implement Global Search

## Summary

Add a global search feature that searches across all sections (Kanban cards, notes, recipes, etc.) and displays unified results.

## Current State

- No search functionality
- Each section would need its own search (when implemented)
- No way to find content across the app

## Requirements

### Routes

```
GET /search?q=<query>             → Search results page
GET /search/suggest?q=<query>     → HTMX autocomplete suggestions
```

### Search Index Strategy

#### Option 1: Query-Time Search (Simple)

Search each entity type at query time:

```lean
def globalSearch (db : Database) (userId : EntityId) (query : String) : IO SearchResults := do
  let query := query.toLower

  -- Search Kanban cards
  let cards ← searchCards db userId query

  -- Search notes (when implemented)
  let notes ← searchNotes db userId query

  -- Search recipes (when implemented)
  let recipes ← searchRecipes db userId query

  -- Combine and rank results
  return combineResults cards notes recipes
```

#### Option 2: Full-Text Index (Advanced)

Build a search index for faster queries:

```lean
structure SearchIndex where
  terms : HashMap String (List SearchHit)

structure SearchHit where
  entityType : String    -- "card", "note", "recipe"
  entityId : EntityId
  field : String         -- "title", "content", "description"
  score : Float
```

### Search Implementation

```lean
-- Actions/Search.lean

def search : ActionM Unit := do
  requireAuth
  let query ← param? "q"
  match query with
  | none => render Views.Search.empty
  | some q =>
    if q.length < 2 then
      render Views.Search.empty
    else
      let userId ← currentUserEntityId
      let results ← globalSearch ctx.db userId q
      render (Views.Search.results q results)

def suggest : ActionM Unit := do
  requireAuth
  let query ← param "q"
  let userId ← currentUserEntityId
  let suggestions ← quickSuggest ctx.db userId query 5
  render (Views.Search.suggestions suggestions)
```

### Search Functions

```lean
def searchCards (db : Database) (userId : EntityId) (query : String) : IO (List SearchResult) := do
  let cards ← getCardsForUser db userId
  let matches := cards.filter fun card =>
    card.title.toLower.containsSubstr query ||
    card.description.toLower.containsSubstr query ||
    card.labels.toLower.containsSubstr query
  return matches.map fun card => {
    entityType := "card"
    entityId := EntityId.ofNat card.id
    title := card.title
    preview := card.description.take 100
    url := s!"/kanban/card/{card.id}"
    icon := "📋"
  }

structure SearchResult where
  entityType : String
  entityId : EntityId
  title : String
  preview : String
  url : String
  icon : String
  score : Float := 1.0
  deriving Repr

structure SearchResults where
  query : String
  results : List SearchResult
  totalCount : Nat
  timeTaken : Float
```

### Views

```lean
-- Views/Search.lean

def searchBox : HtmlM Unit := do
  form [action "/search", method "get", class "search-form"] do
    input [
      type "search",
      name "q",
      placeholder "Search everything...",
      hxGet "/search/suggest",
      hxTrigger "keyup changed delay:300ms",
      hxTarget "#search-suggestions"
    ]
    div [id "search-suggestions"] do pure ()
    button [type "submit"] do text "Search"

def results (query : String) (results : SearchResults) : HtmlM Unit := do
  layout s!"Search: {query}" do
    h1 do text s!"Search results for \"{query}\""

    p do text s!"Found {results.totalCount} results"

    if results.results.isEmpty then
      div [class "no-results"] do
        text "No results found. Try different keywords."
    else
      div [class "search-results"] do
        for result in results.results do
          resultCard result

def resultCard (result : SearchResult) : HtmlM Unit := do
  a [href result.url, class "search-result"] do
    span [class "icon"] do text result.icon
    div [class "content"] do
      h3 do text result.title
      p [class "preview"] do text result.preview
      span [class "type"] do text result.entityType

def suggestions (items : List SearchResult) : HtmlM Unit := do
  if items.isEmpty then
    pure ()
  else
    ul [class "suggestions"] do
      for item in items do
        li do
          a [href item.url] do
            span [class "icon"] do text item.icon
            text item.title
```

### Layout Integration

Add search box to navbar:

```lean
-- In Layout.lean
nav [class "navbar"] do
  -- ... existing content
  div [class "search-container"] do
    Views.Search.searchBox
```

## Acceptance Criteria

- [ ] Global search box in navbar
- [ ] Search across all implemented sections
- [ ] Results grouped by type with icons
- [ ] Result preview with highlighted matches
- [ ] Click result to navigate to item
- [ ] HTMX autocomplete suggestions
- [ ] Minimum query length (2 chars)
- [ ] User-scoped search (only own data)
- [ ] Performance: results in < 500ms

## Technical Notes

- Start with simple containsSubstr matching
- Consider stemming for better results (future)
- Ledger queries may need optimization for text search
- Cache search results briefly to reduce DB load
- Consider dedicated search index for large datasets

## Priority

Medium - Important for usability as content grows

## Estimate

Medium - Core search + UI integration
