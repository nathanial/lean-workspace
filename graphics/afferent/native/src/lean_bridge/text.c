#include "lean_bridge_internal.h"
#include <stdlib.h>

// ============== Font/Text FFI ==============

// Reusable scratch buffers for text batch marshaling.
// Rendering runs on a single thread in the demo runner, so process-global reuse is sufficient.
static const char** g_text_batch_texts = NULL;
static size_t g_text_batch_texts_cap = 0;
static float* g_text_batch_positions = NULL;
static size_t g_text_batch_positions_cap = 0;
static float* g_text_batch_colors = NULL;
static size_t g_text_batch_colors_cap = 0;
static float* g_text_batch_transforms = NULL;
static size_t g_text_batch_transforms_cap = 0;

static int ensure_text_batch_capacity(uint32_t count) {
    size_t text_need = (size_t)count;
    size_t pos_need = (size_t)count * 2;
    size_t color_need = (size_t)count * 4;
    size_t transform_need = (size_t)count * 6;

    if (text_need > g_text_batch_texts_cap) {
        size_t new_cap = text_need * 2;
        const char** resized = realloc((void*)g_text_batch_texts, new_cap * sizeof(char*));
        if (!resized) return 0;
        g_text_batch_texts = resized;
        g_text_batch_texts_cap = new_cap;
    }
    if (pos_need > g_text_batch_positions_cap) {
        size_t new_cap = pos_need * 2;
        float* resized = realloc(g_text_batch_positions, new_cap * sizeof(float));
        if (!resized) return 0;
        g_text_batch_positions = resized;
        g_text_batch_positions_cap = new_cap;
    }
    if (color_need > g_text_batch_colors_cap) {
        size_t new_cap = color_need * 2;
        float* resized = realloc(g_text_batch_colors, new_cap * sizeof(float));
        if (!resized) return 0;
        g_text_batch_colors = resized;
        g_text_batch_colors_cap = new_cap;
    }
    if (transform_need > g_text_batch_transforms_cap) {
        size_t new_cap = transform_need * 2;
        float* resized = realloc(g_text_batch_transforms, new_cap * sizeof(float));
        if (!resized) return 0;
        g_text_batch_transforms = resized;
        g_text_batch_transforms_cap = new_cap;
    }

    return 1;
}

// Load a font from file
LEAN_EXPORT lean_obj_res lean_afferent_font_load(
    lean_obj_arg path_obj,
    uint32_t size,
    lean_obj_arg world
) {
    afferent_ensure_initialized();
    const char* path = lean_string_cstr(path_obj);
    AfferentFontRef font = NULL;
    AfferentResult result = afferent_font_load(path, size, &font);

    if (result != AFFERENT_OK) {
        return lean_io_result_mk_error(lean_mk_io_user_error(
            lean_mk_string("Failed to load font")));
    }

    lean_object* obj = lean_alloc_external(g_font_class, font);
    return lean_io_result_mk_ok(obj);
}

// Destroy a font
LEAN_EXPORT lean_obj_res lean_afferent_font_destroy(lean_obj_arg font_obj, lean_obj_arg world) {
    AfferentFontRef font = (AfferentFontRef)lean_get_external_data(font_obj);
    afferent_font_destroy(font);
    return lean_io_result_mk_ok(lean_box(0));
}

// Get font metrics (returns a tuple: ascender, descender, line_height)
// Float × Float × Float = Prod Float (Prod Float Float)
// Prod has constructor tag 0 with 2 object fields (fst, snd)
LEAN_EXPORT lean_obj_res lean_afferent_font_get_metrics(lean_obj_arg font_obj, lean_obj_arg world) {
    AfferentFontRef font = (AfferentFontRef)lean_get_external_data(font_obj);
    float ascender, descender, line_height;
    afferent_font_get_metrics(font, &ascender, &descender, &line_height);

    // Build nested tuple: (ascender, (descender, line_height))
    // Inner tuple: (descender, line_height)
    lean_object* inner = lean_alloc_ctor(0, 2, 0);  // Prod with 2 object fields
    lean_ctor_set(inner, 0, lean_box_float((double)descender));
    lean_ctor_set(inner, 1, lean_box_float((double)line_height));

    // Outer tuple: (ascender, inner)
    lean_object* outer = lean_alloc_ctor(0, 2, 0);  // Prod with 2 object fields
    lean_ctor_set(outer, 0, lean_box_float((double)ascender));
    lean_ctor_set(outer, 1, inner);

    return lean_io_result_mk_ok(outer);
}

// Measure text dimensions (returns a tuple: width, height)
// Float × Float = Prod Float Float with 2 object fields (boxed floats)
LEAN_EXPORT lean_obj_res lean_afferent_text_measure(
    lean_obj_arg font_obj,
    lean_obj_arg text_obj,
    lean_obj_arg world
) {
    AfferentFontRef font = (AfferentFontRef)lean_get_external_data(font_obj);
    const char* text = lean_string_cstr(text_obj);
    float width, height;
    afferent_text_measure(font, text, &width, &height);

    // Return as a Prod with 2 boxed floats
    lean_object* tuple = lean_alloc_ctor(0, 2, 0);
    lean_ctor_set(tuple, 0, lean_box_float((double)width));
    lean_ctor_set(tuple, 1, lean_box_float((double)height));
    return lean_io_result_mk_ok(tuple);
}

