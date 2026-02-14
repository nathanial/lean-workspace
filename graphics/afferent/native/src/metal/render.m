// render.m - Main renderer module: lifecycle, frame management, buffer creation
#import "render.h"

// Include all sub-modules (compiled separately but included here for single translation unit)
// Note: These are compiled as separate .m files but share headers through render.h
#import "shaders.m"
#import "buffer_pool.m"
#import "pipeline.m"
#import "draw_2d.m"
#import "draw_text.m"
#import "draw_sprites.m"
#import "draw_3d.m"

static void afferent_renderer_free_queued_draw(AfferentQueuedDraw* cmd) {
    if (!cmd) return;
    switch (cmd->type) {
        case AFFERENT_DRAW_CMD_TRIANGLES:
            free(cmd->data.triangles.vertices);
            free(cmd->data.triangles.indices);
            break;
        case AFFERENT_DRAW_CMD_TRIANGLES_SCREEN:
            free(cmd->data.trianglesScreen.vertexData);
            free(cmd->data.trianglesScreen.indices);
            break;
        case AFFERENT_DRAW_CMD_STROKE:
            free(cmd->data.stroke.vertices);
            free(cmd->data.stroke.indices);
            break;
        case AFFERENT_DRAW_CMD_STROKE_PATH:
            free(cmd->data.strokePath.segments);
            break;
        case AFFERENT_DRAW_CMD_TEXT:
            free(cmd->data.text.text);
            break;
        case AFFERENT_DRAW_CMD_SPRITES:
            free(cmd->data.sprites.data);
            break;
        default:
            break;
    }
}

bool afferent_renderer_queue_enabled(AfferentRendererRef renderer) {
    return renderer && renderer->deferDrawCommands && !renderer->flushingDrawQueue;
}

static bool afferent_renderer_reserve_queue(AfferentRendererRef renderer, size_t extra) {
    if (!renderer) return false;
    size_t needed = renderer->drawQueueCount + extra;
    if (needed <= renderer->drawQueueCapacity) return true;

    size_t newCap = renderer->drawQueueCapacity == 0 ? 256 : renderer->drawQueueCapacity * 2;
    while (newCap < needed) {
        newCap *= 2;
    }
    AfferentQueuedDraw* resized =
        (AfferentQueuedDraw*)realloc(renderer->drawQueue, newCap * sizeof(AfferentQueuedDraw));
    if (!resized) return false;
    renderer->drawQueue = resized;
    renderer->drawQueueCapacity = newCap;
    return true;
}

bool afferent_renderer_enqueue_draw(AfferentRendererRef renderer, AfferentQueuedDraw cmd) {
    if (!afferent_renderer_queue_enabled(renderer)) return false;
    if (!afferent_renderer_reserve_queue(renderer, 1)) return false;
    renderer->drawQueue[renderer->drawQueueCount++] = cmd;
    return true;
}

void afferent_renderer_clear_draw_queue(AfferentRendererRef renderer) {
    if (!renderer) return;
    for (size_t i = 0; i < renderer->drawQueueCount; i++) {
        afferent_renderer_free_queued_draw(&renderer->drawQueue[i]);
    }
    renderer->drawQueueCount = 0;
}

static bool float_eq(float a, float b) {
    return a == b;
}

static void afferent_execute_triangles_cmd(
    AfferentRendererRef renderer,
    const AfferentDrawTrianglesCmd* cmd
) {
    if (!renderer || !cmd || cmd->vertexCount == 0 || cmd->indexCount == 0) return;
    AfferentBufferRef vb = NULL;
    AfferentBufferRef ib = NULL;
    if (afferent_buffer_create_vertex(renderer, cmd->vertices, cmd->vertexCount, &vb) != AFFERENT_OK) return;
    if (afferent_buffer_create_index(renderer, cmd->indices, cmd->indexCount, &ib) != AFFERENT_OK) {
        afferent_buffer_destroy(vb);
        return;
    }
    afferent_renderer_draw_triangles(renderer, vb, ib, cmd->indexCount);
    afferent_buffer_destroy(ib);
    afferent_buffer_destroy(vb);
}

static void afferent_execute_triangles_screen_cmd(
    AfferentRendererRef renderer,
    const AfferentDrawTrianglesScreenCmd* cmd
) {
    if (!renderer || !cmd || cmd->vertexCount == 0 || cmd->indexCount == 0) return;
    afferent_renderer_draw_triangles_screen_coords(
        renderer,
        cmd->vertexData,
        cmd->indices,
        cmd->vertexCount,
        cmd->indexCount,
        cmd->canvasWidth,
        cmd->canvasHeight
    );
}

