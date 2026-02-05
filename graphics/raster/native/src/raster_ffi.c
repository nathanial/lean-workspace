/*
 * Raster FFI Implementation
 * C bindings for stb_image, stb_image_write, stb_image_resize2
 */

#include <lean/lean.h>
#include <string.h>
#include <stdlib.h>

/* stb implementations (single-file libraries) */
#define STB_IMAGE_IMPLEMENTATION
#define STBI_NO_HDR  /* Disable HDR to avoid __isoc23_strtol glibc symbol */
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#define STB_IMAGE_RESIZE2_IMPLEMENTATION
#include "stb_image_resize2.h"

/* ========================================================================== */
/* Helper Functions                                                            */
/* ========================================================================== */

static lean_object* mk_io_error(const char* msg) {
    return lean_io_result_mk_error(lean_mk_io_user_error(lean_mk_string(msg)));
}

/* Build tuple (ByteArray, UInt32, UInt32, UInt32) for load results */
static lean_object* mk_load_result(unsigned char* data, int width, int height, int channels) {
    size_t size = (size_t)width * height * channels;

    /* Create ByteArray and copy data */
    lean_object* arr = lean_alloc_sarray(1, size, size);
    memcpy(lean_sarray_cptr(arr), data, size);

    /* Free stb-allocated data */
    stbi_image_free(data);

    /* Build nested tuple: (arr, (width, (height, channels))) */
    lean_object* inner2 = lean_alloc_ctor(0, 2, 0);
    lean_ctor_set(inner2, 0, lean_box_uint32((uint32_t)height));
    lean_ctor_set(inner2, 1, lean_box_uint32((uint32_t)channels));

    lean_object* inner1 = lean_alloc_ctor(0, 2, 0);
    lean_ctor_set(inner1, 0, lean_box_uint32((uint32_t)width));
    lean_ctor_set(inner1, 1, inner2);

    lean_object* result = lean_alloc_ctor(0, 2, 0);
    lean_ctor_set(result, 0, arr);
    lean_ctor_set(result, 1, inner1);

    return result;
}

/* Build tuple (UInt32, UInt32, UInt32) for info results */
static lean_object* mk_info_result(int width, int height, int channels) {
    /* Build tuple (width, (height, channels)) */
    lean_object* inner = lean_alloc_ctor(0, 2, 0);
    lean_ctor_set(inner, 0, lean_box_uint32((uint32_t)height));
    lean_ctor_set(inner, 1, lean_box_uint32((uint32_t)channels));

    lean_object* result = lean_alloc_ctor(0, 2, 0);
    lean_ctor_set(result, 0, lean_box_uint32((uint32_t)width));
    lean_ctor_set(result, 1, inner);

    return result;
}

/* ========================================================================== */
/* Load Operations                                                             */
/* ========================================================================== */

LEAN_EXPORT lean_obj_res raster_load_from_file(
    b_lean_obj_arg path_obj,
    uint8_t requested_channels,
    lean_obj_arg world
) {
    const char* path = lean_string_cstr(path_obj);
    int width, height, channels;

    unsigned char* data = stbi_load(path, &width, &height, &channels,
                                     requested_channels > 0 ? requested_channels : 0);
    if (!data) {
        char msg[512];
        snprintf(msg, sizeof(msg), "Failed to load '%s': %s", path, stbi_failure_reason());
        return mk_io_error(msg);
    }

    int actual_channels = requested_channels > 0 ? requested_channels : channels;
    lean_object* result = mk_load_result(data, width, height, actual_channels);
    return lean_io_result_mk_ok(result);
}

LEAN_EXPORT lean_obj_res raster_load_from_memory(
    b_lean_obj_arg buffer_obj,
    uint8_t requested_channels,
    lean_obj_arg world
) {
    size_t size = lean_sarray_size(buffer_obj);
    const unsigned char* buffer = lean_sarray_cptr(buffer_obj);
    int width, height, channels;

    unsigned char* data = stbi_load_from_memory(buffer, (int)size,
                                                 &width, &height, &channels,
                                                 requested_channels > 0 ? requested_channels : 0);
    if (!data) {
        return mk_io_error(stbi_failure_reason());
    }

    int actual_channels = requested_channels > 0 ? requested_channels : channels;
    lean_object* result = mk_load_result(data, width, height, actual_channels);
    return lean_io_result_mk_ok(result);
}

LEAN_EXPORT lean_obj_res raster_info_from_file(
    b_lean_obj_arg path_obj,
    lean_obj_arg world
) {
    const char* path = lean_string_cstr(path_obj);
    int width, height, channels;

    if (!stbi_info(path, &width, &height, &channels)) {
        char msg[512];
        snprintf(msg, sizeof(msg), "Failed to get info for '%s': %s", path, stbi_failure_reason());
        return mk_io_error(msg);
    }

    lean_object* result = mk_info_result(width, height, channels);
    return lean_io_result_mk_ok(result);
}

/* ========================================================================== */
/* Write Operations                                                            */
/* ========================================================================== */

LEAN_EXPORT lean_obj_res raster_write_png(
    b_lean_obj_arg path_obj,
    uint32_t width, uint32_t height, uint32_t channels,
    b_lean_obj_arg data_obj,
    lean_obj_arg world
) {
    const char* path = lean_string_cstr(path_obj);
    const unsigned char* data = lean_sarray_cptr(data_obj);
    int stride = (int)(width * channels);

    int result = stbi_write_png(path, (int)width, (int)height, (int)channels, data, stride);
    if (!result) {
        return mk_io_error("Failed to write PNG");
    }
    return lean_io_result_mk_ok(lean_box(0));
}

