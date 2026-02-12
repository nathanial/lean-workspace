/*
 * Afferent Text Rendering
 * FreeType integration for font loading and glyph rasterization.
 */

#include <ft2build.h>
#include FT_FREETYPE_H

#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "afferent.h"

// External function to release Metal texture (defined in metal_render.m)
extern void afferent_release_metal_texture(void* texture_ptr);

// FreeType library handle (global, initialized once)
static FT_Library g_ft_library = NULL;
static int g_ft_init_count = 0;

// Texture atlas sizing
#define ATLAS_INITIAL_WIDTH 1024
#define ATLAS_INITIAL_HEIGHT 1024
#define ATLAS_MAX_DIM 4096

// Glyph cache sizing
#define GLYPH_TABLE_INITIAL_CAPACITY 1024
#define GLYPH_TABLE_MAX_LOAD_NUM 7
#define GLYPH_TABLE_MAX_LOAD_DEN 10

// Text geometry cache sizing
#define TEXT_GEOM_TABLE_INITIAL_CAPACITY 2048
#define TEXT_GEOM_TABLE_MAX_LOAD_NUM 7
#define TEXT_GEOM_TABLE_MAX_LOAD_DEN 10

// Range used for conservative metric scan
#define ASCII_SCAN_START 32
#define ASCII_SCAN_END 256

// Glyph cache entry
typedef struct {
    uint32_t codepoint;
    float advance_x;      // How far to move cursor after this glyph
    float bearing_x;      // Horizontal offset from cursor to glyph
    float bearing_y;      // Vertical offset from baseline to top of glyph
    uint16_t width;       // Glyph bitmap width
    uint16_t height;      // Glyph bitmap height
    uint16_t atlas_x;     // Position in texture atlas
    uint16_t atlas_y;
    uint8_t valid;        // Whether this glyph is cached
} GlyphInfo;

typedef struct {
    GlyphInfo* entries;
    uint32_t capacity;
    uint32_t count;
} GlyphTable;

// Cached geometry for a full text string in local baseline coordinates.
// Vertex format: [x, y, u, v] (4 floats per vertex).
typedef struct {
    uint64_t hash;
    char* text;
    uint32_t text_len;
    float* vertices;
    uint32_t* indices;
    uint32_t vertex_count;
    uint32_t index_count;
    uint32_t atlas_version;
    uint8_t valid;
} TextGeometryEntry;

typedef struct {
    TextGeometryEntry* entries;
    uint32_t capacity;
    uint32_t count;
} TextGeometryTable;

// Font structure
struct AfferentFont {
    FT_Face face;
    uint32_t size;
    float ascender;
    float descender;
    float line_height;

    // Glyph cache (dynamic hash table)
    GlyphTable glyphs;
    TextGeometryTable text_geometries;

    // Texture atlas for glyph bitmaps
    uint8_t* atlas_data;
    uint32_t atlas_width;
    uint32_t atlas_height;
    uint32_t atlas_cursor_x;
    uint32_t atlas_cursor_y;
    uint32_t atlas_row_height;

    // Dirty tracking - only upload when new glyphs are added
    int atlas_dirty;
    uint32_t atlas_version;

    // Metal texture handle (set by renderer)
    void* metal_texture;
};

// Reusable scratch buffers for generated text draw data.
// Text rendering is driven on one thread in the demo runner, so process-global reuse is sufficient.
static float* g_text_vertex_float_scratch = NULL;
static size_t g_text_vertex_float_scratch_cap = 0;  // Number of floats
static uint32_t* g_text_index_scratch = NULL;
static size_t g_text_index_scratch_cap = 0;         // Number of indices
static TextGeometryEntry** g_text_geometry_ptr_scratch = NULL;
static size_t g_text_geometry_ptr_scratch_cap = 0;  // Number of entries

static uint32_t next_pow2(uint32_t v) {
    if (v < 2) return 2;
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    return v + 1;
}

static uint32_t glyph_hash(uint32_t codepoint) {
    // Knuth multiplicative hash
    return codepoint * 2654435761u;
}

static uint64_t text_hash(const char* s, uint32_t len) {
    uint64_t h = 1469598103934665603ull;  // FNV-1a offset basis
    for (uint32_t i = 0; i < len; i++) {
        h ^= (uint8_t)s[i];
        h *= 1099511628211ull;  // FNV-1a prime
    }
    return h;
}

static int ensure_text_output_capacity(uint32_t vertex_count, uint32_t index_count) {
    size_t vertex_need = (size_t)vertex_count * 8;  // 8 floats per output vertex
    size_t index_need = (size_t)index_count;

    if (vertex_need > g_text_vertex_float_scratch_cap) {
        size_t new_cap = vertex_need + (vertex_need >> 1) + 64;
        float* resized = realloc(g_text_vertex_float_scratch, new_cap * sizeof(float));
        if (!resized) {
            return 0;
        }
        g_text_vertex_float_scratch = resized;
        g_text_vertex_float_scratch_cap = new_cap;
    }

    if (index_need > g_text_index_scratch_cap) {
        size_t new_cap = index_need + (index_need >> 1) + 64;
        uint32_t* resized = realloc(g_text_index_scratch, new_cap * sizeof(uint32_t));
        if (!resized) {
            return 0;
        }
        g_text_index_scratch = resized;
        g_text_index_scratch_cap = new_cap;
    }

    return 1;
}

