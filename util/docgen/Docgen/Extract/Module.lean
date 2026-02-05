/-
  Docgen.Extract.Module - Module-level extraction and organization
-/
import Lean
import Docgen.Core.Types
import Docgen.Core.Config
import Docgen.Extract.Environment
import Docgen.Extract.DocStrings
import Docgen.Extract.Signatures

namespace Docgen.Extract

open Lean

/-- Extract a DocItem from a constant -/
def extractDocItem (env : Environment) (name : Name) (info : ConstantInfo) : IO DocItem := do
  let kind := classifyConstant env info
  let signature := ppConstantSignature env name
  let docString ← getDocStringIO env name
  let cleanDoc := docString.map cleanDocString
  return {
    name := name
    kind := kind
    signature := signature
    docString := cleanDoc
    sourceFile := none
    sourceLine := none
    visibility := .public_
  }

/-- Extract all items for a module -/
def extractModuleItems (env : Environment) (config : Config) (modName : Name)
    (constants : Array (Name × ConstantInfo)) : IO (Array DocItem) := do
  let mut items := #[]

  for (name, info) in constants do
    -- Skip constructors and recursors (shown with their parent)
    if name.isInternal then continue
    let nameStr := name.toString
    if nameStr.endsWith ".rec" then continue
    if nameStr.endsWith ".mk" && isStructure env name.getPrefix then continue

    -- Skip if doesn't pass config filters
    if !config.shouldIncludeName name then continue

    let item ← extractDocItem env name info
    items := items.push item

  -- Sort by name for consistent output
  return items.qsort (fun a b => a.name.toString < b.name.toString)

/-- Extract a DocModule -/
def extractModule (env : Environment) (config : Config) (modName : Name)
    (constants : Array (Name × ConstantInfo)) : IO DocModule := do
  let moduleDoc := getModuleDoc env modName |>.map cleanDocString
  let items ← extractModuleItems env config modName constants
  return {
    name := modName
    moduleDoc := moduleDoc
    items := items
    submodules := #[]  -- Filled in later
  }

/-- Build module hierarchy from flat module list -/
def buildModuleHierarchy (modules : Array DocModule) : Array DocModule := Id.run do
  let mut result := modules

  -- Build parent-child relationships
  let moduleNames := modules.map (·.name) |>.toList

  for i in [:result.size] do
    let mod := result[i]!
    let children := moduleNames.filter fun child =>
      child != mod.name &&
      child.getPrefix == mod.name
    result := result.set! i { mod with submodules := children.toArray }

  return result

/-- Extract complete project documentation -/
def extractProject (env : Environment) (config : Config) (projectName : String) : IO DocProject := do
  -- Get all constants filtered by config
  let allConstants := filterConstants env config

  -- Group by module
  let grouped := groupByModule env allConstants

  -- Extract each module
  let mut modules := #[]
  for (modName, constants) in grouped.toArray do
    if config.shouldIncludeModule modName then
      let mod ← extractModule env config modName constants
      if mod.hasItems then
        modules := modules.push mod

  -- Sort modules alphabetically
  let sortedModules := modules.qsort (fun a b => a.name.toString < b.name.toString)

  -- Build hierarchy
  let finalModules := buildModuleHierarchy sortedModules

  return {
    name := projectName
    version := none
    modules := finalModules
  }

/-- Count statistics about extracted documentation -/
structure DocStats where
  moduleCount : Nat
  itemCount : Nat
  documentedItems : Nat
  undocumentedItems : Nat
  deriving Repr

def computeStats (project : DocProject) : DocStats := Id.run do
  let mut itemCount := 0
  let mut documented := 0

  for mod in project.modules do
    itemCount := itemCount + mod.items.size
    for item in mod.items do
      if item.docString.isSome then
        documented := documented + 1

  return {
    moduleCount := project.modules.size
    itemCount := itemCount
    documentedItems := documented
    undocumentedItems := itemCount - documented
  }

end Docgen.Extract