static void afferent_execute_stroke_cmd(
    AfferentRendererRef renderer,
    const AfferentDrawStrokeCmd* cmd
) {
    if (!renderer || !cmd || cmd->vertexCount == 0 || cmd->indexCount == 0) return;
    AfferentBufferRef vb = NULL;
    AfferentBufferRef ib = NULL;
    if (afferent_buffer_create_stroke_vertex(renderer, cmd->vertices, cmd->vertexCount, &vb) != AFFERENT_OK) return;
    if (afferent_buffer_create_index(renderer, cmd->indices, cmd->indexCount, &ib) != AFFERENT_OK) {
        afferent_buffer_destroy(vb);
        return;
    }
    afferent_renderer_draw_stroke(
        renderer,
        vb,
        ib,
        cmd->indexCount,
        cmd->halfWidth,
        cmd->canvasWidth,
        cmd->canvasHeight,
        cmd->color[0],
        cmd->color[1],
        cmd->color[2],
        cmd->color[3]
    );
    afferent_buffer_destroy(ib);
    afferent_buffer_destroy(vb);
}

static void afferent_execute_stroke_path_cmd(
    AfferentRendererRef renderer,
    const AfferentDrawStrokePathCmd* cmd
) {
    if (!renderer || !cmd || cmd->segmentCount == 0) return;
    AfferentBufferRef sb = NULL;
    if (afferent_buffer_create_stroke_segment(renderer, cmd->segments, cmd->segmentCount, &sb) != AFFERENT_OK) return;
    afferent_renderer_draw_stroke_path(
        renderer,
        sb,
        cmd->segmentCount,
        cmd->segmentSubdivisions,
        cmd->halfWidth,
        cmd->canvasWidth,
        cmd->canvasHeight,
        cmd->miterLimit,
        cmd->lineCap,
        cmd->lineJoin,
        cmd->transform[0],
        cmd->transform[1],
        cmd->transform[2],
        cmd->transform[3],
        cmd->transform[4],
        cmd->transform[5],
        cmd->dashSegments,
        cmd->dashCount,
        cmd->dashOffset,
        cmd->color[0],
        cmd->color[1],
        cmd->color[2],
        cmd->color[3]
    );
    afferent_buffer_destroy(sb);
}

static bool afferent_stroke_path_compatible(
    const AfferentDrawStrokePathCmd* a,
    const AfferentDrawStrokePathCmd* b
) {
    if (!a || !b) return false;
    if (a->segmentSubdivisions != b->segmentSubdivisions ||
        a->lineCap != b->lineCap ||
        a->lineJoin != b->lineJoin ||
        a->dashCount != b->dashCount) {
        return false;
    }
    if (!float_eq(a->halfWidth, b->halfWidth) ||
        !float_eq(a->canvasWidth, b->canvasWidth) ||
        !float_eq(a->canvasHeight, b->canvasHeight) ||
        !float_eq(a->miterLimit, b->miterLimit) ||
        !float_eq(a->dashOffset, b->dashOffset)) {
        return false;
    }
    for (int i = 0; i < 6; i++) {
        if (!float_eq(a->transform[i], b->transform[i])) return false;
    }
    for (int i = 0; i < 4; i++) {
        if (!float_eq(a->color[i], b->color[i])) return false;
    }
    for (uint32_t i = 0; i < a->dashCount; i++) {
        if (!float_eq(a->dashSegments[i], b->dashSegments[i])) return false;
    }
    return true;
}

static bool afferent_stroke_compatible(
    const AfferentDrawStrokeCmd* a,
    const AfferentDrawStrokeCmd* b
) {
    if (!a || !b) return false;
    if (!float_eq(a->halfWidth, b->halfWidth) ||
        !float_eq(a->canvasWidth, b->canvasWidth) ||
        !float_eq(a->canvasHeight, b->canvasHeight)) {
        return false;
    }
    for (int i = 0; i < 4; i++) {
        if (!float_eq(a->color[i], b->color[i])) return false;
    }
    return true;
}

static bool afferent_triangles_screen_compatible(
    const AfferentDrawTrianglesScreenCmd* a,
    const AfferentDrawTrianglesScreenCmd* b
) {
    if (!a || !b) return false;
    return float_eq(a->canvasWidth, b->canvasWidth) &&
           float_eq(a->canvasHeight, b->canvasHeight);
}

static bool afferent_text_compatible(
    const AfferentDrawTextCmd* a,
    const AfferentDrawTextCmd* b
) {
    if (!a || !b) return false;
    return a->font == b->font &&
           float_eq(a->canvasWidth, b->canvasWidth) &&
           float_eq(a->canvasHeight, b->canvasHeight);
}

static bool afferent_sprites_compatible(
    const AfferentDrawSpritesCmd* a,
    const AfferentDrawSpritesCmd* b
) {
    if (!a || !b) return false;
    return a->texture == b->texture &&
           float_eq(a->canvasWidth, b->canvasWidth) &&
           float_eq(a->canvasHeight, b->canvasHeight);
}

