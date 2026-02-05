# Roadmap

This document outlines potential improvements, new features, and code cleanup opportunities for the Assimptor library.

## Feature Proposals

### [Priority: High] PBR Material Support

**Description:** Extend the asset loading to extract full PBR (Physically Based Rendering) material properties including normal maps, metallic, roughness, ambient occlusion, and emissive textures.

**Rationale:** The current implementation only extracts diffuse textures. Modern rendering pipelines require full PBR material data for realistic rendering. The code already contains a comment noting this limitation (Asset.lean lines 40-45).

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/Assimptor/Asset.lean` - Add new fields to SubMesh
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/common/assimp_loader.cpp` - Extract additional texture types
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/include/assimptor.h` - Extend C API
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/lean_bridge.c` - Bridge new data

**Estimated Effort:** Medium

**Implementation Notes:**
- Extract from Assimp: `aiTextureType_NORMALS`, `aiTextureType_METALNESS`, `aiTextureType_DIFFUSE_ROUGHNESS`, `aiTextureType_AMBIENT_OCCLUSION`, `aiTextureType_EMISSIVE`
- Add to SubMesh: `normalMapIndex`, `metallicIndex`, `roughnessIndex`, `aoIndex`, `emissiveIndex`
- Consider a separate `Material` structure for cleaner organization

---

### [Priority: High] Error Reporting with Details

**Description:** Provide detailed error messages from Assimp instead of generic "Failed to load asset" errors.

**Rationale:** Currently, when asset loading fails, the user receives no information about why (file not found, unsupported format, corrupted file, etc.). Assimp provides detailed error messages via `importer.GetErrorString()` that should be exposed to the Lean caller.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/include/assimptor.h` - Add error string output parameter
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/common/assimp_loader.cpp` - Capture and return error messages
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/lean_bridge.c` - Pass error string to Lean

**Estimated Effort:** Small

---

### [Priority: Medium] Animation Data Loading

**Description:** Extract skeletal animation data (bones, keyframes, animation clips) from model files.

**Rationale:** Many 3D model formats (FBX, COLLADA, glTF) contain animation data that would be valuable for game and visualization applications. Assimp fully supports animation extraction.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/Assimptor/Asset.lean` - Add Animation, Bone, Keyframe structures
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/common/assimp_loader.cpp` - Extract animation data
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/include/assimptor.h` - Extend C API
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/lean_bridge.c` - Bridge animation data

**Estimated Effort:** Large

**Implementation Notes:**
- Add `BoneWeight` structure with bone index and weight
- Add per-vertex bone data (typically 4 bones per vertex)
- Add `Animation` structure with name, duration, keyframes
- Consider a separate `loadAssetWithAnimations` function to avoid overhead for static meshes

---

### [Priority: Medium] Scene Hierarchy Preservation

**Description:** Expose the scene graph hierarchy with node transforms, allowing proper handling of multi-part models with spatial relationships.

**Rationale:** Currently, `collectMeshes` flattens the scene graph and discards transform information. Some models rely on node transforms for proper assembly (e.g., vehicle parts, articulated objects).

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/Assimptor/Asset.lean` - Add SceneNode structure with transform
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/common/assimp_loader.cpp` - Preserve node hierarchy and transforms
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/include/assimptor.h` - Add scene graph API
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/lean_bridge.c` - Bridge scene graph

**Estimated Effort:** Medium

---

### [Priority: Medium] Tangent and Bitangent Export

**Description:** Include tangent and bitangent vectors in the vertex format for normal mapping support.

**Rationale:** The C++ code already requests `aiProcess_CalcTangentSpace` but does not export the computed tangent/bitangent data. These are essential for proper normal map rendering.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/Assimptor/Asset.lean` - Update vertex format documentation
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/common/assimp_loader.cpp` - Export tangent/bitangent (lines 148-189)

**Estimated Effort:** Small

**Implementation Notes:**
- Expand vertex format from 12 to 18 floats: position(3) + normal(3) + tangent(3) + bitangent(3) + uv(2) + color(4)
- Or provide a separate loading mode to avoid overhead for non-normal-mapped models

---

### [Priority: Medium] glTF 2.0 Optimized Path

**Description:** Add a specialized loader for glTF 2.0 format with direct PBR material extraction.

**Rationale:** glTF is becoming the "JPEG of 3D" and has first-class PBR support. Assimp's glTF import already handles PBR properties natively, making extraction more straightforward than FBX/OBJ.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/Assimptor/Asset.lean` - Add glTF-specific material structure
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/common/assimp_loader.cpp` - Add format detection and optimized glTF path

**Estimated Effort:** Medium

---

### [Priority: Low] Embedded Texture Extraction

**Description:** Support extraction of textures embedded within the model file (common in FBX and glTF binary formats).

**Rationale:** Some model files contain embedded textures rather than external file references. Currently these are not accessible.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/Assimptor/Asset.lean` - Add embedded texture data structure
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/common/assimp_loader.cpp` - Extract embedded textures via `aiScene->mTextures`

**Estimated Effort:** Medium

---

### [Priority: Low] Async/Streaming Loading

**Description:** Support asynchronous loading and streaming of large model files.

**Rationale:** Large models can take significant time to load, blocking the main thread. An async loading API would improve user experience.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/Assimptor/Asset.lean` - Add async loading API
- New file: Progress callback mechanism

