# Afferent Layered Architecture

> Status: current (post-RenderCommand removal).
> `RenderCommand`/`collectCommands`/`Execute.Interpreter` are no longer part of the runtime architecture.

Canonical layer roots:

- `Afferent.Runner` (`src/Afferent/Runner/*`)
- `Afferent.Widget` (`src/Afferent/Widget/*`)
- `Afferent.Draw` (`src/Afferent/Draw/*`)
- `Afferent.Output` (`src/Afferent/Output/*`)

## Folder structure (canonical)

```text
graphics/afferent/src/Afferent/
  Runner/
    Loop.lean
  Runner.lean

  Widget/
    Core.lean
    Canopy.lean
  Widget.lean

  Draw/
    Types.lean
    Builder.lean
  Draw.lean

  Output/
    Canvas.lean
    FFI.lean
    Execute/
      Render.lean
    Execute.lean
  Output.lean
```

## Dependency direction (enforced by convention)

Allowed:

- `Runner -> Widget, Draw, Output`
- `Widget -> Draw`
- `Output -> Draw`
- `Draw -> Core types/geometry + CanvasM-facing helpers`

Disallowed:

- `Draw -> Output`
- `Draw -> Runner`
- `Widget -> Runner`
- `Output -> Runner`

## Layer responsibilities

1. Runner
- Owns frame loop orchestration, input polling, event dispatch, and app model update.

2. Widget
- Owns widget model, measure/layout preparation, event model, and Canopy composition.

3. Draw
- Owns shared draw datatypes (`TextAlign`, `MeshInstance`, etc.) and immediate drawing DSL (`RenderM`).

4. Output
- Owns concrete widget traversal and Canvas/FFI execution (`renderMeasuredArborWidget` / `renderArborWidget`).

## Runtime ownership

- Runtime rendering traverses measured/layouted widget trees directly.
- `Canvas` does not own render-command cache state (no command cache path exists).

## Frame-flow contract (single measurement pass)

Runner computes measure/layout once per frame, then:

- uses that same layout for event dispatch
- uses that same measured widget/layout for rendering (`renderMeasuredArborWidget`)

This avoids duplicate measure/layout work in the same frame.
