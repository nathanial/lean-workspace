# Assimptor

Assimp asset loading wrapper for Lean 4.

Assimptor exposes a single `loadAsset` entry point that returns packed mesh
buffers plus submesh and texture metadata, ready for rendering in Afferent.

## Features

- Assimp-backed model loading (FBX, OBJ, COLLADA, and more)
- Packed vertex layout: position(3), normal(3), uv(2), color(4)
- Submesh metadata for multi-material assets
- Optional texture path extraction

## Requirements

- macOS with clang available (for the Assimp C++ loader)
- Assimp library installed via Homebrew:
  ```bash
  brew install assimp
  ```

## Building

```bash
./build.sh
```

Or directly with lake:
```bash
LEAN_CC=/usr/bin/clang lake build
```

## Usage

```lean
import Assimptor

let asset <- Assimptor.loadAsset
  "assets/fictional-frigate/source/frigateUn1.fbx"
  "assets/fictional-frigate/textures"
```

## License

MIT. See `LICENSE`.