static int ensure_text_geometry_ptr_capacity(uint32_t count) {
    size_t need = (size_t)count;
    if (need <= g_text_geometry_ptr_scratch_cap) {
        return 1;
    }
    size_t new_cap = need + (need >> 1) + 16;
    TextGeometryEntry** resized = realloc(
        g_text_geometry_ptr_scratch, new_cap * sizeof(TextGeometryEntry*)
    );
    if (!resized) {
        return 0;
    }
    g_text_geometry_ptr_scratch = resized;
    g_text_geometry_ptr_scratch_cap = new_cap;
    return 1;
}

static int glyph_table_init(GlyphTable* table, uint32_t capacity) {
    uint32_t cap = next_pow2(capacity);
    table->entries = calloc(cap, sizeof(GlyphInfo));
    if (!table->entries) {
        table->capacity = 0;
        table->count = 0;
        return 0;
    }
    table->capacity = cap;
    table->count = 0;
    return 1;
}

static void glyph_table_destroy(GlyphTable* table) {
    if (table->entries) {
        free(table->entries);
    }
    table->entries = NULL;
    table->capacity = 0;
    table->count = 0;
}

static void text_geometry_entry_release(TextGeometryEntry* entry) {
    if (!entry) return;
    free(entry->text);
    free(entry->vertices);
    free(entry->indices);
    entry->text = NULL;
    entry->vertices = NULL;
    entry->indices = NULL;
    entry->text_len = 0;
    entry->vertex_count = 0;
    entry->index_count = 0;
    entry->atlas_version = 0;
    entry->hash = 0;
    entry->valid = 0;
}

static int text_geometry_table_init(TextGeometryTable* table, uint32_t capacity) {
    uint32_t cap = next_pow2(capacity);
    table->entries = calloc(cap, sizeof(TextGeometryEntry));
    if (!table->entries) {
        table->capacity = 0;
        table->count = 0;
        return 0;
    }
    table->capacity = cap;
    table->count = 0;
    return 1;
}

static void text_geometry_table_destroy(TextGeometryTable* table) {
    if (table->entries) {
        for (uint32_t i = 0; i < table->capacity; i++) {
            if (table->entries[i].valid) {
                text_geometry_entry_release(&table->entries[i]);
            }
        }
        free(table->entries);
    }
    table->entries = NULL;
    table->capacity = 0;
    table->count = 0;
}

static int text_geometry_table_rehash(TextGeometryTable* table, uint32_t new_capacity) {
    TextGeometryEntry* old_entries = table->entries;
    uint32_t old_capacity = table->capacity;

    uint32_t cap = next_pow2(new_capacity);
    TextGeometryEntry* new_entries = calloc(cap, sizeof(TextGeometryEntry));
    if (!new_entries) {
        return 0;
    }

    table->entries = new_entries;
    table->capacity = cap;
    table->count = 0;

    if (old_entries) {
        uint32_t mask = cap - 1;
        for (uint32_t i = 0; i < old_capacity; i++) {
            TextGeometryEntry* entry = &old_entries[i];
            if (!entry->valid) continue;
            uint32_t idx = (uint32_t)(entry->hash & (uint64_t)mask);
            while (new_entries[idx].valid) {
                idx = (idx + 1) & mask;
            }
            new_entries[idx] = *entry;
            table->count++;
        }
        free(old_entries);
    }

    return 1;
}

static TextGeometryEntry* text_geometry_table_find(TextGeometryTable* table, uint64_t hash,
                                                   const char* text, uint32_t len) {
    if (!table->entries || table->capacity == 0) {
        return NULL;
    }
    uint32_t mask = table->capacity - 1;
    uint32_t idx = (uint32_t)(hash & (uint64_t)mask);
    for (uint32_t i = 0; i < table->capacity; i++) {
        TextGeometryEntry* entry = &table->entries[idx];
        if (!entry->valid) {
            return NULL;
        }
        if (entry->hash == hash && entry->text_len == len &&
            entry->text && memcmp(entry->text, text, len) == 0) {
            return entry;
        }
        idx = (idx + 1) & mask;
    }
    return NULL;
}

static TextGeometryEntry* text_geometry_table_find_slot(TextGeometryTable* table, uint64_t hash,
                                                        const char* text, uint32_t len, int* existed) {
    if (!table->entries || table->capacity == 0) {
        return NULL;
    }

    uint32_t threshold = (table->capacity * TEXT_GEOM_TABLE_MAX_LOAD_NUM) / TEXT_GEOM_TABLE_MAX_LOAD_DEN;
    if (table->count + 1 > threshold) {
        if (!text_geometry_table_rehash(table, table->capacity * 2)) {
            return NULL;
        }
    }

    uint32_t mask = table->capacity - 1;
    uint32_t idx = (uint32_t)(hash & (uint64_t)mask);
    for (uint32_t i = 0; i < table->capacity; i++) {
        TextGeometryEntry* entry = &table->entries[idx];
        if (!entry->valid) {
            if (existed) *existed = 0;
            return entry;
        }
        if (entry->hash == hash && entry->text_len == len && entry->text &&
            memcmp(entry->text, text, len) == 0) {
            if (existed) *existed = 1;
            return entry;
        }
        idx = (idx + 1) & mask;
    }
    return NULL;
}

