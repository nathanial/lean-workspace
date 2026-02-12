# Text Instanced Rendering Plan (Fast Track)

## Objective
Replace the current text mesh path with instanced glyph rendering plus retained GPU buffers so unchanged text does not regenerate or re-upload geometry each frame.

## Hard Requirements
- No per-frame text vertex/index mesh generation.
- No per-frame float-to-`TextVertex` expansion pass.
- No per-frame static glyph buffer uploads for unchanged runs.
- Remove mesh text rendering path entirely.

## Execution Strategy
Implement end-to-end in one push, then optimize hotspots. Do not block on telemetry work.

## Implementation Order

### 1) New Instanced Text Pipeline (Immediate)
- Add instanced text shader path (`vertex_id` + `instance_id`) using a unit quad.
- Add pipeline creation for instanced text in Metal pipeline setup.
- Define packed structs for:
  - glyph static instance data
  - per-run dynamic data
  - text uniforms

Files:
- `graphics/afferent/native/src/metal/shaders/text.metal` (or new `text_instanced.metal`)
- `graphics/afferent/native/src/metal/pipeline.m`
- `graphics/afferent/native/src/metal/types.h`

### 2) Replace Draw Path With Instanced Rendering
- Rework text draw in `draw_text.m` to:
  - issue instanced draw calls (`drawPrimitives`, `vertexCount=4`, `instanceCount=glyphCount`)
  - upload instance buffers only (no CPU mesh/index path)
- Delete mesh text draw path and route all text rendering through instanced path.

Files:
- `graphics/afferent/native/src/metal/draw_text.m`

### 3) Retained Static Glyph Buffers (Core Win)
- Add native run cache keyed by:
  - font handle/id
  - string hash
  - atlas version
- Cache contents:
  - GPU static instance buffer
  - glyph count
- Frame behavior:
  - unchanged runs: reuse static buffer, upload only dynamic run data
  - changed runs: rebuild once, then retain
- Invalidate on atlas resize/font/text change.

Files:
- `graphics/afferent/native/src/common/text_render.c`
- `graphics/afferent/native/src/metal/draw_text.m`

### 4) Dirty-Run Dynamic Updates
- Update only dynamic data for runs that changed transform/color.
- Avoid rewriting full dynamic buffer when only a subset animates.

Files:
- `graphics/afferent/native/src/metal/draw_text.m`
- `graphics/afferent/src/Afferent/Output/Execute/Batches.lean` (if payload shaping is needed)

### 5) Cleanup and Removal
- Remove any remaining mesh-text code, structs, and dead APIs.
- Keep codebase single-path for text rendering.

## Cache Design (Minimal, Aggressive)
- Use byte-budget LRU from day one.
- Evict oldest run buffers when over budget.
- Default budget sized for 2k-label and 20k-widget stress scenes.

## Acceptance Criteria
- Visual parity across demos.
- Perf tab 2k labels:
  - `ffi` materially lower than current baseline.
  - `exec` materially lower than current baseline.
- Stable scenes: near-zero static text uploads after warmup.

## Validation (Only What Matters)
- Build:
  - `graphics/afferent-demos/build.sh afferent_demos`
- Tests:
  - `just test-project graphics/afferent`
- Manual:
  - Perf tab (2k labels)
  - Animated subset + static majority
  - Atlas growth/regression check

## Risk Controls
- Atlas-version invalidation is mandatory.
- Struct packing must match shader exactly.

## Optional After Landing
- Add deeper timing breakdown for static upload/dynamic upload/encode.
- Tune cache budget with real traces.