static bool afferent_draw_cmd_batchable(AfferentDrawCommandType type) {
    switch (type) {
        case AFFERENT_DRAW_CMD_TRIANGLES:
        case AFFERENT_DRAW_CMD_TRIANGLES_SCREEN:
        case AFFERENT_DRAW_CMD_STROKE:
        case AFFERENT_DRAW_CMD_STROKE_PATH:
        case AFFERENT_DRAW_CMD_TEXT:
        case AFFERENT_DRAW_CMD_SPRITES:
            return true;
        default:
            return false;
    }
}

static bool afferent_draw_cmd_compatible(
    const AfferentQueuedDraw* a,
    const AfferentQueuedDraw* b
) {
    if (!a || !b || a->type != b->type) return false;
    switch (a->type) {
        case AFFERENT_DRAW_CMD_TRIANGLES:
            return true;
        case AFFERENT_DRAW_CMD_TRIANGLES_SCREEN:
            return afferent_triangles_screen_compatible(&a->data.trianglesScreen, &b->data.trianglesScreen);
        case AFFERENT_DRAW_CMD_STROKE:
            return afferent_stroke_compatible(&a->data.stroke, &b->data.stroke);
        case AFFERENT_DRAW_CMD_STROKE_PATH:
            return afferent_stroke_path_compatible(&a->data.strokePath, &b->data.strokePath);
        case AFFERENT_DRAW_CMD_TEXT:
            return afferent_text_compatible(&a->data.text, &b->data.text);
        case AFFERENT_DRAW_CMD_SPRITES:
            return afferent_sprites_compatible(&a->data.sprites, &b->data.sprites);
        default:
            return false;
    }
}

