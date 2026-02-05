/-
  Tests.Integration.StapleTests - Integration tests with Staple project

  Staple is already a docgen dependency, so its environment is available
  without special LEAN_PATH configuration.
-/
import Crucible
import Docgen
import Tests.Integration.Helpers

namespace Tests.Integration.Staple

open Crucible
open Docgen
open Docgen.Extract
open Docgen.Generate
open Tests.Integration

-- Shared test state (use initialize for a single shared IORef)
initialize tempDirRef : IO.Ref (Option TempDir) ← IO.mkRef none

testSuite "Docgen.Integration.Staple"

-- Setup: create temp directory
beforeAll := do
  let td ← TempDir.create "staple-test"
  tempDirRef.set (some td)

-- Teardown: cleanup temp directory
afterAll := do
  match ← tempDirRef.get with
  | some td => TempDir.cleanup td
  | none => pure ()

test "loadEnvFromModule succeeds for Staple" := do
  let result ← loadEnvFromModule `Staple
  result.mainModule ≡ `Staple

test "extractProject finds Staple modules" := do
  let result ← loadEnvFromModule `Staple
  let td := (← tempDirRef.get).get!
  let config := mkTestConfig "." td.path "Staple"

  let project ← extractProject result.env config "Staple"

  -- Should have at least one module
  shouldSatisfy (project.modules.size > 0) "should have at least one module"

  -- Project name should match
  project.name ≡ "Staple"

test "extractProject finds items from Staple" := do
  let result ← loadEnvFromModule `Staple
  let td := (← tempDirRef.get).get!
  let config := mkTestConfig "." td.path "Staple"

  let project ← extractProject result.env config "Staple"

  -- Count total items across all modules
  let totalItems := project.modules.foldl (init := 0) (· + ·.items.size)
  shouldSatisfy (totalItems > 0) "should have at least one item"

test "generateFromEnv produces HTML files" := do
  let result ← loadEnvFromModule `Staple
  let td := (← tempDirRef.get).get!

  -- Filter to only Staple modules to avoid processing all transitive deps
  let config : Config := {
    projectRoot := "."
    outputDir := td.path
    title := some "Staple"
    includeModules := #[`Staple]
  }

  let genResult ← generateFromEnv result.env config
  let stats ← shouldBeOk genResult "generateFromEnv"

  -- Check that files were generated
  shouldSatisfy (stats.pageCount > 0) "should generate at least one page"

  -- Verify index.html exists
  let indexExists ← fileExists (td.path / "index.html")
  shouldSatisfy indexExists "index.html should exist"

  -- Verify style.css exists
  let styleExists ← fileExists (td.path / "style.css")
  shouldSatisfy styleExists "style.css should exist"

test "generated HTML contains expected content" := do
  let result ← loadEnvFromModule `Staple
  let td := (← tempDirRef.get).get!

  let config : Config := {
    projectRoot := "."
    outputDir := td.path
    title := some "Staple"
    includeModules := #[`Staple]
  }

  let _ ← generateFromEnv result.env config

  -- Read index.html and verify it contains expected content
  let indexContent ← IO.FS.readFile (td.path / "index.html")
  shouldContainSubstr indexContent "<!DOCTYPE html>"
  shouldContainSubstr indexContent "Staple"



end Tests.Integration.Staple
