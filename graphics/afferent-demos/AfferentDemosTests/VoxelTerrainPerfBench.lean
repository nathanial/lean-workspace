/-
  Voxel terrain performance benchmarks.
  Measures end-to-end demo mesh build timings for culled vs greedy meshers.
-/
import Crucible
import Demos.Visuals.VoxelWorld

namespace AfferentDemosTests.VoxelTerrainPerfBench

open Crucible
open Demos

private def nanosToMs (n : Nat) : Float :=
  n.toFloat / 1000000.0

private def fmtMs (v : Float) : String :=
  let scaled := (v * 1000.0).toUInt32.toFloat / 1000.0
  s!"{scaled}"

private def avgMs (nanos : Nat) (samples : Nat) : Float :=
  if samples == 0 then 0.0 else nanos.toFloat / samples.toFloat / 1000000.0

private def ratioOrZero (a b : Float) : Float :=
  if b <= 0.0 then 0.0 else a / b

private structure BuildBenchResult where
  samples : Nat
  avgNs : Nat
  minNs : Nat
  maxNs : Nat
  avgMs : Float
  minMs : Float
  maxMs : Float
  vertices : Nat
  triangles : Nat
  checksum : Nat
  deriving Inhabited

private def BuildBenchResult.format (label : String) (r : BuildBenchResult) : String :=
  s!"{label}: samples={r.samples}, avg={fmtMs r.avgMs}ms ({r.avgNs}ns), " ++
  s!"min={fmtMs r.minMs}ms ({r.minNs}ns), max={fmtMs r.maxMs}ms ({r.maxNs}ns), " ++
  s!"vertices={r.vertices}, triangles={r.triangles}, checksum={r.checksum}"

private def benchBuildVoxelWorldMesh
    (params : VoxelWorldParams) (warmup : Nat := 1) (samples : Nat := 2) : IO BuildBenchResult := do
  let total := warmup + samples
  let mut accNanos : Nat := 0
  let mut minNanos : Nat := 0
  let mut maxNanos : Nat := 0
  let mut vertices : Nat := 0
  let mut triangles : Nat := 0
  let mut checksum : Nat := 0

  for i in [:total] do
    let params' := { params with baseHeight := params.baseHeight + (i % 2) }
    let t0 ← IO.monoNanosNow
    let mesh := Demos.buildVoxelWorldMesh params'
    let checksum' := mesh.indices.foldl (fun acc idx => (acc + idx.toNat) % 1000000007) (0 : Nat)
    let t1 ← IO.monoNanosNow
    let dt := t1 - t0
    let verts := mesh.vertices.size / 10
    let tris := mesh.indices.size / 3
    if i >= warmup then
      accNanos := accNanos + dt
      if minNanos == 0 || dt < minNanos then
        minNanos := dt
      if dt > maxNanos then
        maxNanos := dt
      vertices := verts
      triangles := tris
      checksum := checksum'

  pure {
    samples := samples
    avgNs := if samples == 0 then 0 else accNanos / samples
    minNs := minNanos
    maxNs := maxNanos
    avgMs := avgMs accNanos samples
    minMs := nanosToMs minNanos
    maxMs := nanosToMs maxNanos
    vertices := vertices
    triangles := triangles
    checksum := checksum
  }

testSuite "Voxel Terrain Perf Bench"

test "terrain mesh build timings (greedy vs culled)" := do
  let base : VoxelWorldParams := {
    chunkRadius := 2
    chunkHeight := 24
    baseHeight := 5
    heightRange := 14
    frequency := 0.17
    terraceStep := 1
    showChunkBoundaries := true
    showMesh := false
  }

  let greedyResult ← benchBuildVoxelWorldMesh { base with mesher := .greedy } 1 2
  let culledResult ← benchBuildVoxelWorldMesh { base with mesher := .culled } 1 2

  IO.println (BuildBenchResult.format "terrain build (greedy)" greedyResult)
  IO.println (BuildBenchResult.format "terrain build (culled)" culledResult)
  IO.println s!"greedy / culled time ratio: {fmtMs (ratioOrZero greedyResult.avgMs culledResult.avgMs)}x"

  ensure (greedyResult.triangles > 0) "greedy build should emit triangles"
  ensure (culledResult.triangles > 0) "culled build should emit triangles"

end AfferentDemosTests.VoxelTerrainPerfBench
