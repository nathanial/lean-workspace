import Crucible
import Shader

namespace Shader.Tests

open Crucible
open Shader

testSuite "Shader DSL"

test "ShaderType toMetal" := do
  ShaderType.float.toMetal ≡ "float"
  ShaderType.float2.toMetal ≡ "float2"
  ShaderType.float3.toMetal ≡ "float3"
  ShaderType.float4.toMetal ≡ "float4"
  ShaderType.uint.toMetal ≡ "uint"
  ShaderType.int.toMetal ≡ "int"
  ShaderType.bool.toMetal ≡ "bool"

test "ShaderType floatCount" := do
  ShaderType.float.floatCount ≡ 1
  ShaderType.float2.floatCount ≡ 2
  ShaderType.float3.floatCount ≡ 3
  ShaderType.float4.floatCount ≡ 4
  ShaderType.uint.floatCount ≡ 1

test "ParamStruct floatCount" := do
  let params : ParamStruct := [
    ⟨"center", .float2⟩,
    ⟨"size", .float⟩,
    ⟨"color", .float4⟩
  ]
  params.floatCount ≡ 7

test "ShaderExpr literal rendering" := do
  let f : ShaderExpr .float := .litFloat 1.5
  f.toMetal ≡ "1.500000"

  let v2 : ShaderExpr .float2 := .litFloat2 1.0 2.0
  v2.toMetal ≡ "float2(1.000000, 2.000000)"

  let v4 : ShaderExpr .float4 := .litFloat4 0.1 0.2 0.3 1.0
  v4.toMetal ≡ "float4(0.100000, 0.200000, 0.300000, 1.000000)"

test "ShaderExpr arithmetic rendering" := do
  let a : ShaderExpr .float := .litFloat 1.0
  let b : ShaderExpr .float := .litFloat 2.0
  (a + b).toMetal ≡ "(1.000000 + 2.000000)"
  (a - b).toMetal ≡ "(1.000000 - 2.000000)"
  (a * b).toMetal ≡ "(1.000000 * 2.000000)"
  (a / b).toMetal ≡ "(1.000000 / 2.000000)"
  (-a).toMetal ≡ "(-1.000000)"

test "ShaderExpr param access" := do
  let p : ShaderExpr .float2 := param "center" .float2
  p.toMetal ≡ "p.center"

test "ShaderExpr swizzle" := do
  let v : ShaderExpr .float2 := .litFloat2 1.0 2.0
  v.x.toMetal ≡ "float2(1.000000, 2.000000).x"
  v.y.toMetal ≡ "float2(1.000000, 2.000000).y"

test "ShaderExpr math functions" := do
  let x : ShaderExpr .float := .litFloat 0.5
  (sin x).toMetal ≡ "sin(0.500000)"
  (cos x).toMetal ≡ "cos(0.500000)"
  (sqrt x).toMetal ≡ "sqrt(0.500000)"
  (floor x).toMetal ≡ "floor(0.500000)"

test "ShaderExpr conditional" := do
  let c : ShaderExpr .bool := lt (.litFloat 1.0) (.litFloat 2.0)
  let t : ShaderExpr .float := .litFloat 10.0
  let f : ShaderExpr .float := .litFloat 20.0
  (cond c t f).toMetal ≡ "((1.000000 < 2.000000) ? 10.000000 : 20.000000)"

test "CircleShader compile" := do
  let shader : CircleShader := {
    name := "test"
    instanceCount := 1
    params := [
      ⟨"center", .float2⟩,
      ⟨"radius", .float⟩,
      ⟨"color", .float4⟩
    ]
    body := {
      center := param "center" .float2
      radius := param "radius" .float
      color := param "color" .float4
    }
  }
  let fragment := shader.compile
  fragment.name ≡ "test"
  fragment.instanceCount ≡ 1
  fragment.primitive ≡ .circle
  -- Check that body contains expected Metal code
  shouldContainSubstr fragment.functionCode "result.center = p.center;"
  shouldContainSubstr fragment.functionCode "result.radius = p.radius;"
  shouldContainSubstr fragment.functionCode "result.color = p.color;"

test "RectShader compile" := do
  let shader : RectShader := {
    name := "testRect"
    instanceCount := 1
    params := [
      ⟨"position", .float2⟩,
      ⟨"size", .float2⟩,
      ⟨"color", .float4⟩
    ]
    body := {
      position := param "position" .float2
      size := param "size" .float2
      color := param "color" .float4
    }
  }
  let fragment := shader.compile
  fragment.name ≡ "testRect"
  fragment.instanceCount ≡ 1
  fragment.primitive ≡ .rect
  shouldContainSubstr fragment.functionCode "result.position = p.position;"
  shouldContainSubstr fragment.functionCode "result.size = p.size;"

test "QuadShader compile" := do
  let shader : QuadShader := {
    name := "testQuad"
    instanceCount := 1
    params := [
      ⟨"position", .float2⟩,
      ⟨"size", .float2⟩,
      ⟨"color", .float4⟩
    ]
    vertex := {
      position := param "position" .float2
      size := param "size" .float2
    }
    pixel := {
      color := param "color" .float4
    }
  }
  let fragment := shader.compile
  fragment.name ≡ "testQuad"
  fragment.instanceCount ≡ 1
  fragment.primitive ≡ .quad
  -- Quad functionCode contains both vertex and pixel code separated by |||
  shouldContainSubstr fragment.functionCode "|||"
  shouldContainSubstr fragment.functionCode "result.position = p.position;"
  shouldContainSubstr fragment.functionCode "return p.color;"

test "FragmentRegistry operations" := do
  let frag := fragmentCircle "test" 1 4 "struct TestParams { float4 color; };" "return CircleResult(...);"
  let reg := FragmentRegistry.empty.register frag
  reg.size ≡ 1
  ensure (reg.contains frag.hash) "fragment not found"
  match reg.get? frag.hash with
  | some f => f.name ≡ "test"
  | none => ensure false "fragment lookup failed"

test "ParamStruct layout with padding" := do
  -- float3 requires 4-float alignment but only uses 3
  let params : ParamStruct := [
    ⟨"normal", .float3⟩,  -- offset 0, uses slots 0,1,2
    ⟨"alpha", .float⟩     -- offset 3, uses slot 3
  ]
  let layout := params.layout
  -- Packed: 4 floats (3 + 1)
  layout.packedFloatCount ≡ 4
  -- Padded: 4 floats (no gap needed, total is 4 which is already aligned to 4)
  layout.paddedFloatCount ≡ 4

test "ParamStruct layout with actual padding" := do
  -- Test a case that actually requires padding
  let params : ParamStruct := [
    ⟨"color", .float4⟩,   -- offset 0, uses slots 0,1,2,3
    ⟨"normal", .float3⟩,  -- offset 4, uses slots 4,5,6 (aligned to 4)
    ⟨"alpha", .float⟩     -- offset 7, uses slot 7
  ]
  let layout := params.layout
  -- Packed: 8 floats (4 + 3 + 1)
  layout.packedFloatCount ≡ 8
  -- Padded: 8 floats (already aligned to 4)
  layout.paddedFloatCount ≡ 8

end Shader.Tests

def main : IO UInt32 := runAllSuites
