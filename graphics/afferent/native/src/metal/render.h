// render.h - Internal renderer header with structures and declarations
#ifndef AFFERENT_METAL_RENDER_H
#define AFFERENT_METAL_RENDER_H

#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>
#include "afferent.h"
#include "types.h"

// MSAA sample count used by render pass and pipelines.
#define AFFERENT_MSAA_SAMPLE_COUNT 4

// External declarations from window.m
extern id<MTLDevice> afferent_window_get_device(AfferentWindowRef window);
extern CAMetalLayer* afferent_window_get_metal_layer(AfferentWindowRef window);

// External declarations from text_render.c for atlas dirty tracking
extern int afferent_font_atlas_dirty(AfferentFontRef font);
extern void afferent_font_atlas_clear_dirty(AfferentFontRef font);
extern uint32_t afferent_font_get_atlas_version(AfferentFontRef font);

// External declarations from text_render.c
extern uint8_t* afferent_font_get_atlas_data(AfferentFontRef font);
extern uint32_t afferent_font_get_atlas_width(AfferentFontRef font);
extern uint32_t afferent_font_get_atlas_height(AfferentFontRef font);
extern void* afferent_font_get_metal_texture(AfferentFontRef font);
extern void afferent_font_set_metal_texture(AfferentFontRef font, void* texture);
extern int afferent_text_generate_glyph_instances_batch(
    AfferentFontRef font,
    const char** texts,
    uint32_t count,
    TextGlyphInstanceStatic** out_instances,
    uint32_t* out_instance_count
);

// External declarations from texture.c
extern const uint8_t* afferent_texture_get_data(AfferentTextureRef texture);
extern void afferent_texture_get_size(AfferentTextureRef texture, uint32_t* width, uint32_t* height);
extern void* afferent_texture_get_metal_texture(AfferentTextureRef texture);
extern void afferent_texture_set_metal_texture(AfferentTextureRef texture, void* metal_tex);

typedef enum {
    AFFERENT_DRAW_CMD_TRIANGLES = 0,
    AFFERENT_DRAW_CMD_TRIANGLES_SCREEN = 1,
    AFFERENT_DRAW_CMD_STROKE = 2,
    AFFERENT_DRAW_CMD_STROKE_PATH = 3,
    AFFERENT_DRAW_CMD_TEXT = 4,
    AFFERENT_DRAW_CMD_SPRITES = 5,
    AFFERENT_DRAW_CMD_SET_SCISSOR = 6,
    AFFERENT_DRAW_CMD_RESET_SCISSOR = 7
} AfferentDrawCommandType;

typedef struct {
    AfferentVertex* vertices;
    uint32_t vertexCount;
    uint32_t* indices;
    uint32_t indexCount;
} AfferentDrawTrianglesCmd;

typedef struct {
    float* vertexData;      // 6 floats per vertex
    uint32_t vertexCount;
    uint32_t* indices;
    uint32_t indexCount;
    float canvasWidth;
    float canvasHeight;
} AfferentDrawTrianglesScreenCmd;

typedef struct {
    AfferentStrokeVertex* vertices;
    uint32_t vertexCount;
    uint32_t* indices;
    uint32_t indexCount;
    float halfWidth;
    float canvasWidth;
    float canvasHeight;
    float color[4];
} AfferentDrawStrokeCmd;

typedef struct {
    AfferentStrokeSegment* segments;
    uint32_t segmentCount;
    uint32_t segmentSubdivisions;
    float halfWidth;
    float canvasWidth;
    float canvasHeight;
    float miterLimit;
    uint32_t lineCap;
    uint32_t lineJoin;
    float transform[6];
    float dashSegments[8];
    uint32_t dashCount;
    float dashOffset;
    float color[4];
} AfferentDrawStrokePathCmd;

typedef struct {
    AfferentFontRef font;
    char* text;
    float x;
    float y;
    float color[4];
    float transform[6];
    float canvasWidth;
    float canvasHeight;
} AfferentDrawTextCmd;

