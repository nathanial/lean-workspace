#include <lean/lean.h>
#include <stddef.h>
#include <stdint.h>

#include "assimptor.h"

// Load a 3D asset file
// Returns LoadedAsset structure:
//   { vertices: Array Float, indices: Array UInt32, subMeshes: Array SubMesh, texturePaths: Array String }
// SubMesh structure:
//   { indexOffset: UInt32, indexCount: UInt32, textureIndex: UInt32 }
LEAN_EXPORT lean_obj_res lean_assimptor_asset_load(
    lean_obj_arg file_path_obj,
    lean_obj_arg base_path_obj,
    lean_obj_arg world
) {
    const char* file_path = lean_string_cstr(file_path_obj);
    const char* base_path = lean_string_cstr(base_path_obj);

    float* vertices = NULL;
    uint32_t vertex_count = 0;
    uint32_t* indices = NULL;
    uint32_t index_count = 0;
    uint32_t* submesh_index_offsets = NULL;
    uint32_t* submesh_index_counts = NULL;
    uint32_t* submesh_texture_indices = NULL;
    uint32_t submesh_count = 0;
    char** texture_paths = NULL;
    uint32_t texture_count = 0;

    AssimptorResult result = assimptor_asset_load(
        file_path, base_path,
        &vertices, &vertex_count,
        &indices, &index_count,
        &submesh_index_offsets, &submesh_index_counts, &submesh_texture_indices, &submesh_count,
        &texture_paths, &texture_count
    );

    if (result != ASSIMPTOR_OK) {
        return lean_io_result_mk_error(lean_mk_io_user_error(
            lean_mk_string("Failed to load asset")));
    }

    // Build Lean Arrays

    // 1. vertices: Array Float (12 floats per vertex)
    size_t total_floats = (size_t)vertex_count * 12;
    lean_object* vertices_arr = lean_alloc_array(total_floats, total_floats);
    for (size_t i = 0; i < total_floats; i++) {
        lean_array_set_core(vertices_arr, i, lean_box_float((double)vertices[i]));
    }

    // 2. indices: Array UInt32
    lean_object* indices_arr = lean_alloc_array(index_count, index_count);
    for (uint32_t i = 0; i < index_count; i++) {
        lean_array_set_core(indices_arr, i, lean_box_uint32(indices[i]));
    }

    // 3. subMeshes: Array SubMesh
    // SubMesh has 3 UInt32 fields, which is 12 bytes of scalars (unboxed representation)
    // Layout: offset 0: indexOffset (4 bytes), offset 4: indexCount (4 bytes), offset 8: textureIndex (4 bytes)
    lean_object* submeshes_arr = lean_alloc_array(submesh_count, submesh_count);
    for (uint32_t i = 0; i < submesh_count; i++) {
        // SubMesh with 3 UInt32 = 12 bytes of scalars, 0 object fields
        lean_object* submesh = lean_alloc_ctor(0, 0, 12);
        lean_ctor_set_uint32(submesh, 0, submesh_index_offsets[i]);
        lean_ctor_set_uint32(submesh, 4, submesh_index_counts[i]);
        lean_ctor_set_uint32(submesh, 8, submesh_texture_indices[i]);
        lean_array_set_core(submeshes_arr, i, submesh);
    }

    // 4. texturePaths: Array String
    lean_object* textures_arr = lean_alloc_array(texture_count, texture_count);
    for (uint32_t i = 0; i < texture_count; i++) {
        lean_array_set_core(textures_arr, i, lean_mk_string(texture_paths[i]));
    }

    // Build LoadedAsset structure
    // LoadedAsset has 4 object fields: vertices, indices, subMeshes, texturePaths
    lean_object* asset = lean_alloc_ctor(0, 4, 0);
    lean_ctor_set(asset, 0, vertices_arr);
    lean_ctor_set(asset, 1, indices_arr);
    lean_ctor_set(asset, 2, submeshes_arr);
    lean_ctor_set(asset, 3, textures_arr);

    // Free C memory
    assimptor_asset_free_vertices(vertices);
    assimptor_asset_free_indices(indices);
    assimptor_asset_free_submeshes(submesh_index_offsets, submesh_index_counts, submesh_texture_indices);
    assimptor_asset_free_texture_paths(texture_paths, texture_count);

    return lean_io_result_mk_ok(asset);
}
