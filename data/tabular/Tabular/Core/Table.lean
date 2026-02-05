/-
  Tabular.Core.Table
  Full parsed table representation
-/
import Tabular.Core.Row
import Tabular.Core.Config

namespace Tabular

/-- A parsed table with optional headers and rows -/
structure Table where
  /-- Column headers (empty array if no headers) -/
  headers : Array String
  /-- Data rows -/
  rows : Array Row
  /-- Configuration used for parsing -/
  config : Config
  deriving Repr

namespace Table

/-- Number of data rows -/
def rowCount (t : Table) : Nat := t.rows.size

/-- Number of columns (based on headers or first row) -/
def columnCount (t : Table) : Nat :=
  if t.headers.isEmpty then
    t.rows[0]?.map (·.size) |>.getD 0
  else
    t.headers.size

/-- Check if table has headers -/
def hasHeaders (t : Table) : Bool := !t.headers.isEmpty

/-- Get a row by index -/
def row? (t : Table) (idx : Nat) : Option Row := t.rows[idx]?

/-- Get all values in a column by index -/
def column (t : Table) (idx : Nat) : Array Value :=
  t.rows.filterMap (·.get? idx)

/-- Get all values in a column by name -/
def columnByName (t : Table) (name : String) : Array Value :=
  t.rows.filterMap (·.getByName? name)

/-- Iterate over rows -/
def forRows (t : Table) (f : Row → IO Unit) : IO Unit :=
  t.rows.forM f

/-- Empty table -/
def empty (config : Config := Config.csv) : Table :=
  { headers := #[], rows := #[], config }

instance : ToString Table where
  toString t :=
    let headerLine := if t.hasHeaders
      then s!"Headers: {t.headers.toList}\n"
      else ""
    let rowLines := t.rows.mapIdx fun i row => s!"  [{i}] {row}"
    s!"{headerLine}Rows ({t.rowCount}):\n{String.intercalate "\n" rowLines.toList}"

end Table

end Tabular
