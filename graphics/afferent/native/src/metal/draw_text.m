// draw_text.m - Instanced text rendering and font texture management
#import "render.h"
#include <string.h>
#include <limits.h>
#include <stdlib.h>

#define TEXT_BATCH_CACHE_MAX_ENTRIES 256
#define TEXT_BATCH_CACHE_MAX_BYTES (64u * 1024u * 1024u)

typedef struct {
    uint8_t valid;
    uintptr_t font_key;
    uint32_t atlas_version;
    uint32_t text_count;
    uint64_t texts_hash;
    uint32_t glyph_count;
    size_t static_bytes;
    size_t total_bytes;
    uint64_t last_used;
    __strong id<MTLBuffer> static_glyph_buffer;
} TextBatchCacheEntry;

static TextBatchCacheEntry g_text_batch_cache[TEXT_BATCH_CACHE_MAX_ENTRIES] = {0};
static size_t g_text_batch_cache_bytes = 0;
static uint64_t g_text_batch_cache_tick = 1;

static TextRunDynamic* g_text_run_dynamic_scratch = NULL;
static size_t g_text_run_dynamic_scratch_cap = 0;

static uint64_t fnv1a64_step(uint64_t h, const uint8_t* data, size_t len) {
    for (size_t i = 0; i < len; i++) {
        h ^= (uint64_t)data[i];
        h *= 1099511628211ull;
    }
    return h;
}

static uint64_t text_batch_hash(const char** texts, uint32_t count) {
    uint64_t h = 1469598103934665603ull;
    for (uint32_t i = 0; i < count; i++) {
        const char* text = texts[i];
        if (text) {
            h = fnv1a64_step(h, (const uint8_t*)text, strlen(text));
        }
        const uint8_t sep = 0xFF;
        h = fnv1a64_step(h, &sep, 1);
    }
    h ^= (uint64_t)count;
    h *= 1099511628211ull;
    return h;
}

static int ensure_text_run_dynamic_capacity(uint32_t count) {
    size_t need = (size_t)count;
    if (need <= g_text_run_dynamic_scratch_cap) {
        return 1;
    }
    size_t new_cap = need + (need >> 1) + 16;
    TextRunDynamic* resized = realloc(g_text_run_dynamic_scratch, new_cap * sizeof(TextRunDynamic));
    if (!resized) {
        return 0;
    }
    g_text_run_dynamic_scratch = resized;
    g_text_run_dynamic_scratch_cap = new_cap;
    return 1;
}

static void text_batch_cache_clear_entry(TextBatchCacheEntry* entry) {
    if (!entry) return;
    entry->valid = 0;
    entry->font_key = 0;
    entry->atlas_version = 0;
    entry->text_count = 0;
    entry->texts_hash = 0;
    entry->glyph_count = 0;
    entry->static_bytes = 0;
    entry->total_bytes = 0;
    entry->last_used = 0;
    entry->static_glyph_buffer = nil;
}

static void text_batch_cache_evict_index(int idx) {
    if (idx < 0 || idx >= TEXT_BATCH_CACHE_MAX_ENTRIES) return;
    TextBatchCacheEntry* entry = &g_text_batch_cache[idx];
    if (!entry->valid) return;
    if (entry->total_bytes <= g_text_batch_cache_bytes) {
        g_text_batch_cache_bytes -= entry->total_bytes;
    } else {
        g_text_batch_cache_bytes = 0;
    }
    text_batch_cache_clear_entry(entry);
}

static void text_batch_cache_make_room(size_t bytes_needed) {
    while (g_text_batch_cache_bytes + bytes_needed > TEXT_BATCH_CACHE_MAX_BYTES) {
        int lru_idx = -1;
        uint64_t lru_tick = ULLONG_MAX;
        for (int i = 0; i < TEXT_BATCH_CACHE_MAX_ENTRIES; i++) {
            if (!g_text_batch_cache[i].valid) continue;
            if (g_text_batch_cache[i].last_used < lru_tick) {
                lru_tick = g_text_batch_cache[i].last_used;
                lru_idx = i;
            }
        }
        if (lru_idx < 0) {
            break;
        }
        text_batch_cache_evict_index(lru_idx);
    }
}

