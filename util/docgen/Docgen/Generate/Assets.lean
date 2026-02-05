/-
  Docgen.Generate.Assets - Static asset handling
-/
import Docgen.Core.Types
import Docgen.Core.Config
import Docgen.Render.Html
import Docgen.Render.Search

namespace Docgen.Generate

/-- Write a file, creating parent directories as needed -/
def writeFile (path : System.FilePath) (content : String) : IO Unit := do
  -- Ensure parent directory exists
  if let some parent := path.parent then
    IO.FS.createDirAll parent
  IO.FS.writeFile path content

/-- Copy the CSS file to output -/
def copyStyles (config : Config) : IO Unit := do
  let cssPath := config.outputDir / "style.css"
  writeFile cssPath Docgen.Render.stylesCss

/-- Write the search JavaScript -/
def writeSearchJs (config : Config) : IO Unit := do
  let jsPath := config.outputDir / "search.js"
  writeFile jsPath Docgen.Render.searchJs

/-- Write search index JSON -/
def writeSearchIndex (config : Config) (project : DocProject) : IO Unit := do
  let indexPath := config.outputDir / "search-index.json"
  let json := Docgen.Render.renderSearchIndex project
  writeFile indexPath json

/-- Initialize output directory -/
def initOutputDir (config : Config) : IO Unit := do
  IO.FS.createDirAll config.outputDir

end Docgen.Generate
