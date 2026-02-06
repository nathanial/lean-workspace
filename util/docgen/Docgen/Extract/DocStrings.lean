/-
  Docgen.Extract.DocStrings - Extract documentation comments from declarations
-/
import Lean
import Docgen.Core.Types

namespace Docgen.Extract

open Lean

/-- Helper to check if string contains substring -/
def containsSubstr (haystack needle : String) : Bool :=
  (haystack.splitOn needle).length > 1

/-- Get the doc string for a declaration (IO version) -/
def getDocStringIO (env : Environment) (name : Name) : IO (Option String) :=
  findDocString? env name

/-- Get the module doc string (/-! ... -/) -/
def getModuleDoc (_env : Environment) (_modName : Name) : Option String :=
  -- Module docs are typically stored in the module
  -- For now, return none - proper extraction requires more work
  none

/-- Clean up a doc string (trim, normalize whitespace) -/
def cleanDocString (doc : String) : String :=
  doc.trim
    |> normalizeIndentation
    |> trimTrailingWhitespace
  where
    normalizeIndentation (s : String) : String :=
      let lines := s.splitOn "\n"
      -- Find minimum indentation (excluding empty lines)
      let minIndent := lines.foldl (init := 1000) fun acc line =>
        if line.trim.isEmpty then acc
        else
          let indent := line.takeWhile (· == ' ') |>.length
          min acc indent
      -- Remove common indentation
      lines.map (fun line =>
        if line.trim.isEmpty then ""
        else line.drop minIndent
      ) |> String.intercalate "\n"

    trimTrailingWhitespace (s : String) : String :=
      s.splitOn "\n"
        |>.map String.trimRight
        |> String.intercalate "\n"

/-- Extract first line of doc string for summaries -/
def getDocSummary (doc : String) : String :=
  let clean := cleanDocString doc
  match clean.splitOn "\n" with
  | first :: _ => first.take 200  -- Limit to 200 chars
  | [] => ""

/-- Check if a doc string contains a specific annotation -/
def hasDocAnnotation (doc : String) (annotation : String) : Bool :=
  containsSubstr doc s!"@{annotation}" ||
  containsSubstr doc s!"[{annotation}]"

/-- Extract doc string for a structure field (IO version) -/
def getFieldDocStringIO (env : Environment) (structName : Name) (fieldName : Name) : IO (Option String) :=
  findDocString? env (structName ++ fieldName)

/-- Extract doc strings for all fields of a structure -/
def getStructureFieldDocsIO (env : Environment) (structName : Name) : IO (Array (Name × Option String)) := do
  let fields := getStructureFields env structName
  let mut result := #[]
  for fieldName in fields do
    let doc ← getFieldDocStringIO env structName fieldName
    result := result.push (fieldName, doc)
  return result

/-- Extract doc string for an inductive constructor (IO version) -/
def getConstructorDocStringIO (env : Environment) (ctorName : Name) : IO (Option String) :=
  findDocString? env ctorName

end Docgen.Extract