static int text_batch_cache_find_slot(void) {
    for (int i = 0; i < TEXT_BATCH_CACHE_MAX_ENTRIES; i++) {
        if (!g_text_batch_cache[i].valid) return i;
    }
    int lru_idx = -1;
    uint64_t lru_tick = ULLONG_MAX;
    for (int i = 0; i < TEXT_BATCH_CACHE_MAX_ENTRIES; i++) {
        if (g_text_batch_cache[i].last_used < lru_tick) {
            lru_tick = g_text_batch_cache[i].last_used;
            lru_idx = i;
        }
    }
    if (lru_idx >= 0) {
        text_batch_cache_evict_index(lru_idx);
    }
    return lru_idx;
}

static TextBatchCacheEntry* text_batch_cache_lookup(
    uintptr_t font_key,
    uint32_t atlas_version,
    uint64_t texts_hash,
    uint32_t text_count
) {
    for (int i = 0; i < TEXT_BATCH_CACHE_MAX_ENTRIES; i++) {
        TextBatchCacheEntry* entry = &g_text_batch_cache[i];
        if (!entry->valid) continue;
        if (entry->font_key != font_key) continue;
        if (entry->atlas_version != atlas_version) continue;
        if (entry->texts_hash != texts_hash) continue;
        if (entry->text_count != text_count) continue;
        entry->last_used = g_text_batch_cache_tick++;
        return entry;
    }
    return NULL;
}

// Create or update font atlas texture
id<MTLTexture> ensureFontTexture(AfferentRendererRef renderer, AfferentFontRef font) {
    void* stored_texture = afferent_font_get_metal_texture(font);
    id<MTLTexture> texture = (__bridge id<MTLTexture>)stored_texture;

    if (!texture) {
        uint8_t* atlas_data = afferent_font_get_atlas_data(font);
        uint32_t atlas_width = afferent_font_get_atlas_width(font);
        uint32_t atlas_height = afferent_font_get_atlas_height(font);

        MTLTextureDescriptor *desc =
            [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm
                                                               width:atlas_width
                                                              height:atlas_height
                                                           mipmapped:NO];
        desc.usage = MTLTextureUsageShaderRead;

        texture = [renderer->device newTextureWithDescriptor:desc];
        if (!texture) {
            return nil;
        }

        MTLRegion region = MTLRegionMake2D(0, 0, atlas_width, atlas_height);
        [texture replaceRegion:region mipmapLevel:0 withBytes:atlas_data bytesPerRow:atlas_width];

        afferent_font_set_metal_texture(font, (__bridge_retained void*)texture);
    }

    return texture;
}

// Update the font texture with new glyph data (only if atlas has changed)
void updateFontTexture(AfferentRendererRef renderer, AfferentFontRef font) {
    (void)renderer;
    if (!afferent_font_atlas_dirty(font)) {
        return;
    }

    id<MTLTexture> texture = (__bridge id<MTLTexture>)afferent_font_get_metal_texture(font);
    if (texture) {
        uint8_t* atlas_data = afferent_font_get_atlas_data(font);
        uint32_t atlas_width = afferent_font_get_atlas_width(font);
        uint32_t atlas_height = afferent_font_get_atlas_height(font);

        MTLRegion region = MTLRegionMake2D(0, 0, atlas_width, atlas_height);
        [texture replaceRegion:region mipmapLevel:0 withBytes:atlas_data bytesPerRow:atlas_width];

        afferent_font_atlas_clear_dirty(font);
    }
}