**Estimated Effort:** Large

**Dependencies:** Lean's async/IO task system

---

### [Priority: Low] Bounding Box Calculation

**Description:** Compute and return axis-aligned bounding boxes (AABB) for the loaded asset and each submesh.

**Rationale:** Bounding boxes are essential for frustum culling, physics, and spatial queries. Computing them during load is more efficient than recalculating later.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/Assimptor/Asset.lean` - Add AABB structure
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/common/assimp_loader.cpp` - Compute bounds during mesh processing

**Estimated Effort:** Small

---

## Code Improvements

### [Priority: High] Add Test Suite

**Current State:** The project has no tests. It is listed in CLAUDE.md as "Projects without a test target".

**Proposed Change:** Create a test suite using the Crucible framework to verify loading of various model formats and edge cases.

**Benefits:** Ensures correctness, catches regressions, validates format support.

**Affected Files:**
- New file: `/Users/Shared/Projects/lean-workspace/graphics/assimptor/AssimptorTests.lean`
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/lakefile.lean` - Add test target
- New directory: `/Users/Shared/Projects/lean-workspace/graphics/assimptor/testdata/` - Sample models

**Estimated Effort:** Medium

---

### [Priority: High] Linux Support

**Current State:** The lakefile.lean and build.sh are macOS-specific with hardcoded Homebrew paths (`/opt/homebrew/lib`, `/usr/local/lib`).

**Proposed Change:** Add conditional compilation and platform detection for Linux support.

**Benefits:** Expands platform support beyond macOS.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/lakefile.lean` - Add platform detection
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/build.sh` - Handle Linux paths

**Estimated Effort:** Small

**Implementation Notes:**
- Use `System.Platform.isLinux` in lakefile
- Add typical Linux lib paths (`/usr/lib`, `/usr/local/lib`)
- Consider pkg-config integration for portable library discovery

---

### [Priority: Medium] Memory Efficiency for Large Models

**Current State:** Vertex data is stored as `Array Float` which boxes each float value. For large models with millions of vertices, this creates significant memory overhead.

**Proposed Change:** Use `FloatArray` or `ByteArray` for more compact vertex storage.

**Benefits:** Reduced memory usage, better cache locality, faster data transfer to GPU.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/Assimptor/Asset.lean` - Change `vertices : Array Float` to `FloatArray`
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/lean_bridge.c` - Update array construction

**Estimated Effort:** Small

---

### [Priority: Medium] Configurable Post-Processing Flags

**Current State:** Post-processing flags are hardcoded in the C++ loader (triangulation, normal generation, UV flip, etc.).

**Proposed Change:** Allow the caller to specify which Assimp post-processing steps to apply.

**Benefits:** Flexibility for different use cases (e.g., skip UV flip for some formats, control optimization level).

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/Assimptor/Asset.lean` - Add `LoadOptions` structure
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/include/assimptor.h` - Add flags parameter
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/common/assimp_loader.cpp` - Accept flags parameter

**Estimated Effort:** Small

---

### [Priority: Medium] Vendored Assimp Build Option

**Current State:** Requires system-installed Assimp via Homebrew. The .gitignore suggests there was once a local build (`assimp/build/`).

**Proposed Change:** Add option to build Assimp from source (like other projects in this workspace do with their dependencies).

**Benefits:** No system dependency required, reproducible builds, version control.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/build.sh` - Add Assimp download and build
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/lakefile.lean` - Link vendored build

**Estimated Effort:** Medium

---

### [Priority: Low] Separate FFI Module Structure

