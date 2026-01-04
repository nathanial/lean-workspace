# Shader Consolidation Plan (Afferent)

## Goals
- Reduce shader count by merging overlapping pipelines without losing features.
- Keep the API general-purpose (not demo-specific).
- Preserve performance (streaming instanced buffers, no boxed-array paths on hot loops).
- Minimize churn by introducing compatibility wrappers during migration.

## Phase 0 — Inventory + Guardrails (prep)
**Why:** Avoid accidental feature loss and make migrations mechanical.
- Produce a short “shader feature matrix” mapping current shaders to:
  - Geometry type (rect/tri/circle/mesh)
  - Color mode (RGBA/HSV)
  - Texturing (none/sprite/tile)
  - Coordinate space (screen/world)
  - Animation source (CPU/GPU)
- Define 2–3 public “core” shader families we want to end with.
- Add a small set of render smoke tests for:
  - Instanced shapes (rect/tri/circle)
  - Textured quads
  - 3D mesh (textured + untextured)
  - Strokes (path + extruded)

### Shader Feature Matrix (current)
| Shader | Geometry | Color | Texturing | Coord space | Animation |
| --- | --- | --- | --- | --- | --- |
| `basic` | 2D triangles (arbitrary) | RGBA per-vertex | none | NDC | none |
| `text` | 2D quads | RGBA × atlas alpha | font atlas | NDC | none |
| `instanced` | rect/tri/circle | RGBA or HSV(time) | none | world (matrix) or screen | CPU (angle/size) + GPU hue |
| `animated` | rect/tri/circle | HSV(time) | none | screen | GPU spin + hue |
| `orbital` | rect quad | HSV(time) | none | screen | GPU orbit + hue |
| `sprite` | textured quad | texture × alpha | full texture | screen | CPU rotation |
| `textured_rect` | textured quad | texture × alpha | UV sub-rect | screen | none |
| `stroke` | extruded stroke tris | uniform RGBA | none | screen | none |
| `stroke_path` | GPU-extruded stroke | uniform RGBA | none | screen | none |
| `mesh3d` | 3D mesh + ocean | vertex RGBA | none | world/clip | GPU waves (ocean path) |
| `mesh3d_textured` | 3D mesh | texture × vertex RGBA | diffuse tex | world/clip | none |

### Core Shader Families (target)
- **2D Untextured:** `instanced` + `basic`
- **2D Textured:** unified textured instanced + `text`
- **2D Stroke:** `stroke` + `stroke_path`
- **3D Mesh:** unified `mesh3d` (textured + untextured)

**Exit criteria:** Matrix exists, core families listed, smoke tests pass.

---

## Phase 1 — Unify 2D Textured Quads (sprite + textured_rect)
**Target:** Replace `sprite.metal` + `textured_rect.metal` with a single, general shader.
**Status:** Completed (unified shader file with specialized layout0/layout1 pipelines).

**Plan:**
1. Create `textured_instanced.metal` (or extend `sprite.metal`) with:
   - Per-instance: `pos`, `rotation`, `size`, `uvRect`, `alpha`
   - Uniforms: `u_viewport`, optional `u_matrix` (match instanced path)
2. Update native pipeline creation to build one textured-quad pipeline.
3. Add FFI draw calls:
   - `drawTexturedInstancedBuffer` (FloatBuffer path)
   - Keep thin wrappers:
     - `drawSprites*` maps to textured instanced with full UV rect
     - `drawTexturedRect` maps to textured instanced with 1 instance and UV sub-rect
4. Deprecate old shader files and remove old pipelines.

**Exit criteria:** Sprite + textured-rect demos still render correctly using the new pipeline. ✅

---

## Phase 2 — Unify 3D Shaders (mesh3d + mesh3d_textured)
**Target:** Single mesh shader with optional texture sampling.

**Plan:**
1. Merge `mesh3d.metal` and `mesh3d_textured.metal` into `mesh3d.metal`:
   - Add `useTexture` flag in uniforms.
   - When `useTexture == 0`, use vertex color/material only.
2. Update pipeline creation to compile one 3D shader pair.
3. Update FFI to pass `useTexture` and bind texture/sampler only when needed.
4. Keep existing `drawMesh3D*` API but route both to the unified pipeline.

**Exit criteria:** All 3D demos/tests render identically; no shader duplication remains.

---

## Phase 3 — Fold Animated/Orbital into Instanced (or move to demos)
**Target:** Remove `animated.metal` and `orbital.metal` as separate shaders.

**Option A (recommended): integrate into instanced shader**
- Add optional “motion parameters” per instance:
  - `phase`, `spinSpeed`, `orbitParams` (center offset, radius, angular speed)
- Add `motionMode` uniform:
  - `0 = none`, `1 = spin`, `2 = orbit`
- Keep the fast buffer streaming path as primary; GPU motion is optional and general-purpose.

**Option B:** move to demos
- Rebuild orbital/animated demos on top of instanced + CPU updates.
- Remove shader + pipeline + FFI for orbital/animated entirely.

**Exit criteria:** Either path removes two shader files and their pipelines, while preserving demo functionality.

---

## Phase 4 — Cleanup & API Consolidation
- Remove deprecated shader source registrations and pipeline states.
- Delete old FFI entry points and update docs.
- Ensure `Afferent.Shaders` and native shader registration list only core shaders.
- Confirm all demos still compile and run.

**Exit criteria:** Shader list is minimal, APIs are stable, demos still work.

---

## Proposed End-State Shader Set
**2D**
- `instanced.metal` (rect/tri/circle, world/screen sizing, RGBA/HSV)
- `textured_instanced.metal` (sprites, tiles, UI images)
- `stroke.metal` and `stroke_path.metal` (two input formats)
- `text.metal`
**3D**
- `mesh3d.metal` (textured + untextured)

---

## Risks / Mitigations
- **Risk:** Feature parity regressions (UV rects, rotation, alpha, AA).
  - **Mitigation:** Keep old FFI wrappers while migrating; use visual tests.
- **Risk:** API churn.
  - **Mitigation:** Introduce new APIs alongside old ones, then deprecate in docs.
- **Risk:** Performance regressions.
  - **Mitigation:** Ensure FloatBuffer path remains the default fast path.

---

## Suggested Execution Order
1. Phase 1 (textured 2D) — biggest duplication with clear unification.
2. Phase 2 (3D merge) — low-risk, straightforward.
3. Phase 3 (animated/orbital) — choose Option A or B based on desired feature set.
4. Phase 4 cleanup.