static void afferent_flush_group(
    AfferentRendererRef renderer,
    const size_t* groupIndices,
    size_t groupCount
) {
    if (!renderer || !groupIndices || groupCount == 0) return;
    AfferentQueuedDraw* first = &renderer->drawQueue[groupIndices[0]];
    if (!afferent_draw_cmd_batchable(first->type)) {
        for (size_t i = 0; i < groupCount; i++) {
            afferent_renderer_free_queued_draw(&renderer->drawQueue[groupIndices[i]]);
        }
        return;
    }

    if (first->type == AFFERENT_DRAW_CMD_TRIANGLES) {
        uint32_t totalVertices = 0;
        uint32_t totalIndices = 0;
        for (size_t i = 0; i < groupCount; i++) {
            AfferentDrawTrianglesCmd* t = &renderer->drawQueue[groupIndices[i]].data.triangles;
            totalVertices += t->vertexCount;
            totalIndices += t->indexCount;
        }

        AfferentVertex* mergedVertices =
            (AfferentVertex*)malloc((size_t)totalVertices * sizeof(AfferentVertex));
        uint32_t* mergedIndices =
            (uint32_t*)malloc((size_t)totalIndices * sizeof(uint32_t));

        if (mergedVertices && mergedIndices) {
            uint32_t vOffset = 0;
            uint32_t iOffset = 0;
            for (size_t i = 0; i < groupCount; i++) {
                AfferentDrawTrianglesCmd* t = &renderer->drawQueue[groupIndices[i]].data.triangles;
                memcpy(mergedVertices + vOffset, t->vertices, (size_t)t->vertexCount * sizeof(AfferentVertex));
                for (uint32_t k = 0; k < t->indexCount; k++) {
                    mergedIndices[iOffset + k] = t->indices[k] + vOffset;
                }
                vOffset += t->vertexCount;
                iOffset += t->indexCount;
            }
            AfferentDrawTrianglesCmd merged = {
                .vertices = mergedVertices,
                .vertexCount = totalVertices,
                .indices = mergedIndices,
                .indexCount = totalIndices
            };
            afferent_execute_triangles_cmd(renderer, &merged);
        } else {
            for (size_t i = 0; i < groupCount; i++) {
                afferent_execute_triangles_cmd(renderer, &renderer->drawQueue[groupIndices[i]].data.triangles);
            }
        }

        free(mergedVertices);
        free(mergedIndices);
    } else if (first->type == AFFERENT_DRAW_CMD_TRIANGLES_SCREEN) {
        float canvasW = first->data.trianglesScreen.canvasWidth;
        float canvasH = first->data.trianglesScreen.canvasHeight;
        uint32_t totalVertices = 0;
        uint32_t totalIndices = 0;
        for (size_t i = 0; i < groupCount; i++) {
            AfferentDrawTrianglesScreenCmd* t = &renderer->drawQueue[groupIndices[i]].data.trianglesScreen;
            totalVertices += t->vertexCount;
            totalIndices += t->indexCount;
        }

        float* mergedVertices = (float*)malloc((size_t)totalVertices * 6 * sizeof(float));
        uint32_t* mergedIndices = (uint32_t*)malloc((size_t)totalIndices * sizeof(uint32_t));

        if (mergedVertices && mergedIndices) {
            uint32_t vOffset = 0;
            uint32_t iOffset = 0;
            for (size_t i = 0; i < groupCount; i++) {
                AfferentDrawTrianglesScreenCmd* t = &renderer->drawQueue[groupIndices[i]].data.trianglesScreen;
                memcpy(mergedVertices + (size_t)vOffset * 6, t->vertexData,
                       (size_t)t->vertexCount * 6 * sizeof(float));
                for (uint32_t k = 0; k < t->indexCount; k++) {
                    mergedIndices[iOffset + k] = t->indices[k] + vOffset;
                }
                vOffset += t->vertexCount;
                iOffset += t->indexCount;
            }
            AfferentDrawTrianglesScreenCmd merged = {
                .vertexData = mergedVertices,
                .vertexCount = totalVertices,
                .indices = mergedIndices,
                .indexCount = totalIndices,
                .canvasWidth = canvasW,
                .canvasHeight = canvasH
            };
            afferent_execute_triangles_screen_cmd(renderer, &merged);
        } else {
            for (size_t i = 0; i < groupCount; i++) {
                afferent_execute_triangles_screen_cmd(
                    renderer,
                    &renderer->drawQueue[groupIndices[i]].data.trianglesScreen
                );
            }
        }

        free(mergedVertices);
        free(mergedIndices);
    } else if (first->type == AFFERENT_DRAW_CMD_STROKE) {
        uint32_t totalVertices = 0;
        uint32_t totalIndices = 0;
        for (size_t i = 0; i < groupCount; i++) {
            AfferentDrawStrokeCmd* s = &renderer->drawQueue[groupIndices[i]].data.stroke;
            totalVertices += s->vertexCount;
            totalIndices += s->indexCount;
        }

        AfferentStrokeVertex* mergedVertices =
            (AfferentStrokeVertex*)malloc((size_t)totalVertices * sizeof(AfferentStrokeVertex));
        uint32_t* mergedIndices =
            (uint32_t*)malloc((size_t)totalIndices * sizeof(uint32_t));

        if (mergedVertices && mergedIndices) {
            uint32_t vOffset = 0;
            uint32_t iOffset = 0;
            for (size_t i = 0; i < groupCount; i++) {
                AfferentDrawStrokeCmd* s = &renderer->drawQueue[groupIndices[i]].data.stroke;
                memcpy(mergedVertices + vOffset, s->vertices, (size_t)s->vertexCount * sizeof(AfferentStrokeVertex));
                for (uint32_t k = 0; k < s->indexCount; k++) {
                    mergedIndices[iOffset + k] = s->indices[k] + vOffset;
                }
                vOffset += s->vertexCount;
                iOffset += s->indexCount;
            }
            AfferentDrawStrokeCmd merged = first->data.stroke;
            merged.vertices = mergedVertices;
            merged.vertexCount = totalVertices;
            merged.indices = mergedIndices;
            merged.indexCount = totalIndices;
            afferent_execute_stroke_cmd(renderer, &merged);
        } else {
            for (size_t i = 0; i < groupCount; i++) {
                afferent_execute_stroke_cmd(renderer, &renderer->drawQueue[groupIndices[i]].data.stroke);
            }
        }

        free(mergedVertices);
        free(mergedIndices);
    } else if (first->type == AFFERENT_DRAW_CMD_STROKE_PATH) {
        if (groupCount == 1) {
            afferent_execute_stroke_path_cmd(renderer, &first->data.strokePath);
        } else {
            uint32_t totalSegments = 0;
            for (size_t i = 0; i < groupCount; i++) {
                totalSegments += renderer->drawQueue[groupIndices[i]].data.strokePath.segmentCount;
            }

            AfferentStrokeSegment* merged =
                (AfferentStrokeSegment*)malloc((size_t)totalSegments * sizeof(AfferentStrokeSegment));
            if (merged) {
                uint32_t offset = 0;
                for (size_t i = 0; i < groupCount; i++) {
                    AfferentDrawStrokePathCmd* sp = &renderer->drawQueue[groupIndices[i]].data.strokePath;
                    memcpy(merged + offset, sp->segments, (size_t)sp->segmentCount * sizeof(AfferentStrokeSegment));
                    offset += sp->segmentCount;
                }

                AfferentDrawStrokePathCmd mergedCmd = first->data.strokePath;
                mergedCmd.segments = merged;
                mergedCmd.segmentCount = totalSegments;
                afferent_execute_stroke_path_cmd(renderer, &mergedCmd);
                free(merged);
            } else {
                for (size_t i = 0; i < groupCount; i++) {
                    afferent_execute_stroke_path_cmd(renderer, &renderer->drawQueue[groupIndices[i]].data.strokePath);
                }
            }
        }
    } else if (first->type == AFFERENT_DRAW_CMD_TEXT) {
        AfferentFontRef font = first->data.text.font;
        float canvasW = first->data.text.canvasWidth;
        float canvasH = first->data.text.canvasHeight;
        uint32_t runCount = (uint32_t)groupCount;
        const char** texts = (const char**)malloc((size_t)runCount * sizeof(char*));
        float* positions = (float*)malloc((size_t)runCount * 2 * sizeof(float));
        float* colors = (float*)malloc((size_t)runCount * 4 * sizeof(float));
        float* transforms = (float*)malloc((size_t)runCount * 6 * sizeof(float));

        if (texts && positions && colors && transforms) {
            for (uint32_t i = 0; i < runCount; i++) {
                AfferentDrawTextCmd* t = &renderer->drawQueue[groupIndices[i]].data.text;
                texts[i] = t->text;
                positions[i * 2 + 0] = t->x;
                positions[i * 2 + 1] = t->y;
                memcpy(colors + i * 4, t->color, 4 * sizeof(float));
                memcpy(transforms + i * 6, t->transform, 6 * sizeof(float));
            }
            afferent_text_render_runs(renderer, font, texts, positions, colors, transforms, runCount, canvasW, canvasH);
        } else {
            for (size_t i = 0; i < groupCount; i++) {
                AfferentDrawTextCmd* t = &renderer->drawQueue[groupIndices[i]].data.text;
                afferent_text_render(
                    renderer,
                    t->font,
                    t->text,
                    t->x,
                    t->y,
                    t->color[0],
                    t->color[1],
                    t->color[2],
                    t->color[3],
                    t->transform,
                    t->canvasWidth,
                    t->canvasHeight
                );
            }
        }

        free(texts);
        free(positions);
        free(colors);
        free(transforms);
    } else if (first->type == AFFERENT_DRAW_CMD_SPRITES) {
        AfferentTextureRef tex = first->data.sprites.texture;
        float canvasW = first->data.sprites.canvasWidth;
        float canvasH = first->data.sprites.canvasHeight;
        uint32_t totalCount = 0;
        for (size_t i = 0; i < groupCount; i++) {
            totalCount += renderer->drawQueue[groupIndices[i]].data.sprites.count;
        }

        float* merged = (float*)malloc((size_t)totalCount * 5 * sizeof(float));
        if (merged) {
            uint32_t offset = 0;
            for (size_t i = 0; i < groupCount; i++) {
                AfferentDrawSpritesCmd* s = &renderer->drawQueue[groupIndices[i]].data.sprites;
                memcpy(merged + (size_t)offset * 5, s->data, (size_t)s->count * 5 * sizeof(float));
                offset += s->count;
            }
            afferent_renderer_draw_sprites_immediate(renderer, tex, merged, totalCount, canvasW, canvasH);
            free(merged);
        } else {
            for (size_t i = 0; i < groupCount; i++) {
                AfferentDrawSpritesCmd* s = &renderer->drawQueue[groupIndices[i]].data.sprites;
                afferent_renderer_draw_sprites_immediate(
                    renderer,
                    s->texture,
                    s->data,
                    s->count,
                    s->canvasWidth,
                    s->canvasHeight
                );
            }
        }
    }

    for (size_t i = 0; i < groupCount; i++) {
        afferent_renderer_free_queued_draw(&renderer->drawQueue[groupIndices[i]]);
    }
}