typedef struct {
    AfferentTextureRef texture;
    float* data;            // 5 floats per sprite
    uint32_t count;
    float canvasWidth;
    float canvasHeight;
} AfferentDrawSpritesCmd;

typedef struct {
    uint32_t x;
    uint32_t y;
    uint32_t width;
    uint32_t height;
} AfferentDrawSetScissorCmd;

typedef struct AfferentQueuedDraw {
    AfferentDrawCommandType type;
    union {
        AfferentDrawTrianglesCmd triangles;
        AfferentDrawTrianglesScreenCmd trianglesScreen;
        AfferentDrawStrokeCmd stroke;
        AfferentDrawStrokePathCmd strokePath;
        AfferentDrawTextCmd text;
        AfferentDrawSpritesCmd sprites;
        AfferentDrawSetScissorCmd setScissor;
    } data;
} AfferentQueuedDraw;

// Internal renderer structure
struct AfferentRenderer {
    AfferentWindowRef window;
    __strong id<MTLDevice> device;
    __strong id<MTLCommandQueue> commandQueue;
    float drawableScaleOverride;                       // 0 = native scale, >0 overrides
    // Active pipeline pointers
    __strong id<MTLRenderPipelineState> pipelineState;
    __strong id<MTLRenderPipelineState> strokePipelineState;    // Screen-space stroke pipeline
    __strong id<MTLRenderPipelineState> strokePathPipelineState; // GPU stroke path pipeline
    __strong id<MTLRenderPipelineState> textPipelineState;      // For text rendering
    __strong id<MTLRenderPipelineState> spritePipelineState;    // Sprite layout (5-float instances)
    __strong id<MTLRenderPipelineState> screenCoordsPipelineState;  // Screen-coords triangle pipeline
    __strong id<MTLSamplerState> textSampler;                   // For text texture sampling
    __strong id<MTLSamplerState> spriteSampler;                 // For sprite texture sampling
    __strong id<MTLCommandBuffer> currentCommandBuffer;
    __strong id<MTLRenderCommandEncoder> currentEncoder;
    __strong id<CAMetalDrawable> currentDrawable;
    __strong id<MTLTexture> msaaColorTexture;         // MSAA color buffer
    // 3D rendering support
    __strong id<MTLTexture> depthTexture;           // Depth buffer
    __strong id<MTLDepthStencilState> depthState;   // Depth test state (enabled)
    __strong id<MTLDepthStencilState> depthStateDisabled; // Depth test disabled for 2D after 3D
    __strong id<MTLRenderPipelineState> pipeline3D;       // Active 3D rendering pipeline
    __strong id<MTLRenderPipelineState> pipeline3DOcean;       // Active ocean projected-grid pipeline
    // Textured 3D rendering (for loaded assets with diffuse textures)
    __strong id<MTLRenderPipelineState> pipeline3DTextured;       // Active textured 3D pipeline
    __strong id<MTLSamplerState> texturedMeshSampler;             // Sampler for textured meshes
    __strong id<MTLBuffer> oceanIndexBuffer;
    uint32_t oceanIndexCount;
    uint32_t oceanGridSize;
    NSUInteger depthWidth;                 // Track depth texture size
    NSUInteger depthHeight;
    NSUInteger msaaWidth;
    NSUInteger msaaHeight;
    float screenWidth;   // Current screen dimensions for text rendering
    float screenHeight;
    AfferentQueuedDraw* drawQueue;
    size_t drawQueueCount;
    size_t drawQueueCapacity;
    bool deferDrawCommands;
    bool flushingDrawQueue;
};

// Internal buffer structure
struct AfferentBuffer {
    __strong id<MTLBuffer> mtlBuffer;
    uint32_t count;
    bool persistent;
    bool pooled;
};

