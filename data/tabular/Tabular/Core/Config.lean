/-
  Tabular.Core.Config
  Parser configuration for CSV/TSV parsing
-/

namespace Tabular

/-- Configuration for CSV/TSV parsing -/
structure Config where
  /-- Field delimiter character (default: comma) -/
  delimiter : Char := ','
  /-- Quote character for escaping fields (default: double quote) -/
  quote : Char := '"'
  /-- Whether the first row contains headers -/
  hasHeader : Bool := true
  /-- Whether to trim leading/trailing whitespace from unquoted fields -/
  trimWhitespace : Bool := false
  /-- Whether to allow rows with fewer columns than header -/
  allowRagged : Bool := false
  deriving Repr, Inhabited, BEq

namespace Config

/-- Default CSV configuration -/
def csv : Config := {}

/-- Default TSV configuration -/
def tsv : Config := { delimiter := '\t' }

/-- Pipe-separated values configuration -/
def psv : Config := { delimiter := '|' }

/-- Semicolon-separated values (European CSV) -/
def scsv : Config := { delimiter := ';' }

/-- Create config with custom delimiter -/
def withDelimiter (c : Char) : Config := { delimiter := c }

/-- Create config without headers -/
def noHeaders : Config := { hasHeader := false }

end Config

end Tabular