static void afferent_renderer_flush_segment(
    AfferentRendererRef renderer,
    size_t start,
    size_t end
) {
    if (!renderer || start >= end) return;

    size_t segmentCount = end - start;
    bool* consumed = (bool*)calloc(segmentCount, sizeof(bool));
    size_t* groupIndices = (size_t*)malloc(segmentCount * sizeof(size_t));

    if (!consumed || !groupIndices) {
        for (size_t i = start; i < end; i++) {
            size_t one = i;
            afferent_flush_group(renderer, &one, 1);
        }
        free(consumed);
        free(groupIndices);
        return;
    }

    for (size_t local = 0; local < segmentCount; local++) {
        if (consumed[local]) continue;

        size_t seedIndex = start + local;
        AfferentQueuedDraw* seed = &renderer->drawQueue[seedIndex];
        if (!afferent_draw_cmd_batchable(seed->type)) {
            consumed[local] = true;
            afferent_renderer_free_queued_draw(seed);
            continue;
        }

        consumed[local] = true;
        size_t groupCount = 1;
        groupIndices[0] = seedIndex;

        for (size_t probe = local + 1; probe < segmentCount; probe++) {
            if (consumed[probe]) continue;
            size_t probeIndex = start + probe;
            if (afferent_draw_cmd_compatible(seed, &renderer->drawQueue[probeIndex])) {
                consumed[probe] = true;
                groupIndices[groupCount++] = probeIndex;
            }
        }

        afferent_flush_group(renderer, groupIndices, groupCount);
    }

    free(consumed);
    free(groupIndices);
}