static int glyph_table_rehash(GlyphTable* table, uint32_t new_capacity) {
    GlyphInfo* old_entries = table->entries;
    uint32_t old_capacity = table->capacity;

    uint32_t cap = next_pow2(new_capacity);
    GlyphInfo* new_entries = calloc(cap, sizeof(GlyphInfo));
    if (!new_entries) {
        return 0;
    }

    table->entries = new_entries;
    table->capacity = cap;
    table->count = 0;

    if (old_entries) {
        uint32_t mask = cap - 1;
        for (uint32_t i = 0; i < old_capacity; i++) {
            GlyphInfo* entry = &old_entries[i];
            if (!entry->valid) continue;
            uint32_t idx = glyph_hash(entry->codepoint) & mask;
            while (new_entries[idx].valid) {
                idx = (idx + 1) & mask;
            }
            new_entries[idx] = *entry;
            table->count++;
        }
        free(old_entries);
    }

    return 1;
}

static GlyphInfo* glyph_table_find(GlyphTable* table, uint32_t codepoint) {
    if (!table->entries || table->capacity == 0) {
        return NULL;
    }
    uint32_t mask = table->capacity - 1;
    uint32_t idx = glyph_hash(codepoint) & mask;
    for (uint32_t i = 0; i < table->capacity; i++) {
        GlyphInfo* entry = &table->entries[idx];
        if (!entry->valid) {
            return NULL;
        }
        if (entry->codepoint == codepoint) {
            return entry;
        }
        idx = (idx + 1) & mask;
    }
    return NULL;
}

static GlyphInfo* glyph_table_find_slot(GlyphTable* table, uint32_t codepoint, int* existed) {
    if (!table->entries || table->capacity == 0) {
        return NULL;
    }

    uint32_t threshold = (table->capacity * GLYPH_TABLE_MAX_LOAD_NUM) / GLYPH_TABLE_MAX_LOAD_DEN;
    if (table->count + 1 > threshold) {
        if (!glyph_table_rehash(table, table->capacity * 2)) {
            return NULL;
        }
    }

    uint32_t mask = table->capacity - 1;
    uint32_t idx = glyph_hash(codepoint) & mask;
    for (uint32_t i = 0; i < table->capacity; i++) {
        GlyphInfo* entry = &table->entries[idx];
        if (!entry->valid) {
            if (existed) *existed = 0;
            return entry;
        }
        if (entry->codepoint == codepoint) {
            if (existed) *existed = 1;
            return entry;
        }
        idx = (idx + 1) & mask;
    }
    return NULL;
}

static uint32_t utf8_next(const char** p) {
    const unsigned char* s = (const unsigned char*)*p;
    unsigned char c = s[0];
    if (c == 0) {
        return 0;
    }
    if (c < 0x80) {
        (*p)++;
        return c;
    }
    if ((c >> 5) == 0x6) {
        if ((s[1] & 0xC0) != 0x80) {
            (*p)++;
            return 0xFFFD;
        }
        uint32_t cp = ((uint32_t)(c & 0x1F) << 6) | (uint32_t)(s[1] & 0x3F);
        if (cp < 0x80) {
            (*p)++;
            return 0xFFFD;
        }
        (*p) += 2;
        return cp;
    }
    if ((c >> 4) == 0xE) {
        if ((s[1] & 0xC0) != 0x80 || (s[2] & 0xC0) != 0x80) {
            (*p)++;
            return 0xFFFD;
        }
        uint32_t cp = ((uint32_t)(c & 0x0F) << 12) |
                      ((uint32_t)(s[1] & 0x3F) << 6) |
                      (uint32_t)(s[2] & 0x3F);
        if (cp < 0x800 || (cp >= 0xD800 && cp <= 0xDFFF)) {
            (*p)++;
            return 0xFFFD;
        }
        (*p) += 3;
        return cp;
    }
    if ((c >> 3) == 0x1E) {
        if ((s[1] & 0xC0) != 0x80 || (s[2] & 0xC0) != 0x80 || (s[3] & 0xC0) != 0x80) {
            (*p)++;
            return 0xFFFD;
        }
        uint32_t cp = ((uint32_t)(c & 0x07) << 18) |
                      ((uint32_t)(s[1] & 0x3F) << 12) |
                      ((uint32_t)(s[2] & 0x3F) << 6) |
                      (uint32_t)(s[3] & 0x3F);
        if (cp < 0x10000 || cp > 0x10FFFF) {
            (*p)++;
            return 0xFFFD;
        }
        (*p) += 4;
        return cp;
    }
    (*p)++;
    return 0xFFFD;
}

