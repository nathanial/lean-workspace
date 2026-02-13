# Render Stream Cutover Plan

## Goal

Replace the current imperative `Output.Execute` command loop with a first-class render stream pipeline where command flow is explicitly modeled, transformable, observable, and replayable.

This cutover is intentionally aggressive: no compatibility shims are required for old entry points.

## Desired End State

1. `RenderCommand` flow is represented as an explicit stream IR (`RenderEvent`).
2. Coalescing and batch planning are stream-stage transforms.
3. FFI and GPU state mutation live only in a sink boundary.
4. Arbor rendering drives the new stream pipeline end-to-end.
5. Trace/timing data is available per stage.

## Architecture

### 1) Stream Layer (`Afferent.Render.Stream`)

Core primitives:

- `RenderEvent`:
  - `frameStart`, `frameEnd`
  - `barrier` (clip/transform/save-restore/explicit flush)
  - `cmd` (draw command)
- `RenderStream := Array RenderEvent`
- `Transducer` abstraction for stateful stream transforms.
- Functional stream combinators (`map`, `filter`, `windowByBarrier`, etc.).
- `Signal` (Arrow-style stateful signal function) for frame-time reactive composition.

Responsibilities:

- Make stream operations explicit and composable.
- Provide conversion between command arrays and stream form.

### 2) Plan Layer (`Afferent.Render.Plan`)

Pipeline stages:

1. **Normalize**: command array -> stream events with barriers.
2. **Coalesce**: flatten + category coalescing + instanced merge within safe scope boundaries.
3. **Batch Plan**: build `DrawPacket` stream (rect/circle batches + fallback command packets).
4. **Trace**: stage-level counts and timings.

Core types:

- `DrawPacket` (backend-ready execution units).
- `RenderTrace`/`StageTrace` for observability.

Properties:

- Planning stages are pure transforms over stream/arrays.
- No FFI or GPU mutation in planning.

### 3) Sink Layer (`Afferent.Render.Sink`)

Responsibilities:

- Execute `DrawPacket` values against `CanvasM`.
- Own reusable FFI buffers and caches.
- Be the only boundary that performs native calls.

### 4) Arbor Integration (`Afferent.Render.Arbor`)

- Existing Arbor measure/layout/collect flow remains.
- Execution path is replaced with stream pipeline invocation.
- Render stats continue to surface batch + collection + execution timing.

## Migration Scope

1. Introduce new `Afferent.Render` module tree.
2. Move execution logic from `Afferent.Output.Execute.*` into stream/plan/sink split.
3. Repoint `Afferent.Output`, `Afferent.UI.Widget`, and backend compatibility modules to `Afferent.Render`.
4. Remove old `Afferent.Output.Execute.*` imports from source/tests.
5. Validate with `just test-project graphics/afferent`.

## Invariants

1. Barrier semantics are preserved.
2. Coalescing does not reorder across barriers.
3. Batch flushes occur before fallback command execution.
4. Sink remains the only layer invoking FFI draw calls.

## Acceptance Criteria

1. All `graphics/afferent` tests pass.
2. `renderArborWidget*` entry points execute through `Afferent.Render` pipeline.
3. Stream stages and packet planning are inspectable via trace data.
4. No runtime code imports `Afferent.Output.Execute.*`.
