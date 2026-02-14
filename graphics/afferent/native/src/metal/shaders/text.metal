// text.metal - Text rendering shader
#include <metal_stdlib>
using namespace metal;

struct TextGlyphInstanceStatic {
    packed_float2 localPos;
    packed_float2 size;
    packed_float2 uvMin;
    packed_float2 uvMax;
    uint runIndex;
};

struct TextRunDynamic {
    packed_float4 affine0;  // [a, b, c, d]
    packed_float2 affine1;  // [tx, ty]
    packed_float2 origin;   // [x, y]
    packed_float4 color;
};

struct TextInstancedUniforms {
    float2 viewport;
};

struct TextVertexOut {
    float4 position [[position]];
    float2 texCoord;
    float4 color;
};

vertex TextVertexOut text_vertex_main(
    uint vid [[vertex_id]],
    uint iid [[instance_id]],
    constant TextGlyphInstanceStatic* glyphs [[buffer(0)]],
    constant TextRunDynamic* runs [[buffer(1)]],
    constant TextInstancedUniforms& uniforms [[buffer(2)]]
) {
    TextGlyphInstanceStatic glyph = glyphs[iid];
    TextRunDynamic run = runs[glyph.runIndex];

    float2 unitQuad[4] = {
        float2(0.0, 0.0),
        float2(1.0, 0.0),
        float2(0.0, 1.0),
        float2(1.0, 1.0)
    };
    float2 corner = unitQuad[vid];

    float2 localPixel = glyph.localPos + glyph.size * corner + run.origin;
    float2 transformed = float2(
        run.affine0.x * localPixel.x + run.affine0.z * localPixel.y + run.affine1.x,
        run.affine0.y * localPixel.x + run.affine0.w * localPixel.y + run.affine1.y
    );

    float2 ndc;
    ndc.x = (transformed.x / uniforms.viewport.x) * 2.0 - 1.0;
    ndc.y = 1.0 - (transformed.y / uniforms.viewport.y) * 2.0;

    TextVertexOut out;
    out.position = float4(ndc, 0.0, 1.0);
    out.texCoord = mix(glyph.uvMin, glyph.uvMax, corner);
    out.color = run.color;
    return out;
}

fragment float4 text_fragment_main(
    TextVertexOut in [[stage_in]],
    texture2d<float> tex [[texture(0)]],
    sampler smp [[sampler(0)]]
) {
    float alpha = tex.sample(smp, in.texCoord).r;
    return float4(in.color.rgb, in.color.a * alpha);
}
