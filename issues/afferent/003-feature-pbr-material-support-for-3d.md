# PBR Material Support for 3D

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** Shader modifications, additional texture slots

## Description
Extend the 3D asset loading pipeline to support full PBR (Physically Based Rendering) materials including normal maps, metallic, and roughness textures. The LoadedAsset structure notes this as a future enhancement.

## Rationale
Modern 3D content uses PBR workflows. The current system only loads diffuse textures.

## Affected Files
- `Assimptor/Asset.lean` (SubMesh structure, loadAsset function - lines 44-47)
- `native/src/metal/` (shader updates for PBR)
