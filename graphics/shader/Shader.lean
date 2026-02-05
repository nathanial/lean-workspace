/-
  Shader DSL
  A domain-specific language for writing GPU shaders in pure Lean.

  This module provides:
  - Typed expression AST (`ShaderExpr`) that mirrors Metal types
  - Metal code generation via `toMetal`
  - Circle fragment shader compilation via `CircleShader.compile`
  - Rectangle fragment shader compilation via `RectShader.compile`
  - Quad fragment shader compilation via `QuadShader.compile`
  - Operator instances for ergonomic DSL usage
  - Common shader operations (hsvToRgb, easing functions, etc.)

  ## Example Usage

  ```lean
  import Shader

  open Shader in
  def myShader : CircleShader := {
    name := "myShader"
    instanceCount := 8
    params := [
      ⟨"center", .float2⟩,
      ⟨"size", .float⟩,
      ⟨"time", .float⟩,
      ⟨"color", .float4⟩
    ]
    body := {
      center := center + vec2 (sin (time * twoPi)) 0.0
      radius := size * 0.1
      color := color
    }
  }

  def myFragment : ShaderFragment := myShader.compile
  ```
-/

import Shader.Types
import Shader.Expr
import Shader.Render
import Shader.Ops
import Shader.Prelude
import Shader.Fragment
import Shader.Registry
import Shader.Circle
import Shader.Rect
import Shader.Quad
