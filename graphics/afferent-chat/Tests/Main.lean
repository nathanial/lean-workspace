import Crucible
import AfferentChat.Tests.ChatTests

open Crucible

def main : IO UInt32 := do
  IO.println "╔════════════════════════════════════════╗"
  IO.println "║       Afferent Chat Test Suite         ║"
  IO.println "╚════════════════════════════════════════╝"

  let exitCode ← runAllSuites

  IO.println ""
  if exitCode == 0 then
    IO.println "✓ All chat tests passed!"
  else
    IO.println "✗ Some chat tests failed"

  return if exitCode > 0 then 1 else 0
