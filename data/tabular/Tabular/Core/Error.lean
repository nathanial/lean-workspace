/-
  Tabular.Core.Error
  Parse errors and extraction errors with position tracking
-/

namespace Tabular

/-- Position in CSV source for error messages -/
structure Position where
  offset : Nat      -- Byte offset from start
  line : Nat        -- 1-based line number
  column : Nat      -- 1-based column number
  deriving Repr, BEq, Inhabited

instance : ToString Position where
  toString p := s!"line {p.line}, column {p.column}"

/-- Parse errors with position and context -/
inductive ParseError where
  | unexpectedChar (pos : Position) (char : Char) (expected : String)
  | unexpectedEnd (context : String)
  | unclosedQuote (pos : Position)
  | invalidEscape (pos : Position) (char : Char)
  | columnMismatch (pos : Position) (expected : Nat) (actual : Nat)
  | emptyInput
  | other (pos : Position) (msg : String)
  deriving Repr, BEq, Inhabited

namespace ParseError

def position : ParseError → Option Position
  | unexpectedChar pos _ _ => some pos
  | unexpectedEnd _ => none
  | unclosedQuote pos => some pos
  | invalidEscape pos _ => some pos
  | columnMismatch pos _ _ => some pos
  | emptyInput => none
  | other pos _ => some pos

end ParseError

instance : ToString ParseError where
  toString e := match e with
    | .unexpectedChar pos c exp =>
        s!"{pos}: unexpected character '{c}', expected {exp}"
    | .unexpectedEnd ctx =>
        s!"unexpected end of input while parsing {ctx}"
    | .unclosedQuote pos =>
        s!"{pos}: unclosed quoted field"
    | .invalidEscape pos c =>
        s!"{pos}: invalid escape sequence '{c}'"
    | .columnMismatch pos expected actual =>
        s!"{pos}: expected {expected} columns, found {actual}"
    | .emptyInput =>
        "empty input"
    | .other pos msg =>
        s!"{pos}: {msg}"

/-- Result type for parsing operations -/
abbrev ParseResult (α : Type) := Except ParseError α

/-- Extraction errors for type conversion failures -/
inductive ExtractError where
  | typeConversion (value : String) (targetType : String)
  | columnNotFound (name : String)
  | indexOutOfBounds (index : Nat) (size : Nat)
  | emptyValue (column : String)
  deriving Repr, BEq

instance : ToString ExtractError where
  toString e := match e with
    | .typeConversion val typ => s!"cannot convert '{val}' to {typ}"
    | .columnNotFound name => s!"column not found: {name}"
    | .indexOutOfBounds idx sz => s!"index {idx} out of bounds (size {sz})"
    | .emptyValue col => s!"empty value in column: {col}"

/-- Result type for extraction operations -/
abbrev ExtractResult (α : Type) := Except ExtractError α

end Tabular
