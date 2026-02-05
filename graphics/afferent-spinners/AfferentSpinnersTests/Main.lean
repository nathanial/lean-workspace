import Crucible

open Crucible

testSuite "afferent-spinners"

test "placeholder" := do
  shouldBe (1 + 1) 2

def main : IO UInt32 := runAllSuites
