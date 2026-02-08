import Crucible
import AfferentCharts.Tests.ChartPerformanceTests

open Crucible

def main : IO UInt32 := do
  IO.println "╔════════════════════════════════════════╗"
  IO.println "║     Afferent Charts Test Suite         ║"
  IO.println "╚════════════════════════════════════════╝"

  let exitCode ← runAllSuites

  IO.println ""
  if exitCode == 0 then
    IO.println "✓ All chart tests passed!"
  else
    IO.println "✗ Some chart tests failed"

  return if exitCode > 0 then 1 else 0