void afferent_renderer_flush_draw_queue(AfferentRendererRef renderer) {
    if (!renderer || renderer->drawQueueCount == 0) return;
    renderer->flushingDrawQueue = true;

    size_t segmentStart = 0;
    for (size_t i = 0; i < renderer->drawQueueCount; i++) {
        AfferentQueuedDraw* cmd = &renderer->drawQueue[i];
        if (cmd->type == AFFERENT_DRAW_CMD_SET_SCISSOR ||
            cmd->type == AFFERENT_DRAW_CMD_RESET_SCISSOR ||
            !afferent_draw_cmd_batchable(cmd->type)) {
            afferent_renderer_flush_segment(renderer, segmentStart, i);

            if (cmd->type == AFFERENT_DRAW_CMD_SET_SCISSOR) {
                afferent_renderer_set_scissor(
                    renderer,
                    cmd->data.setScissor.x,
                    cmd->data.setScissor.y,
                    cmd->data.setScissor.width,
                    cmd->data.setScissor.height
                );
            } else if (cmd->type == AFFERENT_DRAW_CMD_RESET_SCISSOR) {
                afferent_renderer_reset_scissor(renderer);
            }

            afferent_renderer_free_queued_draw(cmd);
            segmentStart = i + 1;
        }
    }

    afferent_renderer_flush_segment(renderer, segmentStart, renderer->drawQueueCount);
    renderer->drawQueueCount = 0;
    renderer->flushingDrawQueue = false;
}

// ============================================================================
// Renderer Creation and Destruction
// ============================================================================

AfferentResult afferent_renderer_create(
    AfferentWindowRef window,
    AfferentRendererRef* out_renderer
) {
    @autoreleasepool {
        id<MTLDevice> device = afferent_window_get_device(window);
        if (!device) {
            NSLog(@"Failed to get Metal device from window");
            return AFFERENT_ERROR_DEVICE_FAILED;
        }

        struct AfferentRenderer *renderer = calloc(1, sizeof(struct AfferentRenderer));
        if (!renderer) {
            return AFFERENT_ERROR_INIT_FAILED;
        }

        renderer->window = window;
        renderer->device = device;
        renderer->commandQueue = [device newCommandQueue];
        renderer->drawableScaleOverride = 0.0f;
        renderer->drawQueue = NULL;
        renderer->drawQueueCount = 0;
        renderer->drawQueueCapacity = 0;
        renderer->deferDrawCommands = true;
        renderer->flushingDrawQueue = false;

        if (!renderer->commandQueue) {
            NSLog(@"Failed to create command queue");
            free(renderer);
            return AFFERENT_ERROR_INIT_FAILED;
        }

        // Load shaders from external files
        if (!afferent_init_shaders()) {
            NSLog(@"Failed to load shaders");
            free(renderer);
            return AFFERENT_ERROR_INIT_FAILED;
        }

        // Create all pipelines
        AfferentResult pipelineResult = create_pipelines(renderer);
        if (pipelineResult != AFFERENT_OK) {
            free(renderer);
            return pipelineResult;
        }

        // Initialize ocean-related fields
        renderer->oceanIndexBuffer = nil;
        renderer->oceanIndexCount = 0;
        renderer->oceanGridSize = 0;

        // Initialize depth texture pointers
        renderer->msaaColorTexture = nil;
        renderer->depthTexture = nil;
        renderer->depthWidth = 0;
        renderer->depthHeight = 0;
        renderer->msaaWidth = 0;
        renderer->msaaHeight = 0;

        *out_renderer = renderer;
        return AFFERENT_OK;
    }
}

void afferent_renderer_destroy(AfferentRendererRef renderer) {
    if (renderer) {
        @autoreleasepool {
            renderer->currentEncoder = nil;
            renderer->currentCommandBuffer = nil;
            renderer->currentDrawable = nil;

            renderer->msaaColorTexture = nil;
            renderer->depthTexture = nil;
            renderer->depthState = nil;
            renderer->depthStateDisabled = nil;

            renderer->pipelineState = nil;
            renderer->strokePipelineState = nil;
            renderer->textPipelineState = nil;
            renderer->spritePipelineState = nil;
            renderer->pipeline3D = nil;
            renderer->pipeline3DOcean = nil;
            renderer->pipeline3DTextured = nil;

            renderer->textSampler = nil;
            renderer->spriteSampler = nil;
            renderer->texturedMeshSampler = nil;

            renderer->oceanIndexBuffer = nil;

            renderer->commandQueue = nil;
            renderer->device = nil;
            renderer->window = NULL;
        }
        afferent_renderer_clear_draw_queue(renderer);
        free(renderer->drawQueue);
        free(renderer);
    }
}

