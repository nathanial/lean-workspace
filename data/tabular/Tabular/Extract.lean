/-
  Tabular.Extract
  FromCsv typeclass for typed extraction from CSV cells
-/
import Tabular.Core.Value
import Tabular.Core.Row
import Tabular.Core.Error

namespace Tabular

/-- Typeclass for extracting typed values from CSV cells -/
class FromCsv (α : Type) where
  fromCsv : Value → ExtractResult α

instance : FromCsv String where
  fromCsv v := .ok v.content

instance : FromCsv Int where
  fromCsv v :=
    if v.isEmpty then
      .error (.emptyValue "")
    else match v.content.trim.toInt? with
      | some n => .ok n
      | none => .error (.typeConversion v.content "Int")

instance : FromCsv Nat where
  fromCsv v := do
    let n : Int ← FromCsv.fromCsv v
    if n >= 0 then .ok n.toNat
    else .error (.typeConversion v.content "Nat (negative)")

/-- Parse a float from a string.
    Supports formats: 123, -123, 123.456, -123.456 -/
private def parseFloat? (s : String) : Option Float :=
  let s := s.trim
  if s.isEmpty then none
  else
    -- First try as integer
    match s.toInt? with
    | some n => some (Float.ofInt n)
    | none =>
      -- Parse manually: [sign] integer [. fraction]
      let chars := s.toList
      let (sign, rest) := match chars with
        | '-' :: t => (-1.0, t)
        | '+' :: t => (1.0, t)
        | _ => (1.0, chars)

      -- Split at decimal point
      let (intPart, afterDot) := rest.span (· != '.')
      let fracPart := match afterDot with
        | '.' :: t => t
        | _ => []

      -- Parse integer part
      let intStr := String.ofList intPart
      match intStr.toNat? with
      | none => none
      | some intVal =>
        -- Parse fraction part
        let fracVal? := if fracPart.isEmpty then some 0.0
          else
            let fracStr := String.ofList fracPart
            match fracStr.toNat? with
            | some n =>
              let divisor := Float.pow 10.0 fracPart.length.toFloat
              some (n.toFloat / divisor)
            | none => none
        match fracVal? with
        | none => none
        | some fracVal =>
          let base := intVal.toFloat + fracVal
          let result := sign * base
          some result

instance : FromCsv Float where
  fromCsv v :=
    if v.isEmpty then
      .error (.emptyValue "")
    else
      match parseFloat? v.content with
      | some f => .ok f
      | none => .error (.typeConversion v.content "Float")

instance : FromCsv Bool where
  fromCsv v :=
    let s := v.content.trim.toLower
    if s == "true" || s == "1" || s == "yes" || s == "y" then
      .ok true
    else if s == "false" || s == "0" || s == "no" || s == "n" || s.isEmpty then
      .ok false
    else
      .error (.typeConversion v.content "Bool")

instance [FromCsv α] : FromCsv (Option α) where
  fromCsv v :=
    if v.isEmpty then
      .ok none
    else match FromCsv.fromCsv v with
      | .ok x => .ok (some x)
      | .error _ => .ok none  -- Treat conversion errors as none for Option

instance : FromCsv Value where
  fromCsv v := .ok v

/-- Extract column by index with type conversion -/
def Row.getAs [FromCsv α] (row : Row) (idx : Nat) : ExtractResult α := do
  match row.get? idx with
  | some v => FromCsv.fromCsv v
  | none => .error (.indexOutOfBounds idx row.size)

/-- Extract column by name with type conversion -/
def Row.getByNameAs [FromCsv α] (row : Row) (name : String) : ExtractResult α := do
  match row.getByName? name with
  | some v => FromCsv.fromCsv v
  | none => .error (.columnNotFound name)

/-- Extract column by index, returning Option for empty values -/
def Row.getAsOption [FromCsv α] (row : Row) (idx : Nat) : ExtractResult (Option α) :=
  match row.get? idx with
  | some v =>
    if v.isEmpty then .ok none
    else match FromCsv.fromCsv v with
      | .ok x => .ok (some x)
      | .error e => .error e
  | none => .error (.indexOutOfBounds idx row.size)

/-- Extract column by name, returning Option for empty values -/
def Row.getByNameAsOption [FromCsv α] (row : Row) (name : String) : ExtractResult (Option α) :=
  match row.getByName? name with
  | some v =>
    if v.isEmpty then .ok none
    else match FromCsv.fromCsv v with
      | .ok x => .ok (some x)
      | .error e => .error e
  | none => .error (.columnNotFound name)

end Tabular
