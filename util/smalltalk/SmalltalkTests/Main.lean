/-
  Smalltalk test suite entrypoint.
-/
import Crucible
import SmalltalkTests.ASTTests
import SmalltalkTests.ParserTests
import SmalltalkTests.EvalTests
import SmalltalkTests.MethodTests
import SmalltalkTests.ImageTests

open Crucible

def main : IO UInt32 := do
  IO.println "Smalltalk Tests"
  IO.println "==============="
  runAllSuites
