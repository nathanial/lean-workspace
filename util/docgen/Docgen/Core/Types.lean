/-
  Docgen.Core.Types - Core data structures for documentation representation
-/
import Lean

namespace Docgen

/-- Kind of documented item -/
inductive ItemKind where
  | def_          -- def, abbrev
  | theorem_      -- theorem, lemma
  | structure_    -- structure
  | inductive_    -- inductive type
  | class_        -- class (typeclass)
  | instance_     -- instance declaration
  | axiom_        -- axiom, constant
  deriving Repr, BEq, Hashable, Inhabited

/-- Visibility of a declaration -/
inductive Visibility where
  | public_
  | protected_
  | private_
  deriving Repr, BEq, Inhabited

/-- A documented declaration -/
structure DocItem where
  /-- Fully qualified name -/
  name : Lean.Name
  /-- Kind of item -/
  kind : ItemKind
  /-- Pretty-printed type signature -/
  signature : String
  /-- Doc comment (if any) -/
  docString : Option String := none
  /-- Source file location -/
  sourceFile : Option String := none
  /-- Line number -/
  sourceLine : Option Nat := none
  /-- Visibility level -/
  visibility : Visibility := .public_
  deriving Repr, Inhabited

/-- Structure field information -/
structure FieldInfo where
  /-- Field name -/
  name : String
  /-- Pretty-printed type -/
  type : String
  /-- Field doc comment -/
  docString : Option String := none
  deriving Repr, Inhabited

/-- Extended info for structures -/
structure StructureInfo where
  /-- Structure fields -/
  fields : Array FieldInfo := #[]
  /-- Parent structures (for extends) -/
  parents : Array Lean.Name := #[]
  deriving Repr, Inhabited

/-- Constructor information for inductives -/
structure ConstructorInfo where
  /-- Constructor name -/
  name : Lean.Name
  /-- Pretty-printed type -/
  type : String
  /-- Constructor doc comment -/
  docString : Option String := none
  deriving Repr, Inhabited

/-- Extended info for inductives -/
structure InductiveInfo where
  /-- Constructors -/
  constructors : Array ConstructorInfo := #[]
  deriving Repr, Inhabited

/-- A documented module -/
structure DocModule where
  /-- Module name (e.g., `Docgen.Core`) -/
  name : Lean.Name
  /-- Module-level doc comment (/-! ... -/) -/
  moduleDoc : Option String := none
  /-- Items in this module -/
  items : Array DocItem := #[]
  /-- Direct submodule names -/
  submodules : Array Lean.Name := #[]
  deriving Repr, Inhabited

/-- Complete project documentation -/
structure DocProject where
  /-- Project name -/
  name : String
  /-- Project version -/
  version : Option String := none
  /-- All documented modules -/
  modules : Array DocModule := #[]
  deriving Repr, Inhabited

namespace ItemKind

/-- Convert to display string -/
def toString : ItemKind -> String
  | .def_ => "def"
  | .theorem_ => "theorem"
  | .structure_ => "structure"
  | .inductive_ => "inductive"
  | .class_ => "class"
  | .instance_ => "instance"
  | .axiom_ => "axiom"

/-- CSS class name for styling -/
def cssClass : ItemKind -> String
  | .def_ => "def"
  | .theorem_ => "theorem"
  | .structure_ => "structure"
  | .inductive_ => "inductive"
  | .class_ => "class"
  | .instance_ => "instance"
  | .axiom_ => "axiom"

instance : ToString ItemKind := ⟨toString⟩

end ItemKind

namespace DocItem

/-- Get the short name (last component) -/
def shortName (item : DocItem) : String :=
  match item.name.componentsRev with
  | n :: _ => n.toString
  | [] => item.name.toString

/-- Generate HTML anchor ID -/
def anchorId (item : DocItem) : String :=
  item.name.toString.replace "." "-"

end DocItem

namespace DocModule

/-- Get the short name (last component) -/
def shortName (mod : DocModule) : String :=
  match mod.name.componentsRev with
  | n :: _ => n.toString
  | [] => mod.name.toString

/-- Convert module name to file path -/
def toFilePath (mod : DocModule) : String :=
  mod.name.toString.replace "." "/" ++ ".html"

/-- Check if module has any documented items -/
def hasItems (mod : DocModule) : Bool :=
  !mod.items.isEmpty || mod.moduleDoc.isSome

end DocModule

end Docgen
