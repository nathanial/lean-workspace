/-
  Tabular.Core.Row
  Row representation with column access by index or name
-/
import Tabular.Core.Value

namespace Tabular

/-- A row of values with optional column name mapping -/
structure Row where
  values : Array Value
  /-- Column headers (empty if no headers) -/
  headers : Array String := #[]
  deriving Repr

namespace Row

/-- Create a row with column names from headers -/
def ofArrayWithHeaders (values : Array Value) (headers : Array String) : Row :=
  { values, headers }

/-- Create a row without column names -/
def ofArray (values : Array Value) : Row :=
  { values, headers := #[] }

/-- Get value by column index -/
def get? (row : Row) (idx : Nat) : Option Value :=
  row.values[idx]?

/-- Get value by column name (case-insensitive) -/
def getByName? (row : Row) (name : String) : Option Value :=
  let nameLower := name.toLower
  match row.headers.findIdx? (fun h => h.toLower == nameLower) with
  | some idx => row.values[idx]?
  | none => none

/-- Number of columns -/
def size (row : Row) : Nat := row.values.size

/-- Check if row has named columns -/
def hasHeaders (row : Row) : Bool := !row.headers.isEmpty

/-- Get all column names (if available) -/
def columnNames (row : Row) : Array String := row.headers

instance : ToString Row where
  toString row :=
    let vals := row.values.map (·.content)
    s!"Row({String.intercalate ", " vals.toList})"

end Row

end Tabular