**Current State:** All FFI code is in a single `lean_bridge.c` file.

**Proposed Change:** Split into separate modules following the pattern of other workspace projects.

**Benefits:** Better organization, easier maintenance as the API grows.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/lean_bridge.c` - Split into multiple files
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/lakefile.lean` - Update build targets

**Estimated Effort:** Small

---

### [Priority: Low] Resource Handle Pattern for Large Assets

**Current State:** `loadAsset` returns a fully materialized `LoadedAsset` with all data copied to Lean arrays.

**Proposed Change:** Consider an opaque handle pattern where data stays on the native side until explicitly requested.

**Benefits:** Lower memory usage when only portions of model data are needed.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/Assimptor/Asset.lean` - Add handle-based API
- `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/lean_bridge.c` - Manage native handles

**Estimated Effort:** Medium

**Dependencies:** Requires careful lifecycle management

---

## Code Cleanup

### [Priority: Medium] Add Crucible Dependency for Future Tests

**Issue:** The lakefile.lean has no dependencies, but tests will need the crucible framework.

**Location:** `/Users/Shared/Projects/lean-workspace/graphics/assimptor/lakefile.lean`

**Action Required:** Add `require crucible from git` dependency in preparation for test suite.

**Estimated Effort:** Small

---

### [Priority: Low] Update README with Full API Documentation

**Issue:** The README is minimal and does not document the `LoadedAsset` or `SubMesh` structures.

**Location:** `/Users/Shared/Projects/lean-workspace/graphics/assimptor/README.md`

**Action Required:**
- Document `LoadedAsset` structure and field meanings
- Document `SubMesh` structure
- Add examples for accessing submesh data
- Document vertex format in detail
- Add troubleshooting section for common Assimp errors

**Estimated Effort:** Small

---

### [Priority: Low] Add CHANGELOG.md

**Issue:** No changelog to track version history and breaking changes.

**Location:** New file: `/Users/Shared/Projects/lean-workspace/graphics/assimptor/CHANGELOG.md`

**Action Required:** Create changelog documenting the current v0.0.1 release and future changes.

**Estimated Effort:** Small

---

### [Priority: Low] Missing Null Check on Texture Path Array Allocation

**Issue:** The code checks `if (texturePaths.empty())` but does not check if malloc for `out_texture_paths` fails when there are textures.

**Location:** `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/src/common/assimp_loader.cpp` lines 213-220

**Action Required:** Add null check after malloc for texture paths array.

**Estimated Effort:** Small

---

### [Priority: Low] Consider Separate Error Codes

**Issue:** Only three error codes exist: `ASSIMPTOR_OK`, `ASSIMPTOR_ERROR_INIT_FAILED`, `ASSIMPTOR_ERROR_BUFFER_FAILED`. More granular errors would help debugging.

**Location:** `/Users/Shared/Projects/lean-workspace/graphics/assimptor/native/include/assimptor.h` lines 10-14

**Action Required:** Add error codes for: file not found, unsupported format, empty scene, invalid mesh data.

**Estimated Effort:** Small

---

### [Priority: Low] Remove Unused `.gitignore` Entry

**Issue:** The `.gitignore` has `/build/` and `assimp/build/` entries that reference directories not present in the current structure. Lake uses `.lake/` for build artifacts.

**Location:** `/Users/Shared/Projects/lean-workspace/graphics/assimptor/.gitignore`

**Action Required:** Review and clean up stale gitignore entries.

**Estimated Effort:** Small

---

## Architecture Considerations

### Module Organization

The current single-file structure (`Assimptor/Asset.lean`) is appropriate for the current scope. As features are added (animations, scene hierarchy, materials), consider organizing into:

```
Assimptor/
  Asset.lean       -- Main LoadedAsset type
  SubMesh.lean     -- SubMesh type
  Material.lean    -- PBR material structures
  Animation.lean   -- Animation and bone data
  Scene.lean       -- Scene hierarchy types
  Options.lean     -- Loading options/flags
  Error.lean       -- Error types
```

### Integration with Afferent

The library is designed for use with the `afferent` graphics framework. Consider:
- Consistent coordinate system conventions
- Direct GPU buffer upload utilities
- Integration examples in the afferent demo code

### Dependency on System Libraries

The current approach requires Homebrew-installed Assimp. For maximum portability, the workspace pattern of vendoring dependencies (as seen in `quarry` with SQLite, `raster` with stb) would be ideal but is more complex for Assimp due to its size and build complexity.