// Render text
LEAN_EXPORT lean_obj_res lean_afferent_text_render(
    lean_obj_arg renderer_obj,
    lean_obj_arg font_obj,
    lean_obj_arg text_obj,
    double x,
    double y,
    double r,
    double g,
    double b,
    double a,
    lean_obj_arg transform_arr,
    double canvas_width,
    double canvas_height,
    lean_obj_arg world
) {
    AfferentRendererRef renderer = (AfferentRendererRef)lean_get_external_data(renderer_obj);
    AfferentFontRef font = (AfferentFontRef)lean_get_external_data(font_obj);
    const char* text = lean_string_cstr(text_obj);

    // Extract transform array (6 floats: a, b, c, d, tx, ty)
    float transform[6] = {1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f};  // Identity default
    size_t arr_size = lean_array_size(transform_arr);
    if (arr_size >= 6) {
        for (size_t i = 0; i < 6; i++) {
            transform[i] = (float)lean_unbox_float(lean_array_get_core(transform_arr, i));
        }
    }

    AfferentResult result = afferent_text_render(
        renderer, font, text,
        (float)x, (float)y,
        (float)r, (float)g, (float)b, (float)a,
        transform,
        (float)canvas_width, (float)canvas_height
    );

    if (result != AFFERENT_OK) {
        return lean_io_result_mk_error(lean_mk_io_user_error(
            lean_mk_string("Failed to render text")));
    }

    return lean_io_result_mk_ok(lean_box(0));
}

// Batch text rendering - multiple strings with same font in one draw call
LEAN_EXPORT lean_obj_res lean_afferent_text_render_batch(
    lean_obj_arg renderer_obj,
    lean_obj_arg font_obj,
    lean_obj_arg texts_arr,
    lean_obj_arg positions_arr,
    lean_obj_arg colors_arr,
    lean_obj_arg transforms_arr,
    double canvas_width,
    double canvas_height,
    lean_obj_arg world
) {
    AfferentRendererRef renderer = (AfferentRendererRef)lean_get_external_data(renderer_obj);
    AfferentFontRef font = (AfferentFontRef)lean_get_external_data(font_obj);

    uint32_t count = (uint32_t)lean_array_size(texts_arr);
    if (count == 0) {
        return lean_io_result_mk_ok(lean_box(0));
    }

    if (!ensure_text_batch_capacity(count)) {
        return lean_io_result_mk_error(lean_mk_io_user_error(
            lean_mk_string("Failed to allocate text batch buffers")));
    }

    // Extract text strings
    for (uint32_t i = 0; i < count; i++) {
        g_text_batch_texts[i] = lean_string_cstr(lean_array_get_core(texts_arr, i));
    }

    // Extract positions array (2 floats per entry). Default to (0, 0) when missing.
    size_t pos_size = lean_array_size(positions_arr);
    if (pos_size >= (size_t)count * 2) {
        for (size_t i = 0; i < (size_t)count * 2; i++) {
            g_text_batch_positions[i] = (float)lean_unbox_float(lean_array_get_core(positions_arr, i));
        }
    } else {
        for (size_t i = 0; i < (size_t)count * 2; i++) {
            g_text_batch_positions[i] = 0.0f;
        }
    }

    // Extract colors array (4 floats per entry). Default to white when missing.
    size_t color_size = lean_array_size(colors_arr);
    if (color_size >= (size_t)count * 4) {
        for (size_t i = 0; i < (size_t)count * 4; i++) {
            g_text_batch_colors[i] = (float)lean_unbox_float(lean_array_get_core(colors_arr, i));
        }
    } else {
        for (uint32_t i = 0; i < count; i++) {
            size_t base = (size_t)i * 4;
            g_text_batch_colors[base + 0] = 1.0f;
            g_text_batch_colors[base + 1] = 1.0f;
            g_text_batch_colors[base + 2] = 1.0f;
            g_text_batch_colors[base + 3] = 1.0f;
        }
    }

    // Extract transforms array (6 floats per entry). Default to identity when missing.
    size_t transform_size = lean_array_size(transforms_arr);
    if (transform_size >= (size_t)count * 6) {
        for (size_t i = 0; i < (size_t)count * 6; i++) {
            g_text_batch_transforms[i] = (float)lean_unbox_float(lean_array_get_core(transforms_arr, i));
        }
    } else {
        for (uint32_t i = 0; i < count; i++) {
            size_t base = (size_t)i * 6;
            g_text_batch_transforms[base + 0] = 1.0f;
            g_text_batch_transforms[base + 1] = 0.0f;
            g_text_batch_transforms[base + 2] = 0.0f;
            g_text_batch_transforms[base + 3] = 1.0f;
            g_text_batch_transforms[base + 4] = 0.0f;
            g_text_batch_transforms[base + 5] = 0.0f;
        }
    }

    AfferentResult result = afferent_text_render_batch(
        renderer, font, g_text_batch_texts, g_text_batch_positions, g_text_batch_colors,
        g_text_batch_transforms, count,
        (float)canvas_width, (float)canvas_height
    );

    if (result != AFFERENT_OK) {
        return lean_io_result_mk_error(lean_mk_io_user_error(
            lean_mk_string("Failed to render text batch")));
    }

    return lean_io_result_mk_ok(lean_box(0));
}
