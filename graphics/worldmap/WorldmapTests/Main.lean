/-
  Worldmap Test Suite
  Main entry point for running all tests.
-/
import WorldmapTests.TileCoord
import WorldmapTests.TileProvider
import WorldmapTests.Viewport
import WorldmapTests.Zoom
import WorldmapTests.RetryLogic
import WorldmapTests.TileCache
import WorldmapTests.Utils
import WorldmapTests.KeyCode
import WorldmapTests.Overlay
import WorldmapTests.Marker
import WorldmapTests.Prefetch
import WorldmapTests.RequestCoalescing
import Crucible

open Crucible

def main : IO UInt32 := do
  IO.println "Worldmap Test Suite"
  IO.println "==================="
  IO.println ""

  let result ← runAllSuites

  IO.println ""
  IO.println "==================="

  if result != 0 then
    IO.println "Some tests failed!"
    return 1
  else
    IO.println "All tests passed!"
    return 0