static int ensure_atlas_capacity(AfferentFontRef font, uint32_t glyph_w, uint32_t glyph_h) {
    if (!font) {
        return 0;
    }

    uint32_t needed_w = font->atlas_cursor_x + glyph_w + 1;
    uint32_t needed_h = font->atlas_cursor_y + glyph_h + 1;

    if (needed_w <= font->atlas_width && needed_h <= font->atlas_height) {
        return 1;
    }

    uint32_t new_w = font->atlas_width;
    uint32_t new_h = font->atlas_height;

    while (new_w < needed_w || new_h < needed_h) {
        if (new_w < needed_w) new_w *= 2;
        if (new_h < needed_h) new_h *= 2;
        if (new_w > ATLAS_MAX_DIM) new_w = ATLAS_MAX_DIM;
        if (new_h > ATLAS_MAX_DIM) new_h = ATLAS_MAX_DIM;
        if (new_w < needed_w || new_h < needed_h) {
            return 0;
        }
    }

    if (new_w == font->atlas_width && new_h == font->atlas_height) {
        return 1;
    }

    uint8_t* new_data = calloc((size_t)new_w * (size_t)new_h, 1);
    if (!new_data) {
        return 0;
    }

    for (uint32_t y = 0; y < font->atlas_height; y++) {
        memcpy(new_data + (size_t)y * new_w,
               font->atlas_data + (size_t)y * font->atlas_width,
               font->atlas_width);
    }

    free(font->atlas_data);
    font->atlas_data = new_data;
    font->atlas_width = new_w;
    font->atlas_height = new_h;
    font->atlas_version += 1;
    if (font->atlas_version == 0) {
        font->atlas_version = 1;
    }

    if (font->metal_texture) {
        afferent_release_metal_texture(font->metal_texture);
        font->metal_texture = NULL;
    }

    font->atlas_dirty = 1;
    return 1;
}

// Initialize FreeType
AfferentResult afferent_text_init(void) {
    if (g_ft_init_count > 0) {
        g_ft_init_count++;
        return AFFERENT_OK;
    }

    FT_Error error = FT_Init_FreeType(&g_ft_library);
    if (error) {
        return AFFERENT_ERROR_FONT_FAILED;
    }

    g_ft_init_count = 1;
    return AFFERENT_OK;
}

// Shutdown FreeType
void afferent_text_shutdown(void) {
    if (g_ft_init_count > 0) {
        g_ft_init_count--;
        if (g_ft_init_count == 0 && g_ft_library) {
            FT_Done_FreeType(g_ft_library);
            g_ft_library = NULL;
        }
    }
    if (g_ft_init_count == 0) {
        free(g_text_vertex_float_scratch);
        g_text_vertex_float_scratch = NULL;
        g_text_vertex_float_scratch_cap = 0;
        free(g_text_index_scratch);
        g_text_index_scratch = NULL;
        g_text_index_scratch_cap = 0;
        free(g_text_geometry_ptr_scratch);
        g_text_geometry_ptr_scratch = NULL;
        g_text_geometry_ptr_scratch_cap = 0;
    }
}

// Load a font from file
AfferentResult afferent_font_load(
    const char* path,
    uint32_t size,
    AfferentFontRef* out_font
) {
    if (!g_ft_library) {
        // Auto-initialize if not done
        AfferentResult init_result = afferent_text_init();
        if (init_result != AFFERENT_OK) {
            return init_result;
        }
    }

    struct AfferentFont* font = calloc(1, sizeof(struct AfferentFont));
    if (!font) {
        return AFFERENT_ERROR_FONT_FAILED;
    }

    // Load face from file
    FT_Error error = FT_New_Face(g_ft_library, path, 0, &font->face);
    if (error) {
        free(font);
        return AFFERENT_ERROR_FONT_FAILED;
    }

    (void)FT_Select_Charmap(font->face, FT_ENCODING_UNICODE);

    // Set character size (size in pixels, 72 DPI)
    error = FT_Set_Pixel_Sizes(font->face, 0, size);
    if (error) {
        FT_Done_Face(font->face);
        free(font);
        return AFFERENT_ERROR_FONT_FAILED;
    }

    font->size = size;

    // Calculate font metrics.
    //
    // FreeType face metrics are often slightly optimistic once hinting/rasterization is applied,
    // which can make layout under-allocate vertical space and cause text overlap. Since we
    // compute conservative ascent/descent from the rasterized glyph bitmaps for a basic
    // ASCII range, and use it to derive a safe line height.
    float ft_asc = font->face->size->metrics.ascender / 64.0f;
    float ft_desc = font->face->size->metrics.descender / 64.0f;
    float ft_line = font->face->size->metrics.height / 64.0f;

    float max_ascent = 0.0f;
    float max_descent = 0.0f;
    for (uint32_t cp = ASCII_SCAN_START; cp < ASCII_SCAN_END; cp++) {
        FT_Error e = FT_Load_Char(font->face, cp, FT_LOAD_RENDER);
        if (e) continue;
        FT_GlyphSlot slot = font->face->glyph;
        float ascent = (float)slot->bitmap_top;  // baseline -> top
        float descent = (float)slot->bitmap.rows - (float)slot->bitmap_top; // baseline -> bottom
        if (ascent > max_ascent) max_ascent = ascent;
        if (descent > max_descent) max_descent = descent;
    }

    float bitmap_line = max_ascent + max_descent;
    if (bitmap_line <= 0.0f) {
        // Fallback to FreeType metrics if raster scan failed.
        font->ascender = ft_asc;
        font->descender = ft_desc;
        font->line_height = ft_line;
    } else {
        font->ascender = max_ascent;
        font->descender = -max_descent;
        // Keep FreeType's line gap if it is larger than bitmap extents.
        font->line_height = (ft_line > bitmap_line) ? ft_line : bitmap_line;
    }

    // Allocate texture atlas
    font->atlas_width = ATLAS_INITIAL_WIDTH;
    font->atlas_height = ATLAS_INITIAL_HEIGHT;
    font->atlas_data = calloc((size_t)ATLAS_INITIAL_WIDTH * (size_t)ATLAS_INITIAL_HEIGHT, 1);
    if (!font->atlas_data) {
        FT_Done_Face(font->face);
        free(font);
        return AFFERENT_ERROR_FONT_FAILED;
    }

    font->atlas_cursor_x = 1;  // Start at 1 to avoid edge artifacts
    font->atlas_cursor_y = 1;
    font->atlas_row_height = 0;
    font->atlas_version = 1;

    // Initialize glyph cache
    if (!glyph_table_init(&font->glyphs, GLYPH_TABLE_INITIAL_CAPACITY)) {
        free(font->atlas_data);
        FT_Done_Face(font->face);
        free(font);
        return AFFERENT_ERROR_FONT_FAILED;
    }

    if (!text_geometry_table_init(&font->text_geometries, TEXT_GEOM_TABLE_INITIAL_CAPACITY)) {
        glyph_table_destroy(&font->glyphs);
        free(font->atlas_data);
        FT_Done_Face(font->face);
        free(font);
        return AFFERENT_ERROR_FONT_FAILED;
    }

    *out_font = font;
    return AFFERENT_OK;
}

