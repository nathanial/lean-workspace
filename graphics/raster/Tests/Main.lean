import Crucible
import Tests.TypeTests
import Tests.TransformTests

open Crucible

def main : IO UInt32 := do
  IO.println "Raster Library Tests"
  IO.println "===================="
  runAllSuites
