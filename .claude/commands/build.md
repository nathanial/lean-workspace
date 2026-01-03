# Build Project

Build the specified Lean project using the appropriate method.

## Instructions

1. Identify the project to build from user input: $ARGUMENTS
2. Find the project directory (check all categories: graphics/, web/, network/, data/, apps/, util/, math/, audio/, testing/)
3. Check if this project requires `./build.sh`:
   - **FFI projects**: afferent, afferent-demos, chroma, assimptor, worldmap, vane, grove, cairn, quarry, raster, fugue
   - **gRPC**: legate (run `lake run buildFfi` first, then `./build.sh`)
4. Build using the appropriate method:
   - FFI projects: `cd <category>/<project> && ./build.sh`
   - Standard projects: `cd <category>/<project> && lake build`
5. Report build results clearly

## Example Usage

```
/build terminus
/build afferent
/build loom
```
