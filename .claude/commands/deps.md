# Show Dependencies

Analyze and display the dependency graph for a project.

## Instructions

1. Identify the project from user input: $ARGUMENTS
2. Read the project's `lakefile.lean`
3. Extract all `require` statements
4. For each dependency:
   - Show the dependency name and version tag
   - Identify which tier it belongs to (from CLAUDE.md)
   - Check if it's a local workspace project or external
5. Display the dependency tree

## Dependency Tiers

| Tier | Projects |
|------|----------|
| 0 | crucible, staple, cellar, assimptor, raster |
| 1 | herald, trellis, collimator, protolean, scribe, chronicle, terminus, fugue, linalg, chronos, measures, rune, tincture, wisp, chisel, ledger, quarry, convergent, reactive, tabular, entity, totem, conduit, tracer, smalltalk |
| 2 | citadel, legate, oracle, parlance, arbor, blockfall, twenty48, minefield, solitaire, stencil |
| 3 | loom, afferent, canopy, ask, lighthouse, enchiridion, docgen |
| 4 | todo-app, homebase-app, chroma, vane, worldmap, grove, cairn, afferent-demos |

## External Dependencies

- mathlib (collimator)
- batteries (ledger)
- plausible (chroma, tincture)

## Example Usage

```
/deps afferent
/deps loom
```