// Destroy a font
void afferent_font_destroy(AfferentFontRef font) {
    if (font) {
        if (font->face) {
            FT_Done_Face(font->face);
        }
        if (font->atlas_data) {
            free(font->atlas_data);
        }
        glyph_table_destroy(&font->glyphs);
        text_geometry_table_destroy(&font->text_geometries);
        // Release the Metal texture if one was created
        if (font->metal_texture) {
            afferent_release_metal_texture(font->metal_texture);
        }
        free(font);
    }
}

// Get font metrics
void afferent_font_get_metrics(
    AfferentFontRef font,
    float* ascender,
    float* descender,
    float* line_height
) {
    if (font) {
        if (ascender) *ascender = font->ascender;
        if (descender) *descender = font->descender;
        if (line_height) *line_height = font->line_height;
    }
}

// Cache a glyph (rasterize and add to atlas)
static GlyphInfo* cache_glyph(AfferentFontRef font, uint32_t codepoint) {
    GlyphInfo* glyph = glyph_table_find(&font->glyphs, codepoint);
    if (glyph) {
        return glyph;  // Already cached
    }

    int existed = 0;
    GlyphInfo* glyph_info = glyph_table_find_slot(&font->glyphs, codepoint, &existed);
    if (!glyph_info) {
        return NULL;
    }
    if (existed) {
        return glyph_info;
    }

    // Load glyph
    FT_Error error = FT_Load_Char(font->face, codepoint, FT_LOAD_RENDER);
    if (error) {
        return NULL;
    }

    FT_GlyphSlot ft_slot = font->face->glyph;
    FT_Bitmap* bitmap = &ft_slot->bitmap;

    // Check if we have room in atlas
    if (font->atlas_cursor_x + bitmap->width + 1 > font->atlas_width) {
        // Move to next row
        font->atlas_cursor_x = 1;
        font->atlas_cursor_y += font->atlas_row_height + 1;
        font->atlas_row_height = 0;
    }

    if (!ensure_atlas_capacity(font, bitmap->width, bitmap->rows)) {
        return NULL;
    }

    // Copy bitmap to atlas (handle mono and grayscale pixel modes)
    int pitch = bitmap->pitch;
    for (uint32_t y = 0; y < bitmap->rows; y++) {
        const uint8_t* row = bitmap->buffer +
            (pitch >= 0 ? (int)y * pitch : (int)(bitmap->rows - 1 - y) * -pitch);
        for (uint32_t x = 0; x < bitmap->width; x++) {
            uint8_t value = 0;
            switch (bitmap->pixel_mode) {
                case FT_PIXEL_MODE_GRAY:
                    value = row[x];
                    break;
                case FT_PIXEL_MODE_MONO: {
                    uint8_t byte = row[x >> 3];
                    uint8_t mask = (uint8_t)(0x80 >> (x & 7));
                    value = (byte & mask) ? 0xFF : 0x00;
                    break;
                }
                case FT_PIXEL_MODE_GRAY2: {
                    uint8_t byte = row[x >> 2];
                    uint8_t shift = (uint8_t)(6 - 2 * (x & 3));
                    uint8_t level = (byte >> shift) & 0x3;
                    value = (uint8_t)(level * 85);  // 255 / 3
                    break;
                }
                case FT_PIXEL_MODE_GRAY4: {
                    uint8_t byte = row[x >> 1];
                    uint8_t shift = (uint8_t)((x & 1) ? 0 : 4);
                    uint8_t level = (byte >> shift) & 0xF;
                    value = (uint8_t)(level * 17);  // 255 / 15
                    break;
                }
                case FT_PIXEL_MODE_BGRA:
                    value = row[x * 4 + 3];
                    break;
                default:
                    value = 0;
                    break;
            }
            uint32_t atlas_idx = (font->atlas_cursor_y + y) * font->atlas_width +
                                 (font->atlas_cursor_x + x);
            font->atlas_data[atlas_idx] = value;
        }
    }

    // Store glyph info
    glyph_info->codepoint = codepoint;
    glyph_info->advance_x = ft_slot->advance.x / 64.0f;
    glyph_info->bearing_x = ft_slot->bitmap_left;
    glyph_info->bearing_y = ft_slot->bitmap_top;
    glyph_info->width = bitmap->width;
    glyph_info->height = bitmap->rows;
    glyph_info->atlas_x = font->atlas_cursor_x;
    glyph_info->atlas_y = font->atlas_cursor_y;
    glyph_info->valid = 1;
    font->glyphs.count++;

    // Mark atlas as dirty - needs upload to GPU
    font->atlas_dirty = 1;

    // Update atlas cursor
    font->atlas_cursor_x += bitmap->width + 1;
    if (bitmap->rows > font->atlas_row_height) {
        font->atlas_row_height = bitmap->rows;
    }

    return glyph_info;
}

