/-
  Docgen.Generate.Site - Static site generation orchestrator
-/
import Docgen.Core.Types
import Docgen.Core.Config
import Docgen.Extract.Module
import Docgen.Render.Html
import Docgen.Render.Navigation
import Docgen.Render.Search
import Docgen.Generate.Assets

namespace Docgen.Generate

open Docgen.Render
open Docgen.Extract

/-- Statistics about generated site -/
structure GenerateStats where
  pageCount : Nat
  moduleCount : Nat
  itemCount : Nat
  outputDir : System.FilePath
  deriving Repr

/-- Generate a single module page -/
def generateModulePage (project : DocProject) (mod : DocModule) (config : Config) : IO String := do
  let sidebar := renderSidebar project (some mod.name)
  let page := renderModulePage mod project config sidebar
  return buildPage page

/-- Generate the index page -/
def generateIndexPage (project : DocProject) (config : Config) : IO String := do
  let sidebar := renderSidebar project none
  let page := renderIndexPage project config sidebar
  return buildPage page

/-- Generate all pages for a project -/
def generatePages (project : DocProject) (config : Config) : IO GenerateStats := do
  -- Initialize output directory
  initOutputDir config

  -- Write assets
  copyStyles config
  writeSearchJs config
  writeSearchIndex config project

  -- Write index page
  let indexHtml ← generateIndexPage project config
  writeFile (config.outputDir / "index.html") indexHtml

  let mut pageCount := 1
  let mut itemCount := 0

  -- Write module pages
  for mod in project.modules do
    if mod.hasItems then
      let html ← generateModulePage project mod config

      -- Create subdirectories as needed
      let filePath := config.outputDir / mod.toFilePath
      writeFile filePath html

      pageCount := pageCount + 1
      itemCount := itemCount + mod.items.size

  return {
    pageCount := pageCount
    moduleCount := project.modules.size
    itemCount := itemCount
    outputDir := config.outputDir
  }

/-- Main generation entry point -/
def generate (config : Config) : IO (Except String GenerateStats) := do
  try
    -- Detect project name from lakefile
    let projectName := config.getTitle

    -- For now, we need to load an already-built environment
    -- This requires the project to be built first with `lake build`
    IO.eprintln s!"Generating documentation for: {projectName}"
    IO.eprintln s!"Output directory: {config.outputDir}"

    -- TODO: Actually load the environment and extract docs
    -- For now, create a stub project to test rendering
    let stubProject : DocProject := {
      name := projectName
      version := some "0.0.1"
      modules := #[]
    }

    let stats ← generatePages stubProject config

    IO.eprintln s!"Generated {stats.pageCount} pages"
    return .ok stats

  catch e =>
    return .error s!"Generation failed: {e}"

/-- Generate docs from an already-loaded environment -/
def generateFromEnv (env : Lean.Environment) (config : Config) : IO (Except String GenerateStats) := do
  try
    let projectName := config.getTitle

    IO.eprintln s!"Extracting documentation..."

    -- Extract project documentation
    let project ← extractProject env config projectName

    let stats := computeStats project
    IO.eprintln s!"Found {stats.moduleCount} modules, {stats.itemCount} items"
    IO.eprintln s!"Documented: {stats.documentedItems}, Undocumented: {stats.undocumentedItems}"

    IO.eprintln s!"Generating HTML..."

    let genStats ← generatePages project config

    IO.eprintln s!"Done! Generated {genStats.pageCount} pages in {config.outputDir}"

    return .ok genStats

  catch e =>
    return .error s!"Generation failed: {e}"

end Docgen.Generate