static TextBatchCacheEntry* build_or_get_batch_cache_entry(
    AfferentRendererRef renderer,
    AfferentFontRef font,
    const char** texts,
    uint32_t count,
    AfferentResult* out_result
) {
    if (out_result) *out_result = AFFERENT_OK;

    uint32_t atlas_version = afferent_font_get_atlas_version(font);
    uintptr_t font_key = (uintptr_t)font;
    uint64_t hash = text_batch_hash(texts, count);

    TextBatchCacheEntry* cached = text_batch_cache_lookup(font_key, atlas_version, hash, count);
    if (cached && cached->static_glyph_buffer) {
        return cached;
    }

    AfferentTextGlyphInstanceStatic* instances = NULL;
    uint32_t instance_count = 0;
    int ok = afferent_text_generate_glyph_instances_batch(font, texts, count, &instances, &instance_count);
    if (!ok) {
        if (out_result) *out_result = AFFERENT_ERROR_TEXT_FAILED;
        return NULL;
    }
    if (instance_count == 0 || !instances) {
        return NULL;
    }

    size_t static_bytes = (size_t)instance_count * sizeof(TextGlyphInstanceStatic);
    id<MTLBuffer> static_buffer =
        [renderer->device newBufferWithLength:static_bytes options:MTLResourceStorageModeShared];
    if (!static_buffer) {
        if (out_result) *out_result = AFFERENT_ERROR_TEXT_FAILED;
        return NULL;
    }
    memcpy(static_buffer.contents, instances, static_bytes);

    size_t total_bytes = static_bytes;
    text_batch_cache_make_room(total_bytes);
    int slot = text_batch_cache_find_slot();
    if (slot < 0) {
        if (out_result) *out_result = AFFERENT_ERROR_TEXT_FAILED;
        return NULL;
    }

    TextBatchCacheEntry* entry = &g_text_batch_cache[slot];
    text_batch_cache_clear_entry(entry);
    entry->valid = 1;
    entry->font_key = font_key;
    entry->atlas_version = atlas_version;
    entry->text_count = count;
    entry->texts_hash = hash;
    entry->glyph_count = instance_count;
    entry->static_bytes = static_bytes;
    entry->total_bytes = total_bytes;
    entry->last_used = g_text_batch_cache_tick++;
    entry->static_glyph_buffer = static_buffer;

    g_text_batch_cache_bytes += total_bytes;
    return entry;
}