static int text_geometry_rebuild(AfferentFontRef font, TextGeometryEntry* entry) {
    if (!font || !entry || !entry->text) {
        return 0;
    }

    free(entry->vertices);
    free(entry->indices);
    entry->vertices = NULL;
    entry->indices = NULL;
    entry->vertex_count = 0;
    entry->index_count = 0;

    // First pass: ensure glyphs are cached and count visible quads.
    uint32_t quad_count = 0;
    const char* p = entry->text;
    while (*p) {
        uint32_t codepoint = utf8_next(&p);
        if (codepoint == 0) break;
        GlyphInfo* glyph = cache_glyph(font, codepoint);
        if (glyph && glyph->width > 0 && glyph->height > 0) {
            quad_count++;
        }
    }

    if (quad_count == 0) {
        entry->atlas_version = font->atlas_version;
        return 1;
    }

    uint32_t vertex_count = quad_count * 4;
    uint32_t index_count = quad_count * 6;
    float* vertices = malloc((size_t)vertex_count * 4 * sizeof(float));
    uint32_t* indices = malloc((size_t)index_count * sizeof(uint32_t));
    if (!vertices || !indices) {
        free(vertices);
        free(indices);
        return 0;
    }

    float cursor_x = 0.0f;
    float cursor_y = 0.0f;
    uint32_t quad_idx = 0;
    p = entry->text;
    while (*p) {
        uint32_t codepoint = utf8_next(&p);
        if (codepoint == 0) break;
        GlyphInfo* glyph = cache_glyph(font, codepoint);

        if (glyph && glyph->width > 0 && glyph->height > 0) {
            float gx = cursor_x + glyph->bearing_x;
            float gy = cursor_y - glyph->bearing_y;
            float gw = glyph->width;
            float gh = glyph->height;

            float x0 = gx;
            float y0 = gy;
            float x1 = gx + gw;
            float y1 = gy;
            float x2 = gx + gw;
            float y2 = gy + gh;
            float x3 = gx;
            float y3 = gy + gh;

            float u0 = (float)glyph->atlas_x / font->atlas_width;
            float v0 = (float)glyph->atlas_y / font->atlas_height;
            float u1 = (float)(glyph->atlas_x + glyph->width) / font->atlas_width;
            float v1 = (float)(glyph->atlas_y + glyph->height) / font->atlas_height;

            uint32_t base_vertex = quad_idx * 4;
            size_t vi = (size_t)base_vertex * 4;

            vertices[vi++] = x0; vertices[vi++] = y0; vertices[vi++] = u0; vertices[vi++] = v0;
            vertices[vi++] = x1; vertices[vi++] = y1; vertices[vi++] = u1; vertices[vi++] = v0;
            vertices[vi++] = x2; vertices[vi++] = y2; vertices[vi++] = u1; vertices[vi++] = v1;
            vertices[vi++] = x3; vertices[vi++] = y3; vertices[vi++] = u0; vertices[vi++] = v1;

            uint32_t base_index = quad_idx * 6;
            indices[base_index + 0] = base_vertex + 0;
            indices[base_index + 1] = base_vertex + 1;
            indices[base_index + 2] = base_vertex + 2;
            indices[base_index + 3] = base_vertex + 0;
            indices[base_index + 4] = base_vertex + 2;
            indices[base_index + 5] = base_vertex + 3;

            quad_idx++;
        }

        if (glyph) {
            cursor_x += glyph->advance_x;
        }
    }

    entry->vertices = vertices;
    entry->indices = indices;
    entry->vertex_count = vertex_count;
    entry->index_count = index_count;
    entry->atlas_version = font->atlas_version;
    return 1;
}