// ============================================================================
// Internal Accessors
// ============================================================================

id<MTLDevice> afferent_renderer_get_device(AfferentRendererRef renderer) {
    return renderer ? renderer->device : nil;
}

id<MTLRenderCommandEncoder> afferent_renderer_get_encoder(AfferentRendererRef renderer) {
    return renderer ? renderer->currentEncoder : nil;
}

// ============================================================================
// Drawable Scale Control
// ============================================================================

// Enable a drawable scale override (typically 1.0 to disable Retina).
// Pass scale <= 0 to restore native backing scale.
void afferent_renderer_set_drawable_scale(AfferentRendererRef renderer, float scale) {
    if (!renderer) return;
    renderer->drawableScaleOverride = scale;
    CAMetalLayer *metalLayer = afferent_window_get_metal_layer(renderer->window);
    if (!metalLayer) return;
    CGSize boundsSize = metalLayer.bounds.size;
    if (scale > 0.0f) {
        metalLayer.drawableSize = CGSizeMake(boundsSize.width * scale, boundsSize.height * scale);
    } else {
        CGFloat nativeScale = metalLayer.contentsScale;
        if (nativeScale <= 0.0) nativeScale = 1.0;
        metalLayer.drawableSize = CGSizeMake(boundsSize.width * nativeScale, boundsSize.height * nativeScale);
    }
}

// ============================================================================
// Frame Management
// ============================================================================

AfferentResult afferent_renderer_begin_frame(AfferentRendererRef renderer, float r, float g, float b, float a) {
    @autoreleasepool {
        afferent_renderer_clear_draw_queue(renderer);
        // Reset buffer pool at frame start - all buffers become available for reuse
        pool_reset_frame();

        CAMetalLayer *metalLayer = afferent_window_get_metal_layer(renderer->window);
        if (!metalLayer) {
            return AFFERENT_ERROR_INIT_FAILED;
        }

        // Re-apply drawable scale override each frame (handles window resizes)
        if (renderer->drawableScaleOverride > 0.0f) {
            CGSize boundsSize = metalLayer.bounds.size;
            float s = renderer->drawableScaleOverride;
            metalLayer.drawableSize = CGSizeMake(boundsSize.width * s, boundsSize.height * s);
        }

        renderer->currentDrawable = [metalLayer nextDrawable];
        if (!renderer->currentDrawable) {
            return AFFERENT_ERROR_INIT_FAILED;
        }

        renderer->currentCommandBuffer = [renderer->commandQueue commandBuffer];
        if (!renderer->currentCommandBuffer) {
            return AFFERENT_ERROR_INIT_FAILED;
        }

        id<MTLTexture> drawableTexture = renderer->currentDrawable.texture;

        // Store screen dimensions for text rendering
        renderer->screenWidth = drawableTexture.width;
        renderer->screenHeight = drawableTexture.height;

        MTLRenderPassDescriptor *passDesc = [MTLRenderPassDescriptor renderPassDescriptor];
        passDesc.colorAttachments[0].loadAction = MTLLoadActionClear;
        passDesc.colorAttachments[0].clearColor = MTLClearColorMake(r, g, b, a);

        ensureMSAATexture(renderer, drawableTexture.width, drawableTexture.height);
        ensureDepthTexture(renderer, drawableTexture.width, drawableTexture.height);
        if (!renderer->msaaColorTexture || !renderer->depthTexture) {
            return AFFERENT_ERROR_INIT_FAILED;
        }
        passDesc.colorAttachments[0].texture = renderer->msaaColorTexture;
        passDesc.colorAttachments[0].resolveTexture = drawableTexture;
        passDesc.colorAttachments[0].storeAction = MTLStoreActionMultisampleResolve;
        passDesc.depthAttachment.texture = renderer->depthTexture;
        passDesc.depthAttachment.loadAction = MTLLoadActionClear;
        passDesc.depthAttachment.storeAction = MTLStoreActionDontCare;
        passDesc.depthAttachment.clearDepth = 1.0;

        renderer->currentEncoder = [renderer->currentCommandBuffer renderCommandEncoderWithDescriptor:passDesc];
        if (!renderer->currentEncoder) {
            return AFFERENT_ERROR_INIT_FAILED;
        }

        [renderer->currentEncoder setRenderPipelineState:renderer->pipelineState];

        return AFFERENT_OK;
    }
}

