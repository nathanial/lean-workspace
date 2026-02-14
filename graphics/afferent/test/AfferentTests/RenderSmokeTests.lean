/-
  Afferent Render Smoke Tests
  Lightweight checks for shader registry and dynamic state helpers.
-/
import AfferentTests.Framework
import Afferent.Runtime.Shader.Sources
import Afferent.Graphics.Render.Dynamic
import Init.Data.FloatArray

namespace AfferentTests.RenderSmokeTests

open Crucible
open AfferentTests
open Afferent

testSuite "Render Smoke Tests"

private def shaderSource? (name : String) : Option String :=
  Afferent.Shaders.all.find? (fun entry => entry.fst == name) |>.map (·.snd)

private def hasDuplicate (names : Array String) : Bool := Id.run do
  let mut seen : Array String := #[]
  for n in names do
    if seen.contains n then
      return true
    seen := seen.push n
  return false

test "shader registry includes expected names and non-empty sources" := do
  let names := Afferent.Shaders.all.map (·.fst)
  ensure (!hasDuplicate names) "Shader registry contains duplicate names"
  let expected := #[
    "basic",
    "text",
    "sprite",
    "stroke",
    "stroke_path",
    "mesh3d"
  ]
  for name in expected do
    match shaderSource? name with
    | some src =>
        ensure (src.length > 0) s!"Shader {name} source is empty"
    | none =>
        ensure false s!"Shader {name} missing from registry"

test "core shader entry points exist" := do
  let sprite := (shaderSource? "sprite").getD ""
  shouldContainSubstr sprite "sprite_vertex_layout0"
  shouldContainSubstr sprite "sprite_fragment"
  let mesh3d := (shaderSource? "mesh3d").getD ""
  shouldContainSubstr mesh3d "vertex_main_3d"
  shouldContainSubstr mesh3d "vertex_main_3d_textured"
  shouldContainSubstr mesh3d "fragment_main_3d"

private def mkParticles : Render.Dynamic.ParticleState :=
  let data := Id.run do
    let mut arr := FloatArray.emptyWithCapacity 10
    -- Particle 0: x=10, y=20, vx=0, vy=0, hue=0.1
    arr := arr.push 10.0
    arr := arr.push 20.0
    arr := arr.push 0.0
    arr := arr.push 0.0
    arr := arr.push 0.1
    -- Particle 1: x=30, y=40, vx=0, vy=0, hue=0.3
    arr := arr.push 30.0
    arr := arr.push 40.0
    arr := arr.push 0.0
    arr := arr.push 0.0
    arr := arr.push 0.3
    arr
  { data, count := 2, screenWidth := 50.0, screenHeight := 50.0 }

test "particle bouncing updates position and reflects velocity at bounds" := do
  let particles := mkParticles
  let updated := particles.updateBouncing 0.1 5.0
  shouldBeNear (updated.data.get! 0) 10.0
  shouldBeNear (updated.data.get! 1) 20.0
  shouldBeNear (updated.data.get! 5) 30.0
  shouldBeNear (updated.data.get! 6) 40.0



end AfferentTests.RenderSmokeTests