static TextGeometryEntry* get_or_build_text_geometry(AfferentFontRef font, const char* text) {
    if (!font || !text) {
        return NULL;
    }

    uint32_t len = (uint32_t)strlen(text);
    uint64_t hash = text_hash(text, len);
    TextGeometryEntry* entry = text_geometry_table_find(&font->text_geometries, hash, text, len);
    if (entry) {
        if (entry->atlas_version != font->atlas_version) {
            if (!text_geometry_rebuild(font, entry)) {
                return NULL;
            }
        }
        return entry;
    }

    int existed = 0;
    entry = text_geometry_table_find_slot(&font->text_geometries, hash, text, len, &existed);
    if (!entry) {
        return NULL;
    }
    if (existed) {
        if (entry->atlas_version != font->atlas_version) {
            if (!text_geometry_rebuild(font, entry)) {
                return NULL;
            }
        }
        return entry;
    }

    memset(entry, 0, sizeof(*entry));
    entry->hash = hash;
    entry->text_len = len;
    entry->text = malloc((size_t)len + 1);
    if (!entry->text) {
        memset(entry, 0, sizeof(*entry));
        return NULL;
    }
    memcpy(entry->text, text, len + 1);
    entry->valid = 1;
    font->text_geometries.count++;

    if (!text_geometry_rebuild(font, entry)) {
        text_geometry_entry_release(entry);
        return NULL;
    }

    return entry;
}

// Measure text dimensions
void afferent_text_measure(
    AfferentFontRef font,
    const char* text,
    float* width,
    float* height
) {
    if (!font || !text) {
        if (width) *width = 0;
        if (height) *height = 0;
        return;
    }

    float total_width = 0;
    float max_height = font->line_height;

    const char* p = text;
    while (*p) {
        uint32_t codepoint = utf8_next(&p);
        if (codepoint == 0) break;
        GlyphInfo* glyph = cache_glyph(font, codepoint);

        if (glyph) {
            total_width += glyph->advance_x;
        }
    }

    if (width) *width = total_width;
    if (height) *height = max_height;
}

// Get atlas data for creating Metal texture
uint8_t* afferent_font_get_atlas_data(AfferentFontRef font) {
    return font ? font->atlas_data : NULL;
}

uint32_t afferent_font_get_atlas_width(AfferentFontRef font) {
    return font ? font->atlas_width : 0;
}

uint32_t afferent_font_get_atlas_height(AfferentFontRef font) {
    return font ? font->atlas_height : 0;
}

// Set the Metal texture handle (called by renderer after texture creation)
void afferent_font_set_metal_texture(AfferentFontRef font, void* texture) {
    if (font) {
        font->metal_texture = texture;
    }
}

void* afferent_font_get_metal_texture(AfferentFontRef font) {
    return font ? font->metal_texture : NULL;
}

// Check if atlas needs updating (new glyphs were added)
int afferent_font_atlas_dirty(AfferentFontRef font) {
    return font ? font->atlas_dirty : 0;
}

// Clear the dirty flag after uploading atlas to GPU
void afferent_font_atlas_clear_dirty(AfferentFontRef font) {
    if (font) {
        font->atlas_dirty = 0;
    }
}

// Helper to apply 2D affine transform to a point
// Transform is [a, b, c, d, tx, ty] where: x' = a*x + c*y + tx, y' = b*x + d*y + ty
static inline void apply_transform(float px, float py, const float* t,
                                   float* out_x, float* out_y) {
    *out_x = t[0] * px + t[2] * py + t[4];
    *out_y = t[1] * px + t[3] * py + t[5];
}

// Generate vertex data for rendering text with transform support
// Vertex format: pos.x, pos.y, uv.x, uv.y, r, g, b, a (8 floats per vertex)
// Transform is [a, b, c, d, tx, ty] (6 floats), or NULL for identity
// Returns number of vertices generated
int afferent_text_generate_vertices(
    AfferentFontRef font,
    const char* text,
    float x,
    float y,
    float r, float g, float b, float a,
    float screen_width,
    float screen_height,
    const float* transform,
    float** out_vertices,
    uint32_t** out_indices,
    uint32_t* out_vertex_count,
    uint32_t* out_index_count
) {
    if (!font || !text || !out_vertices || !out_indices) {
        return 0;
    }

    // Default to identity transform if none provided
    float identity[6] = {1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f};
    if (!transform) {
        transform = identity;
    }

    TextGeometryEntry* geom = get_or_build_text_geometry(font, text);
    if (!geom || geom->vertex_count == 0 || geom->index_count == 0) {
        *out_vertices = NULL;
        *out_indices = NULL;
        *out_vertex_count = 0;
        *out_index_count = 0;
        return geom ? 1 : 0;
    }

    if (!ensure_text_output_capacity(geom->vertex_count, geom->index_count)) {
        return 0;
    }
    float* vertices = g_text_vertex_float_scratch;
    uint32_t* indices = g_text_index_scratch;

    for (uint32_t i = 0; i < geom->vertex_count; i++) {
        size_t src = (size_t)i * 4;
        float px = geom->vertices[src + 0] + x;
        float py = geom->vertices[src + 1] + y;
        float u = geom->vertices[src + 2];
        float v = geom->vertices[src + 3];

        float tx, ty;
        apply_transform(px, py, transform, &tx, &ty);

        size_t dst = (size_t)i * 8;
        vertices[dst + 0] = (tx / screen_width) * 2.0f - 1.0f;
        vertices[dst + 1] = 1.0f - (ty / screen_height) * 2.0f;
        vertices[dst + 2] = u;
        vertices[dst + 3] = v;
        vertices[dst + 4] = r;
        vertices[dst + 5] = g;
        vertices[dst + 6] = b;
        vertices[dst + 7] = a;
    }
    for (uint32_t i = 0; i < geom->index_count; i++) {
        indices[i] = geom->indices[i];
    }

    *out_vertices = vertices;
    *out_indices = indices;
    *out_vertex_count = geom->vertex_count;
    *out_index_count = geom->index_count;

    return 1;
}

