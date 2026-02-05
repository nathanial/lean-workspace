import Crucible
import RasterTests.TypeTests
import RasterTests.TransformTests

open Crucible

def main : IO UInt32 := do
  IO.println "Raster Library Tests"
  IO.println "===================="
  runAllSuites
