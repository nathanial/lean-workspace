# Afferent Layered Architecture

Canonical layer roots:

- `Afferent.Runner` (`src/Afferent/Runner/*`)
- `Afferent.Widget` (`src/Afferent/Widget/*`)
- `Afferent.Draw` (`src/Afferent/Draw/*`)
- `Afferent.Output` (`src/Afferent/Output/*`)

## Folder structure (canonical + compatibility)

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
    Command.lean
    Builder.lean
    Cache.lean
    Collect.lean
    Optimize/
      Coalesce.lean
    Optimize.lean
    Runtime.lean
  Draw.lean

  Output/
    Canvas.lean
    FFI.lean
    Execute/
      Interpreter.lean
      Batches.lean
      Batched.lean
      Render.lean
      Coalesce.lean
    Execute.lean
  Output.lean

  -- compatibility facades (legacy import paths only)
  App/UIRunner.lean
  UI/Arbor/Render/*.lean
  UI/Widget/Backend*.lean
```

Compatibility modules remain under:

- `Afferent.App.UIRunner`
- `Afferent.UI.Arbor.Render.*`
- `Afferent.UI.Widget.Backend.*`

These files are pass-through facades only. No new implementation should be added there.

## Dependency direction (enforced by convention)

Allowed:

- `Runner -> Widget, Draw, Output`
- `Widget -> Draw`
- `Output -> Draw`
- `Draw -> Core types/geometry only`

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
- Owns backend-agnostic render command IR (`RenderCommand`), command collection, and optimization.

4. Output
- Owns concrete canvas/FFI execution of draw commands to the renderer.

## Runtime ownership

- Render command collection is stateless; there is no `Afferent.Draw.Runtime`.
- `Canvas` does not own render-command cache state.

## Frame-flow contract (single measurement pass)

Runner computes measure/layout once per frame, then:

- uses that same layout for event dispatch
- uses that same measured widget/layout for rendering (`renderMeasuredArborWidget`)

This avoids duplicate measure/layout work in the same frame.