// Generate vertices for multiple text strings into one buffer
// Each string has its own position, color, and transform
int afferent_text_generate_vertices_batch(
    AfferentFontRef font,
    const char** texts,           // Array of strings
    const float* positions,       // [x0, y0, x1, y1, ...]
    const float* colors,          // [r0, g0, b0, a0, ...]
    const float* transforms,      // [a0, b0, c0, d0, tx0, ty0, ...] (6 per entry)
    uint32_t count,
    float screen_width,
    float screen_height,
    float** out_vertices,
    uint32_t** out_indices,
    uint32_t* out_vertex_count,
    uint32_t* out_index_count
) {
    if (!font || !texts || count == 0 || !out_vertices || !out_indices) {
        if (out_vertices) *out_vertices = NULL;
        if (out_indices) *out_indices = NULL;
        if (out_vertex_count) *out_vertex_count = 0;
        if (out_index_count) *out_index_count = 0;
        return count == 0 ? 1 : 0;
    }

    if (!ensure_text_geometry_ptr_capacity(count)) {
        return 0;
    }
    TextGeometryEntry** geometries = g_text_geometry_ptr_scratch;

    uint32_t total_vertices = 0;
    uint32_t total_indices = 0;
    for (uint32_t i = 0; i < count; i++) {
        const char* text = texts[i];
        if (!text || !*text) {
            geometries[i] = NULL;
            continue;
        }
        TextGeometryEntry* geom = get_or_build_text_geometry(font, text);
        if (!geom) {
            return 0;
        }
        geometries[i] = geom;
        total_vertices += geom->vertex_count;
        total_indices += geom->index_count;
    }

    if (total_vertices == 0 || total_indices == 0) {
        *out_vertices = NULL;
        *out_indices = NULL;
        *out_vertex_count = 0;
        *out_index_count = 0;
        return 1;
    }

    if (!ensure_text_output_capacity(total_vertices, total_indices)) {
        return 0;
    }
    float* vertices = g_text_vertex_float_scratch;
    uint32_t* indices = g_text_index_scratch;

    // Default identity transform
    float identity[6] = {1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f};

    uint32_t vertex_count = 0;
    uint32_t index_count = 0;

    // Process each text instance using cached local geometry.
    for (uint32_t text_idx = 0; text_idx < count; text_idx++) {
        const TextGeometryEntry* geom = geometries[text_idx];
        if (!geom || geom->vertex_count == 0 || geom->index_count == 0) continue;

        float x = positions ? positions[text_idx * 2] : 0.0f;
        float y = positions ? positions[text_idx * 2 + 1] : 0.0f;
        float r = colors ? colors[text_idx * 4] : 1.0f;
        float g = colors ? colors[text_idx * 4 + 1] : 1.0f;
        float b = colors ? colors[text_idx * 4 + 2] : 1.0f;
        float a = colors ? colors[text_idx * 4 + 3] : 1.0f;
        const float* transform = transforms ? &transforms[text_idx * 6] : identity;

        for (uint32_t i = 0; i < geom->vertex_count; i++) {
            size_t src = (size_t)i * 4;
            float px = geom->vertices[src + 0] + x;
            float py = geom->vertices[src + 1] + y;
            float u = geom->vertices[src + 2];
            float v = geom->vertices[src + 3];

            float tx, ty;
            apply_transform(px, py, transform, &tx, &ty);

            size_t dst = (size_t)(vertex_count + i) * 8;
            vertices[dst + 0] = (tx / screen_width) * 2.0f - 1.0f;
            vertices[dst + 1] = 1.0f - (ty / screen_height) * 2.0f;
            vertices[dst + 2] = u;
            vertices[dst + 3] = v;
            vertices[dst + 4] = r;
            vertices[dst + 5] = g;
            vertices[dst + 6] = b;
            vertices[dst + 7] = a;
        }

        for (uint32_t i = 0; i < geom->index_count; i++) {
            indices[index_count + i] = vertex_count + geom->indices[i];
        }

        vertex_count += geom->vertex_count;
        index_count += geom->index_count;
    }

    *out_vertices = vertices;
    *out_indices = indices;
    *out_vertex_count = vertex_count;
    *out_index_count = index_count;

    return 1;
}
