/-
  Tests.Integration.ChronosTests - Integration tests with Chronos project

  Note: These tests require LEAN_PATH to include Chronos build output.
  Run with test.sh to ensure proper setup.
-/
import Crucible
import Docgen
import Tests.Integration.Helpers
import Staple

namespace Tests.Integration.Chronos

open Crucible
open Docgen
open Docgen.Extract
open Docgen.Generate
open Tests.Integration

-- Shared test state (use initialize for single shared IORefs)
initialize tempDirRef : IO.Ref (Option TempDir) ← IO.mkRef none
initialize envRef : IO.Ref (Option EnvLoadResult) ← IO.mkRef none

testSuite "Docgen.Integration.Chronos"

-- Setup: create temp directory and load Chronos environment
beforeAll := do
  let td ← TempDir.create "chronos-test"
  tempDirRef.set (some td)

  -- Try to load Chronos environment
  -- This will fail if LEAN_PATH is not set correctly
  try
    let result ← loadEnvFromModule `Chronos
    envRef.set (some result)
  catch e =>
    IO.eprintln s!"Warning: Could not load Chronos environment: {e}"
    IO.eprintln "Ensure LEAN_PATH includes Chronos build output."
    IO.eprintln "Run tests with: ./test.sh"

-- Teardown: cleanup temp directory
afterAll := do
  match ← tempDirRef.get with
  | some td => TempDir.cleanup td
  | none => pure ()

/-- Helper to get the loaded environment or skip test -/
def getChronosEnv : IO EnvLoadResult := do
  match ← envRef.get with
  | some env => return env
  | none => throw <| IO.userError "Chronos environment not loaded (LEAN_PATH not set?)"

test "loadEnvFromModule succeeds for Chronos" := do
  let result ← getChronosEnv
  result.mainModule ≡ `Chronos

test "extractProject finds Chronos submodules" := do
  let result ← getChronosEnv
  let td := (← tempDirRef.get).get!
  let config := mkTestConfig "." td.path "Chronos"

  let project ← extractProject result.env config "Chronos"

  -- Chronos has multiple submodules
  let moduleNames := project.modules.map (·.name.toString)

  -- Should find Duration, Timestamp, etc.
  let hasDuration := moduleNames.toList.any (Staple.String.containsSubstr · "Duration")
  let hasTimestamp := moduleNames.toList.any (Staple.String.containsSubstr · "Timestamp")

  shouldSatisfy hasDuration "should have Duration module"
  shouldSatisfy hasTimestamp "should have Timestamp module"

test "Chronos has many documented items" := do
  let result ← getChronosEnv
  let td := (← tempDirRef.get).get!
  let config := mkTestConfig "." td.path "Chronos"

  let project ← extractProject result.env config "Chronos"

  -- Count items
  let stats := computeStats project

  -- Chronos should have significant content
  shouldSatisfy (stats.itemCount >= 5) s!"should have at least 5 items (got {stats.itemCount})"

test "ItemKind classification finds structures" := do
  let result ← getChronosEnv
  let td := (← tempDirRef.get).get!
  let config := mkTestConfig "." td.path "Chronos"

  let project ← extractProject result.env config "Chronos"

  -- Find structure items
  let structures := project.modules.foldl (init := #[]) fun acc mod =>
    acc ++ mod.items.filter (·.kind == .structure_)

  -- Should find Duration, Timestamp, DateTime as structures
  shouldSatisfy (structures.size >= 1) s!"should find at least 1 structure (got {structures.size})"

test "includePrivate option includes more items" := do
  let result ← getChronosEnv
  let td := (← tempDirRef.get).get!

  -- Config without private
  let configNoPrivate := {
    mkTestConfig "." td.path "Chronos" with
    includePrivate := false
  }
  let projectNoPrivate ← extractProject result.env configNoPrivate "Chronos"
  let countNoPrivate := projectNoPrivate.modules.foldl (init := 0) (· + ·.items.size)

  -- Config with private
  let configWithPrivate := {
    mkTestConfig "." td.path "Chronos" with
    includePrivate := true
  }
  let projectWithPrivate ← extractProject result.env configWithPrivate "Chronos"
  let countWithPrivate := projectWithPrivate.modules.foldl (init := 0) (· + ·.items.size)

  -- With private should have >= items than without
  shouldSatisfy (countWithPrivate >= countNoPrivate)
    s!"includePrivate should include more or equal items ({countWithPrivate} >= {countNoPrivate})"



end Tests.Integration.Chronos
