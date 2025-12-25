# Implement Recipes Section

## Summary

The Recipes section is currently a placeholder stub. Implement a recipe management feature for storing, organizing, and searching personal recipes.

## Current State

- Route exists: `GET /recipes`
- Action: `Recipes.index` only checks login and renders placeholder
- View: Shows "Recipes - Coming soon!" with emoji
- No data model defined

## Requirements

### Data Model (Models.lean)

```lean
-- Recipe attributes
def recipeTitle : LedgerAttribute := ...
def recipeDescription : LedgerAttribute := ...
def recipeIngredients : LedgerAttribute := ...  -- cardinality many
def recipeInstructions : LedgerAttribute := ...
def recipeServings : LedgerAttribute := ...
def recipePrepTime : LedgerAttribute := ...     -- minutes
def recipeCookTime : LedgerAttribute := ...     -- minutes
def recipeTags : LedgerAttribute := ...         -- cardinality many
def recipeSource : LedgerAttribute := ...       -- URL or book reference
def recipeImage : LedgerAttribute := ...        -- filename (future)

structure DbRecipe where
  id : Nat
  title : String
  description : String
  ingredients : List String
  instructions : String
  servings : Nat
  prepTime : Nat
  cookTime : Nat
  tags : List String
  source : String
  deriving Repr, BEq
```

### Routes to Add

```
GET  /recipes                     → List all recipes
GET  /recipes/new                 → New recipe form
POST /recipes/recipe              → Create recipe
GET  /recipes/recipe/:id          → View recipe
GET  /recipes/recipe/:id/edit     → Edit recipe form
PUT  /recipes/recipe/:id          → Update recipe
DELETE /recipes/recipe/:id        → Delete recipe
GET  /recipes/tag/:tag            → Recipes by tag
GET  /recipes/search?q=           → Search recipes
GET  /recipes/random              → Random recipe picker
```

### Actions (Actions/Recipes.lean)

- `index`: Grid/list view of all recipes
- `newRecipe`: Show recipe creation form
- `createRecipe`: Create new recipe
- `showRecipe`: Display full recipe
- `editRecipe`: Show edit form
- `updateRecipe`: Update recipe
- `deleteRecipe`: Delete with confirmation
- `byTag`: Filter recipes by tag
- `search`: Search by title, ingredients, tags
- `randomRecipe`: Pick a random recipe

### Views (Views/Recipes.lean)

- Recipe grid with title and tags
- Recipe card component
- Full recipe view:
  - Title and description
  - Prep/cook time badges
  - Servings with scale adjustment
  - Ingredients list (checkable)
  - Instructions (numbered steps)
  - Tags
  - Source link
- Recipe form with:
  - Title, description
  - Dynamic ingredient list (add/remove)
  - Instructions textarea
  - Time inputs
  - Tag input with suggestions
- Tag filter sidebar
- Search results

### Features

- Ingredient list with checkboxes (for shopping)
- Servings scaler (multiply/divide ingredients)
- Print-friendly view
- Recipe tags: breakfast, lunch, dinner, dessert, snack, quick, healthy, etc.

## Acceptance Criteria

- [ ] User can create, edit, and delete recipes
- [ ] Recipes have title, description, ingredients, instructions, times, tags
- [ ] Dynamic ingredient list in form (add/remove items)
- [ ] Checkable ingredients for cooking
- [ ] Tag filtering and search
- [ ] Random recipe picker for meal planning
- [ ] Print-friendly recipe view
- [ ] HTMX for smooth interactions
- [ ] Audit logging for recipe operations

## Technical Notes

- Ingredients stored as List String for simplicity
- Consider structured ingredients (amount, unit, item) later
- Instructions as Markdown for formatting
- Image support deferred to file upload issue

## Priority

Medium - Nice organizational feature

## Estimate

Medium - Standard CRUD + search
