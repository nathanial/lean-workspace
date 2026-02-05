import Crucible
import Tests.WorldmapTests
import Tests.WorldmapPipelineTests
import Wisp

def main : IO UInt32 := do
  Wisp.FFI.globalInit
  try
    runAllSuites
  finally
    Wisp.FFI.globalCleanup
    Wisp.HTTP.Client.shutdown
