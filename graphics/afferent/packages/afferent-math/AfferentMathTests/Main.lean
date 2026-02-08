import Crucible
import AfferentMath.Widget.MathView2D
import AfferentMath.Widget.MathView3D
import AfferentMath.Widget.VectorField
import Linalg.Vec2
import Linalg.Vec3

open Crucible
open AfferentMath.Widget
open Linalg

testSuite "afferent-math"

test "MathView2D world/screen roundtrip remains stable" := do
  let config : MathView2D.Config := { scale := 80.0, originOffset := (20.0, -10.0) }
  let view := MathView2D.viewForSize config 800 600
  let world := Vec2.mk 1.25 (-2.5)
  let screen := MathView2D.worldToScreen view world
  let world' := MathView2D.screenToWorld view screen
  shouldBeNear world'.x world.x
  shouldBeNear world'.y world.y

test "MathView2D.pan updates explicit origin coordinates" := do
  let config : MathView2D.Config := { origin := some (100.0, 200.0) }
  let panned := MathView2D.pan config 30.0 (-20.0)
  ensure (panned.origin == some (130.0, 180.0)) s!"Expected origin (130, 180), got {panned.origin}"

test "MathView2D.zoomAt keeps cursor world point fixed" := do
  let config : MathView2D.Config := { scale := 60.0 }
  let cursor := (150.0, 120.0)
  let before := MathView2D.viewForSize config 640 480
  let worldBefore := MathView2D.screenToWorld before cursor
  let zoomed := MathView2D.zoomAt config 640 480 cursor 1.5 10.0 400.0
  let after := MathView2D.viewForSize zoomed 640 480
  let worldAfter := MathView2D.screenToWorld after cursor
  shouldBeNear worldAfter.x worldBefore.x
  shouldBeNear worldAfter.y worldBefore.y
  ensure (zoomed.scale > config.scale) "Zoom factor > 1 should increase scale"

test "MathView3D orbit and zoom configs clamp to limits" := do
  let config : MathView3D.Config := {
    orbitSpeed := 1.0
    zoomSpeed := 1.0
    minPitch := -0.2
    maxPitch := 0.2
    minDistance := 2.0
    maxDistance := 10.0
    camera := { yaw := 0.0, pitch := 0.0, distance := 3.0, target := Vec3.zero }
  }
  let orbited := MathView3D.orbitConfig config 0.0 1.0
  let zoomedIn := MathView3D.zoomConfig config (-0.9)
  let zoomedOut := MathView3D.zoomConfig config 5.0
  shouldBeNear orbited.camera.pitch 0.2
  shouldBeNear zoomedIn.camera.distance 2.0
  shouldBeNear zoomedOut.camera.distance 10.0

test "VectorField grayscale magnitude mapping spans black-to-white" := do
  let low := VectorField.colorForMagnitude .grayscale 0.0 10.0
  let mid := VectorField.colorForMagnitude .grayscale 5.0 10.0
  let high := VectorField.colorForMagnitude .grayscale 10.0 10.0
  shouldBeNear low.r 0.0
  shouldBeNear mid.r 0.5
  shouldBeNear high.r 1.0
  shouldBeNear high.g 1.0
  shouldBeNear high.b 1.0

def main : IO UInt32 := runAllSuites
