/-
  Docgen.Extract.Signatures - Pretty-print type signatures
-/
import Lean
import Docgen.Core.Types

namespace Docgen.Extract

open Lean

/-- Options for signature pretty-printing -/
structure SignatureOptions where
  /-- Maximum line width -/
  maxWidth : Nat := 100
  /-- Show implicit arguments -/
  showImplicits : Bool := false
  /-- Show universe levels -/
  showUniverses : Bool := false
  deriving Inhabited

/-- Pretty-print a constant's signature (simple version) -/
def ppConstantSignature (env : Environment) (name : Name) : String :=
  match env.find? name with
  | some info => toString info.type
  | none => s!"<not found: {name}>"

/-- Format a signature with the declaration name -/
def formatSignature (name : Name) (kind : ItemKind) (signature : String) : String :=
  let kindStr := kind.toString
  let nameStr := name.toString
  s!"{kindStr} {nameStr} : {signature}"

/-- Get a short signature (first line only) -/
def shortSignature (signature : String) : String :=
  match signature.splitOn "\n" with
  | first :: _ => first
  | [] => signature

/-- Pretty-print structure fields -/
def ppStructureFields (env : Environment) (structName : Name) : Array (String × String) := Id.run do
  let fields := getStructureFields env structName
  let mut result := #[]
  for field in fields do
    -- Get the projection function type
    let projName := structName ++ field
    match env.find? projName with
    | some info =>
      result := result.push (field.toString, toString info.type)
    | none => continue
  return result

/-- Pretty-print inductive constructors -/
def ppInductiveConstructors (env : Environment) (indName : Name) : Array (Name × String) := Id.run do
  match env.find? indName with
  | some (.inductInfo ii) =>
    let mut result := #[]
    for ctorName in ii.ctors do
      match env.find? ctorName with
      | some ctorInfo =>
        result := result.push (ctorName, toString ctorInfo.type)
      | none => continue
    return result
  | _ => return #[]

end Docgen.Extract