// Render multiple text strings with the same font in a single draw call
AfferentResult afferent_text_render_batch(
    AfferentRendererRef renderer,
    AfferentFontRef font,
    const char** texts,
    const float* positions,
    const float* colors,
    const float* transforms,
    uint32_t count,
    float canvas_width,
    float canvas_height
) {
    @autoreleasepool {
        if (!renderer || !renderer->currentEncoder || !font || !texts || count == 0) {
            return AFFERENT_OK;
        }

        id<MTLTexture> fontTexture = ensureFontTexture(renderer, font);
        if (!fontTexture) {
            return AFFERENT_ERROR_TEXT_FAILED;
        }
        updateFontTexture(renderer, font);

        AfferentResult cacheResult = AFFERENT_OK;
        TextBatchCacheEntry* entry = build_or_get_batch_cache_entry(
            renderer, font, texts, count, &cacheResult
        );
        if (cacheResult != AFFERENT_OK) {
            return cacheResult;
        }
        if (!entry || !entry->static_glyph_buffer || entry->glyph_count == 0) {
            return AFFERENT_OK;
        }

        if (!ensure_text_run_dynamic_capacity(count)) {
            return AFFERENT_ERROR_TEXT_FAILED;
        }

        const float identity[6] = {1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f};
        for (uint32_t i = 0; i < count; i++) {
            const float* t = transforms ? &transforms[i * 6] : identity;
            float x = positions ? positions[i * 2] : 0.0f;
            float y = positions ? positions[i * 2 + 1] : 0.0f;
            float r = colors ? colors[i * 4] : 1.0f;
            float g = colors ? colors[i * 4 + 1] : 1.0f;
            float b = colors ? colors[i * 4 + 2] : 1.0f;
            float a = colors ? colors[i * 4 + 3] : 1.0f;

            TextRunDynamic* run = &g_text_run_dynamic_scratch[i];
            run->affine0[0] = t[0];
            run->affine0[1] = t[1];
            run->affine0[2] = t[2];
            run->affine0[3] = t[3];
            run->affine1[0] = t[4];
            run->affine1[1] = t[5];
            run->origin[0] = x;
            run->origin[1] = y;
            run->color[0] = r;
            run->color[1] = g;
            run->color[2] = b;
            run->color[3] = a;
        }

        // IMPORTANT: dynamic run data must be per draw-call.
        // Reusing one mutable run buffer from the cache lets later writes in the same frame
        // overwrite positions for earlier draws before GPU execution.
        size_t run_bytes = (size_t)count * sizeof(TextRunDynamic);
        id<MTLBuffer> run_buffer = pool_acquire_buffer(
            renderer->device,
            g_buffer_pool.text_vertex_pool,
            &g_buffer_pool.text_vertex_pool_count,
            run_bytes
        );
        if (!run_buffer) {
            run_buffer = [renderer->device newBufferWithLength:run_bytes
                                                       options:MTLResourceStorageModeShared];
        }
        if (!run_buffer) {
            return AFFERENT_ERROR_TEXT_FAILED;
        }
        memcpy(run_buffer.contents, g_text_run_dynamic_scratch, run_bytes);

        TextInstancedUniforms uniforms;
        uniforms.viewport[0] = canvas_width;
        uniforms.viewport[1] = canvas_height;

        [renderer->currentEncoder setRenderPipelineState:renderer->textPipelineState];
        [renderer->currentEncoder setDepthStencilState:renderer->depthStateDisabled];

        [renderer->currentEncoder setFragmentTexture:fontTexture atIndex:0];
        [renderer->currentEncoder setFragmentSamplerState:renderer->textSampler atIndex:0];

        [renderer->currentEncoder setVertexBuffer:entry->static_glyph_buffer offset:0 atIndex:0];
        [renderer->currentEncoder setVertexBuffer:run_buffer offset:0 atIndex:1];
        [renderer->currentEncoder setVertexBytes:&uniforms length:sizeof(uniforms) atIndex:2];

        [renderer->currentEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip
                                    vertexStart:0
                                    vertexCount:4
                                  instanceCount:entry->glyph_count];

        [renderer->currentEncoder setRenderPipelineState:renderer->pipelineState];
        return AFFERENT_OK;
    }
}

// Render one text string by routing through the instanced batch path
AfferentResult afferent_text_render(
    AfferentRendererRef renderer,
    AfferentFontRef font,
    const char* text,
    float x,
    float y,
    float r,
    float g,
    float b,
    float a,
    const float* transform,
    float canvas_width,
    float canvas_height
) {
    @autoreleasepool {
        if (!renderer || !renderer->currentEncoder || !font || !text || text[0] == '\0') {
            return AFFERENT_OK;
        }

        const char* texts[1] = {text};
        float positions[2] = {x, y};
        float colors[4] = {r, g, b, a};
        float identity[6] = {1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f};
        const float* transforms_ptr = transform ? transform : identity;

        return afferent_text_render_batch(
            renderer,
            font,
            texts,
            positions,
            colors,
            transforms_ptr,
            1,
            canvas_width,
            canvas_height
        );
    }
}

// Helper to get renderer screen dimensions (for Lean FFI)
float afferent_renderer_get_screen_width(AfferentRendererRef renderer) {
    return renderer ? renderer->screenWidth : 0;
}

float afferent_renderer_get_screen_height(AfferentRendererRef renderer) {
    return renderer ? renderer->screenHeight : 0;
}

// Release a retained Metal texture (called from text_render.c when font is destroyed)
void afferent_release_metal_texture(void* texture_ptr) {
    if (texture_ptr) {
        id<MTLTexture> texture = (__bridge_transfer id<MTLTexture>)texture_ptr;
        (void)texture;
    }
}