LEAN_EXPORT lean_obj_res raster_write_jpeg(
    b_lean_obj_arg path_obj,
    uint32_t width, uint32_t height, uint32_t channels,
    b_lean_obj_arg data_obj,
    uint8_t quality,
    lean_obj_arg world
) {
    const char* path = lean_string_cstr(path_obj);
    const unsigned char* data = lean_sarray_cptr(data_obj);

    int result = stbi_write_jpg(path, (int)width, (int)height, (int)channels, data, (int)quality);
    if (!result) {
        return mk_io_error("Failed to write JPEG");
    }
    return lean_io_result_mk_ok(lean_box(0));
}

LEAN_EXPORT lean_obj_res raster_write_bmp(
    b_lean_obj_arg path_obj,
    uint32_t width, uint32_t height, uint32_t channels,
    b_lean_obj_arg data_obj,
    lean_obj_arg world
) {
    const char* path = lean_string_cstr(path_obj);
    const unsigned char* data = lean_sarray_cptr(data_obj);

    int result = stbi_write_bmp(path, (int)width, (int)height, (int)channels, data);
    if (!result) {
        return mk_io_error("Failed to write BMP");
    }
    return lean_io_result_mk_ok(lean_box(0));
}

/* Callback context for in-memory encoding */
typedef struct {
    unsigned char* buffer;
    size_t size;
    size_t capacity;
} WriteContext;

static void write_callback(void* context, void* data, int size) {
    WriteContext* ctx = (WriteContext*)context;
    size_t needed = ctx->size + (size_t)size;
    if (needed > ctx->capacity) {
        size_t new_capacity = ctx->capacity == 0 ? 4096 : ctx->capacity * 2;
        while (new_capacity < needed) new_capacity *= 2;
        ctx->buffer = realloc(ctx->buffer, new_capacity);
        ctx->capacity = new_capacity;
    }
    memcpy(ctx->buffer + ctx->size, data, (size_t)size);
    ctx->size += (size_t)size;
}

LEAN_EXPORT lean_obj_res raster_encode_png(
    uint32_t width, uint32_t height, uint32_t channels,
    b_lean_obj_arg data_obj,
    lean_obj_arg world
) {
    const unsigned char* data = lean_sarray_cptr(data_obj);
    int stride = (int)(width * channels);

    WriteContext ctx = {NULL, 0, 0};
    int result = stbi_write_png_to_func(write_callback, &ctx,
                                         (int)width, (int)height, (int)channels,
                                         data, stride);
    if (!result || !ctx.buffer) {
        if (ctx.buffer) free(ctx.buffer);
        return mk_io_error("Failed to encode PNG");
    }

    lean_object* arr = lean_alloc_sarray(1, ctx.size, ctx.size);
    memcpy(lean_sarray_cptr(arr), ctx.buffer, ctx.size);
    free(ctx.buffer);

    return lean_io_result_mk_ok(arr);
}

LEAN_EXPORT lean_obj_res raster_encode_jpeg(
    uint32_t width, uint32_t height, uint32_t channels,
    b_lean_obj_arg data_obj,
    uint8_t quality,
    lean_obj_arg world
) {
    const unsigned char* data = lean_sarray_cptr(data_obj);

    WriteContext ctx = {NULL, 0, 0};
    int result = stbi_write_jpg_to_func(write_callback, &ctx,
                                         (int)width, (int)height, (int)channels,
                                         data, (int)quality);
    if (!result || !ctx.buffer) {
        if (ctx.buffer) free(ctx.buffer);
        return mk_io_error("Failed to encode JPEG");
    }

    lean_object* arr = lean_alloc_sarray(1, ctx.size, ctx.size);
    memcpy(lean_sarray_cptr(arr), ctx.buffer, ctx.size);
    free(ctx.buffer);

    return lean_io_result_mk_ok(arr);
}

/* ========================================================================== */
/* Resize Operations                                                           */
/* ========================================================================== */

LEAN_EXPORT lean_obj_res raster_resize(
    b_lean_obj_arg src_data_obj,
    uint32_t src_width, uint32_t src_height,
    uint32_t dst_width, uint32_t dst_height,
    uint8_t channels,
    lean_obj_arg world
) {
    const unsigned char* src = lean_sarray_cptr(src_data_obj);
    size_t dst_size = (size_t)dst_width * dst_height * channels;

    lean_object* dst_arr = lean_alloc_sarray(1, dst_size, dst_size);
    unsigned char* dst = lean_sarray_cptr(dst_arr);

    /* Use stbir_resize with proper pixel layout */
    stbir_pixel_layout layout;
    switch (channels) {
        case 1: layout = STBIR_1CHANNEL; break;
        case 2: layout = STBIR_2CHANNEL; break;
        case 3: layout = STBIR_RGB; break;
        case 4: layout = STBIR_RGBA; break;
        default:
            lean_dec(dst_arr);
            return mk_io_error("Invalid channel count for resize");
    }

    unsigned char* result = stbir_resize_uint8_linear(
        src, (int)src_width, (int)src_height, 0,
        dst, (int)dst_width, (int)dst_height, 0,
        layout
    );

    if (!result) {
        lean_dec(dst_arr);
        return mk_io_error("Resize operation failed");
    }

    return lean_io_result_mk_ok(dst_arr);
}
