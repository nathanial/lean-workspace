/-
  Oracle Test Suite
-/

import Crucible
import OracleTests.JsonTests
import OracleTests.RequestTests
import OracleTests.ConfigTests
import OracleTests.ErrorTests
import OracleTests.ResponseTests
import OracleTests.JsonUtilsTests
import OracleTests.ModelTests
import OracleTests.RetryTests
import OracleTests.NewParamsTests
import OracleTests.EndpointTests
import OracleTests.VisionTests
import OracleTests.DeltaTests
import OracleTests.ChatResponseTests
import OracleTests.ReactiveTypesTests
import OracleTests.ChatStreamTests
import OracleTests.ReactiveIntegrationTests
import OracleTests.OpenRouterIntegrationTests
import OracleTests.AgentTests
import OracleTests.AgentTypesTests
import OracleTests.MockClientTests
import OracleTests.AgentResultTests
import OracleTests.StreamAccumulatorTests
import OracleTests.ImageOutputTests

open Crucible

def main : IO UInt32 := do
  let result <- runAllSuites
  _ <- Wisp.FFI.globalCleanup
  _ <- Wisp.HTTP.Client.shutdown
  pure result