// ============================================================================
// Buffer Pool - Reuse MTLBuffers across frames to avoid allocation overhead
// ============================================================================

#define BUFFER_POOL_SIZE 64
#define MAX_BUFFER_SIZE (1024 * 1024)  // 1MB max per pooled buffer
#define WRAPPER_POOL_SIZE 256  // Pool for AfferentBuffer wrapper structs

typedef struct {
    id<MTLBuffer> buffer;
    size_t capacity;
    bool in_use;
} PooledBuffer;

typedef struct {
    PooledBuffer vertex_pool[BUFFER_POOL_SIZE];
    PooledBuffer index_pool[BUFFER_POOL_SIZE];
    int vertex_pool_count;
    int index_pool_count;
    // Wrapper struct pool to avoid malloc/free per draw call
    struct AfferentBuffer* wrapper_pool[WRAPPER_POOL_SIZE];
    int wrapper_pool_count;
    int wrapper_pool_used;
    // Text rendering buffer pools (separate from shape buffers)
    PooledBuffer text_vertex_pool[BUFFER_POOL_SIZE];
    PooledBuffer text_index_pool[BUFFER_POOL_SIZE];
    int text_vertex_pool_count;
    int text_index_pool_count;
} BufferPool;

// Global buffer pool
extern BufferPool g_buffer_pool;

// Buffer pool functions (buffer_pool.m)
struct AfferentBuffer* pool_acquire_wrapper(void);
id<MTLBuffer> pool_acquire_buffer(id<MTLDevice> device, PooledBuffer* pool, int* count, size_t required_size);
void pool_reset_frame(void);

// Persistent buffer creation (not pooled)
AfferentResult afferent_buffer_create_stroke_segment_persistent(
    AfferentRendererRef renderer,
    const AfferentStrokeSegment* segments,
    uint32_t segment_count,
    AfferentBufferRef* out_buffer
);

// Pipeline creation (pipeline.m)
AfferentResult create_pipelines(struct AfferentRenderer* renderer);
void ensureDepthTexture(AfferentRendererRef renderer, NSUInteger width, NSUInteger height);
void ensureMSAATexture(AfferentRendererRef renderer, NSUInteger width, NSUInteger height);

// Text rendering helpers (draw_text.m)
id<MTLTexture> ensureFontTexture(AfferentRendererRef renderer, AfferentFontRef font);
void updateFontTexture(AfferentRendererRef renderer, AfferentFontRef font);
AfferentResult afferent_text_render_runs(
    AfferentRendererRef renderer,
    AfferentFontRef font,
    const char** texts,
    const float* positions,
    const float* colors,
    const float* transforms,
    uint32_t count,
    float canvas_width,
    float canvas_height
);

// Sprite rendering helpers (draw_sprites.m)
id<MTLTexture> createMetalTexture(id<MTLDevice> device, const uint8_t* data, uint32_t width, uint32_t height);
void afferent_renderer_draw_sprites_immediate(
    AfferentRendererRef renderer,
    AfferentTextureRef texture,
    const float* data,
    uint32_t count,
    float canvasWidth,
    float canvasHeight
);

// 3D rendering helpers (draw_3d.m)
void ensure_ocean_index_buffer(AfferentRendererRef renderer, uint32_t gridSize);

// Renderer internal accessors (for FFI modules)
id<MTLDevice> afferent_renderer_get_device(AfferentRendererRef renderer);
id<MTLRenderCommandEncoder> afferent_renderer_get_encoder(AfferentRendererRef renderer);
bool afferent_renderer_queue_enabled(AfferentRendererRef renderer);
bool afferent_renderer_enqueue_draw(AfferentRendererRef renderer, AfferentQueuedDraw cmd);
void afferent_renderer_clear_draw_queue(AfferentRendererRef renderer);
void afferent_renderer_flush_draw_queue(AfferentRendererRef renderer);

#endif // AFFERENT_METAL_RENDER_H
