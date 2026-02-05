#ifndef ASSIMPTOR_H
#define ASSIMPTOR_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum AssimptorResult {
    ASSIMPTOR_OK = 0,
    ASSIMPTOR_ERROR_INIT_FAILED = 1,
    ASSIMPTOR_ERROR_BUFFER_FAILED = 2
} AssimptorResult;

// Load a 3D asset file (FBX, OBJ supported)
// Returns all mesh data ready for rendering.
// Vertex format: 12 floats per vertex (position[3], normal[3], uv[2], color[4])
// Caller must free returned arrays using assimptor_asset_free_*
AssimptorResult assimptor_asset_load(
    const char* file_path,
    const char* base_path,
    // Output vertex data (12 floats per vertex)
    float** out_vertices,
    uint32_t* out_vertex_count,
    // Output index data
    uint32_t** out_indices,
    uint32_t* out_index_count,
    // Sub-mesh info arrays (all same length = submesh_count)
    uint32_t** out_submesh_index_offsets,
    uint32_t** out_submesh_index_counts,
    uint32_t** out_submesh_texture_indices,
    uint32_t* out_submesh_count,
    // Texture paths (null-terminated strings)
    char*** out_texture_paths,
    uint32_t* out_texture_count
);

// Free asset data
void assimptor_asset_free_vertices(float* vertices);
void assimptor_asset_free_indices(uint32_t* indices);
void assimptor_asset_free_submeshes(
    uint32_t* index_offsets,
    uint32_t* index_counts,
    uint32_t* texture_indices
);
void assimptor_asset_free_texture_paths(char** paths, uint32_t count);

#ifdef __cplusplus
}
#endif

#endif // ASSIMPTOR_H
