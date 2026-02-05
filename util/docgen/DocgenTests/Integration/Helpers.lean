/-
  Tests.Integration.Helpers - Shared utilities for integration tests
-/
import Docgen
import Crucible

namespace DocgenTests.Integration

open Docgen
open Crucible

/-- Temp directory for test output -/
structure TempDir where
  path : System.FilePath
  deriving Repr, Inhabited

/-- Create a unique temp directory for test output -/
def TempDir.create (namePrefix : String := "docgen-test") : IO TempDir := do
  let timestamp ← IO.monoMsNow
  let path : System.FilePath := s!"/tmp/{namePrefix}-{timestamp}"
  IO.FS.createDirAll path
  return { path := path }

/-- Recursively remove a directory -/
partial def removeRecursive (path : System.FilePath) : IO Unit := do
  if ← path.isDir then
    let entries ← System.FilePath.readDir path
    for entry in entries do
      removeRecursive entry.path
    IO.FS.removeDir path
  else
    IO.FS.removeFile path

/-- Remove temp directory and all contents -/
def TempDir.cleanup (td : TempDir) : IO Unit := do
  try
    removeRecursive td.path
  catch _ => pure ()  -- Ignore cleanup errors

/-- Check if a file exists -/
def fileExists (path : System.FilePath) : IO Bool := do
  try
    let _ ← IO.FS.readFile path
    return true
  catch _ => return false

/-- Create a test config with temp output directory -/
def mkTestConfig (projectRoot : String) (outputDir : System.FilePath)
    (title : String := "Test Project") : Config := {
  projectRoot := projectRoot
  outputDir := outputDir
  title := some title
  includePrivate := false
  includeInternal := false
}

end DocgenTests.Integration
