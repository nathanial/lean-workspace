/-
  Docgen.Core.Config - Configuration for documentation generation
-/
import Lean

namespace Docgen

/-- Configuration for documentation generation -/
structure Config where
  /-- Project root directory (contains lakefile.lean) -/
  projectRoot : System.FilePath
  /-- Output directory for generated docs -/
  outputDir : System.FilePath := "docs"
  /-- Project title (auto-detected from lakefile if not specified) -/
  title : Option String := none
  /-- Include private declarations -/
  includePrivate : Bool := false
  /-- Include internal names (e.g., proof terms, auxiliary definitions) -/
  includeInternal : Bool := false
  /-- Source repository URL for source links (e.g., GitHub) -/
  sourceUrl : Option String := none
  /-- Branch/tag for source links -/
  sourceBranch : String := "main"
  /-- Modules to include (empty = all) -/
  includeModules : Array Lean.Name := #[]
  /-- Modules to exclude -/
  excludeModules : Array Lean.Name := #[]
  deriving Repr, Inhabited

namespace Config

/-- Default configuration for current directory -/
def default : Config := {
  projectRoot := "."
}

/-- Check if a module should be included based on config -/
def shouldIncludeModule (config : Config) (name : Lean.Name) : Bool :=
  let included := config.includeModules.isEmpty ||
                  config.includeModules.any (fun m => name.toString.startsWith m.toString)
  let excluded := config.excludeModules.any (fun m => name.toString.startsWith m.toString)
  included && !excluded

/-- Helper to check if string contains substring -/
private def containsSubstr (haystack needle : String) : Bool :=
  (haystack.splitOn needle).length > 1

/-- Check if a name should be included based on visibility settings -/
def shouldIncludeName (config : Config) (name : Lean.Name) : Bool :=
  -- Skip internal names unless configured
  if name.isInternal && !config.includeInternal then false
  -- Skip private names unless configured
  else if isPrivateName name && !config.includePrivate then false
  else true
  where
    isPrivateName (n : Lean.Name) : Bool :=
      let s := n.toString
      containsSubstr s "_private_" || containsSubstr s "._"

/-- Get the effective title -/
def getTitle (config : Config) : String :=
  config.title.getD (config.projectRoot.fileName.getD "Documentation")

/-- Build source URL for a file and line -/
def buildSourceUrl (config : Config) (file : String) (line : Nat) : Option String :=
  config.sourceUrl.map fun baseUrl =>
    let cleanFile := if file.startsWith "./" then file.drop 2 else file
    s!"{baseUrl}/blob/{config.sourceBranch}/{cleanFile}#L{line}"

end Config

end Docgen
