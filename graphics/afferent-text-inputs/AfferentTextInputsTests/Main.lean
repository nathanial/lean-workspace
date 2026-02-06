import Crucible
open Crucible

testSuite "afferent-text-inputs"

test "placeholder" := do
  shouldBe (1 + 1) 2

def main : IO UInt32 := runAllSuites
