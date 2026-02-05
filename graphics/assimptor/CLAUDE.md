# Assimptor

Assimp-based 3D asset loading library for Lean 4.

## Build

Requires Assimp via Homebrew: `brew install assimp`

```bash
./build.sh
```

Or manually: `LEAN_CC=/usr/bin/clang lake build`

## Architecture

Single entry point API for loading 3D models:

```lean
Assimptor.loadAsset (filePath : String) (basePath : String) : IO LoadedAsset
```

**Vertex layout:** 12 floats per vertex - position(3), normal(3), uv(2), color(4)

### Key Types

- `LoadedAsset` - Contains vertices, indices, submeshes, and texture paths
- `SubMesh` - Offset/count into index buffer plus texture reference

### Native Code

- `native/src/common/assimp_loader.cpp` - C++ Assimp integration
- `native/src/lean_bridge.c` - FFI bridge to Lean

## Supported Formats

FBX, OBJ, COLLADA, and other Assimp-supported formats.
