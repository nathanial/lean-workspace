# Rebuild Project

Clean and rebuild the specified Lean project from scratch.

## Instructions

1. Identify the project to rebuild from user input: $ARGUMENTS
2. Find the project directory (check all categories: graphics/, web/, network/, data/, apps/, util/, math/, audio/, testing/)
3. Clean the project: `cd <category>/<project> && lake clean`
4. Rebuild using the appropriate method:
   - **FFI projects** (afferent, afferent-demos, chroma, assimptor, worldmap, vane, grove, cairn, quarry, raster, fugue, legate): `./build.sh`
   - **Standard projects**: `lake build`
5. Report build results

## Example Usage

```
/rebuild terminus
/rebuild afferent
```