AfferentResult afferent_renderer_end_frame(AfferentRendererRef renderer) {
    @autoreleasepool {
        if (renderer->currentEncoder) {
            afferent_renderer_flush_draw_queue(renderer);
            [renderer->currentEncoder endEncoding];
            renderer->currentEncoder = nil;
        }

        if (renderer->currentCommandBuffer && renderer->currentDrawable) {
            [renderer->currentCommandBuffer presentDrawable:renderer->currentDrawable];
            [renderer->currentCommandBuffer commit];
        }

        renderer->currentCommandBuffer = nil;
        renderer->currentDrawable = nil;

        return AFFERENT_OK;
    }
}

// ============================================================================
// Buffer Creation
// ============================================================================

static AfferentResult afferent_buffer_create_pooled(
    AfferentRendererRef renderer,
    PooledBuffer* pool,
    int* pool_count,
    const void* data,
    uint32_t element_count,
    size_t element_size,
    AfferentBufferRef* out_buffer
) {
    @autoreleasepool {
        size_t required_size = (size_t)element_count * element_size;

        id<MTLBuffer> mtlBuffer = pool_acquire_buffer(
            renderer->device,
            pool,
            pool_count,
            required_size
        );

        if (!mtlBuffer) {
            return AFFERENT_ERROR_BUFFER_FAILED;
        }

        memcpy(mtlBuffer.contents, data, required_size);

        struct AfferentBuffer *buffer = pool_acquire_wrapper();
        buffer->count = element_count;
        buffer->mtlBuffer = mtlBuffer;
        buffer->persistent = false;
        *out_buffer = buffer;
        return AFFERENT_OK;
    }
}

AfferentResult afferent_buffer_create_vertex(
    AfferentRendererRef renderer,
    const AfferentVertex* vertices,
    uint32_t vertex_count,
    AfferentBufferRef* out_buffer
) {
    return afferent_buffer_create_pooled(
        renderer,
        g_buffer_pool.vertex_pool,
        &g_buffer_pool.vertex_pool_count,
        vertices,
        vertex_count,
        sizeof(AfferentVertex),
        out_buffer
    );
}

AfferentResult afferent_buffer_create_stroke_vertex(
    AfferentRendererRef renderer,
    const AfferentStrokeVertex* vertices,
    uint32_t vertex_count,
    AfferentBufferRef* out_buffer
) {
    return afferent_buffer_create_pooled(
        renderer,
        g_buffer_pool.vertex_pool,
        &g_buffer_pool.vertex_pool_count,
        vertices,
        vertex_count,
        sizeof(AfferentStrokeVertex),
        out_buffer
    );
}

AfferentResult afferent_buffer_create_stroke_segment(
    AfferentRendererRef renderer,
    const AfferentStrokeSegment* segments,
    uint32_t segment_count,
    AfferentBufferRef* out_buffer
) {
    return afferent_buffer_create_pooled(
        renderer,
        g_buffer_pool.vertex_pool,
        &g_buffer_pool.vertex_pool_count,
        segments,
        segment_count,
        sizeof(AfferentStrokeSegment),
        out_buffer
    );
}

AfferentResult afferent_buffer_create_stroke_segment_persistent(
    AfferentRendererRef renderer,
    const AfferentStrokeSegment* segments,
    uint32_t segment_count,
    AfferentBufferRef* out_buffer
) {
    if (!renderer || !segments || segment_count == 0 || !out_buffer) {
        return AFFERENT_ERROR_BUFFER_FAILED;
    }

    @autoreleasepool {
        size_t required_size = segment_count * sizeof(AfferentStrokeSegment);
        id<MTLBuffer> mtlBuffer = [renderer->device newBufferWithBytes:segments
                                                                length:required_size
                                                               options:MTLResourceStorageModeShared];
        if (!mtlBuffer) {
            return AFFERENT_ERROR_BUFFER_FAILED;
        }

        struct AfferentBuffer *buffer = malloc(sizeof(struct AfferentBuffer));
        if (!buffer) {
            return AFFERENT_ERROR_BUFFER_FAILED;
        }
        buffer->count = segment_count;
        buffer->mtlBuffer = mtlBuffer;
        buffer->persistent = true;
        buffer->pooled = false;
        *out_buffer = buffer;
        return AFFERENT_OK;
    }
}

AfferentResult afferent_buffer_create_index(
    AfferentRendererRef renderer,
    const uint32_t* indices,
    uint32_t index_count,
    AfferentBufferRef* out_buffer
) {
    return afferent_buffer_create_pooled(
        renderer,
        g_buffer_pool.index_pool,
        &g_buffer_pool.index_pool_count,
        indices,
        index_count,
        sizeof(uint32_t),
        out_buffer
    );
}
