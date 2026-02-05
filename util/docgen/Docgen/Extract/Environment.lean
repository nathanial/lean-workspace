/-
  Docgen.Extract.Environment - Load and traverse Lean environments
-/
import Lean
import Docgen.Core.Types
import Docgen.Core.Config

namespace Docgen.Extract

open Lean Meta

/-- Result of loading an environment -/
structure EnvLoadResult where
  /-- The loaded environment -/
  env : Environment
  /-- Module name that was imported -/
  mainModule : Name

/-- Load an environment by importing a module -/
def loadEnvFromModule (moduleName : Name) : IO EnvLoadResult := do
  -- Initialize Lean
  Lean.initSearchPath (← Lean.findSysroot)

  -- Import the module
  let env ← importModules #[{ module := moduleName }] {} 0
  return { env, mainModule := moduleName }

/-- Get all constant names from an environment -/
def getConstantNames (env : Environment) : Array Name :=
  env.constants.map₁.toList.map (·.1) |>.toArray

/-- Get the actual module that defined a constant -/
def getModuleFor (env : Environment) (name : Name) : Option Name :=
  match env.getModuleIdxFor? name with
  | some idx => env.header.moduleNames[idx.toNat]?
  | none => none

/-- Check if a module name matches the target prefix -/
def moduleMatchesPrefix (modName : Name) (prefix_ : Name) : Bool :=
  modName == prefix_ || prefix_.isPrefixOf modName

/-- Filter constants based on config and module origin -/
def filterConstants (env : Environment) (config : Config) : Array (Name × ConstantInfo) :=
  env.constants.map₁.toList.toArray.filter fun (name, _) =>
    -- First check config filters (private, internal, etc.)
    if !config.shouldIncludeName name then false
    else
      -- Then check module origin if includeModules is specified
      if config.includeModules.isEmpty then true
      else
        match getModuleFor env name with
        | some modName =>
          config.includeModules.any (moduleMatchesPrefix modName ·)
        | none => false

/-- Check if a name is a structure -/
def isStructure (env : Environment) (name : Name) : Bool :=
  getStructureInfo? env name |>.isSome

/-- Check if a name is a class -/
def isClass (env : Environment) (name : Name) : Bool :=
  -- Check if there's a class instance associated with this name
  match env.find? name with
  | some (.inductInfo ii) => ii.isRec  -- Classes are typically non-recursive
  | _ => false

/-- Classify a constant into an ItemKind -/
def classifyConstant (env : Environment) (info : ConstantInfo) : ItemKind :=
  match info with
  | .axiomInfo _ => .axiom_
  | .thmInfo _ => .theorem_
  | .defnInfo di =>
    if isStructure env di.name then .structure_
    else .def_
  | .inductInfo ii =>
    if isStructure env ii.name then .structure_
    else .inductive_
  | .ctorInfo _ => .def_
  | .recInfo _ => .def_
  | .quotInfo _ => .axiom_
  | .opaqueInfo _ => .def_

/-- Group declarations by their module -/
def groupByModule (env : Environment) (constants : Array (Name × ConstantInfo))
    : Std.HashMap Name (Array (Name × ConstantInfo)) := Id.run do
  let mut result : Std.HashMap Name (Array (Name × ConstantInfo)) := {}

  for (name, info) in constants do
    let modName := getModuleFor env name |>.getD name.getPrefix
    let existing := result.getD modName #[]
    result := result.insert modName (existing.push (name, info))

  return result

end Docgen.Extract
