/-
  Config endpoint tests
-/

import Crucible
import Oracle

namespace OracleTests.EndpointTests

open Crucible
open Oracle

testSuite "Config Endpoints"

test "Config.modelsEndpoint returns correct URL" := do
  let cfg := Config.simple "key"
  shouldBe cfg.modelsEndpoint "https://openrouter.ai/api/v1/models"

end OracleTests.EndpointTests
