/-
  Docgen.CLI - Command-line interface using Parlance
-/
import Parlance
import Docgen.Core.Config
import Docgen.Generate.Site

namespace Docgen.CLI

open Parlance

/-- Define the docgen command -/
def cmd : Command := command "docgen" do
  Cmd.version "0.0.1"
  Cmd.description "Generate documentation for Lean 4 projects"

  -- Build subcommand
  Cmd.subcommand "build" do
    Cmd.description "Generate documentation from a Lean project"

    Cmd.arg "path" (argType := .path) (required := false)
      (description := "Project root directory (default: current directory)")

    Cmd.flag "output" (short := some 'o') (argType := .path)
      (description := "Output directory (default: ./docs)")

    Cmd.flag "title" (argType := .string)
      (description := "Project title (default: detected from lakefile)")

    Cmd.boolFlag "include-private"
      (description := "Include private declarations")

    Cmd.boolFlag "include-internal"
      (description := "Include internal/auxiliary definitions")

    Cmd.flag "source-url" (argType := .string)
      (description := "Repository URL for source links (e.g., https://github.com/user/repo)")

    Cmd.flag "source-branch" (argType := .string)
      (description := "Branch/tag for source links (default: main)")

/-- Parse config from command-line arguments -/
def parseConfig (result : ParseResult) : Config := {
  projectRoot := result.getString! "path" "."
  outputDir := result.getString! "output" "docs"
  title := result.getString "title"
  includePrivate := result.hasFlag "include-private"
  includeInternal := result.hasFlag "include-internal"
  sourceUrl := result.getString "source-url"
  sourceBranch := result.getString! "source-branch" "main"
}

/-- Run the build subcommand -/
def runBuild (result : ParseResult) : IO UInt32 := do
  let config := parseConfig result

  printInfo s!"Generating docs for: {config.projectRoot}"
  printInfo s!"Output directory: {config.outputDir}"

  match ← Generate.generate config with
  | .ok stats =>
    printSuccess s!"Generated {stats.pageCount} pages"
    printSuccess s!"Output: {stats.outputDir}"
    return 0
  | .error err =>
    printError err
    return 1

/-- Main entry point -/
def run (args : List String) : IO UInt32 := do
  match parse cmd args with
  | .ok result =>
    match result.commandPath with
    | ["build"] => runBuild result
    | _ =>
      -- No subcommand - show help
      IO.println cmd.helpText
      return 0
  | .error .helpRequested =>
    IO.println cmd.helpText
    return 0
  | .error .versionRequested =>
    IO.println "docgen 0.0.1"
    return 0
  | .error err =>
    printError err.toString
    return 1

end Docgen.CLI
