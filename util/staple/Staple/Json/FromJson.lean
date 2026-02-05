/-
  Staple.Json.FromJson - Deserialization typeclass

  Provides the FromJson typeclass for parsing JSON into Lean values.
-/
import Staple.Json.Value
import Staple.Json.Parse

namespace Staple.Json

/-- Typeclass for parsing JSON values into Lean types.

    Implement this typeclass to enable JSON deserialization for your types.

    Example:
    ```
    structure User where
      name : String
      age : Nat

    instance : FromJson User where
      fromJson? v := do
        let name ← v.getStrField? "name"
        let age ← v.getNatField? "age"
        return { name, age }
    ```
-/
class FromJson (α : Type) where
  fromJson? : Value → Option α

export FromJson (fromJson?)

/-- Parse JSON and convert to a typed value -/
def fromJsonString? {α : Type} [FromJson α] (s : String) : Option α := do
  let value ← parse? s
  fromJson? value

/-- Parse JSON and convert, returning Except with error message -/
def fromJsonExcept {α : Type} [FromJson α] (v : Value) : Except String α :=
  match fromJson? v with
  | some a => .ok a
  | none => .error "Failed to parse JSON value"

/-- Parse JSON string and convert, returning Except with error message -/
def fromJsonString {α : Type} [FromJson α] (s : String) : Except String α := do
  let value ← parse s
  fromJsonExcept value

/-! ## Primitive Instances -/

instance : FromJson Bool where
  fromJson? v := v.getBool?

instance : FromJson Nat where
  fromJson? v := v.getNat?

instance : FromJson Int where
  fromJson? v := v.getInt?

instance : FromJson Float where
  fromJson? v := v.getFloat?

instance : FromJson String where
  fromJson? v := v.getStr?

instance : FromJson Char where
  fromJson? v := do
    let s ← v.getStr?
    if s.length == 1 then
      match s.toList with
      | c :: _ => some c
      | [] => none
    else
      none

/-! ## Unsigned Integer Instances -/

instance : FromJson UInt8 where
  fromJson? v := do
    let n ← v.getNat?
    if n ≤ UInt8.size - 1 then some n.toUInt8 else none

instance : FromJson UInt16 where
  fromJson? v := do
    let n ← v.getNat?
    if n ≤ UInt16.size - 1 then some n.toUInt16 else none

instance : FromJson UInt32 where
  fromJson? v := do
    let n ← v.getNat?
    if n ≤ UInt32.size - 1 then some n.toUInt32 else none

instance : FromJson UInt64 where
  fromJson? v := do
    let n ← v.getNat?
    some n.toUInt64

/-! ## Signed Integer Instances -/

instance : FromJson Int8 where
  fromJson? v := do
    let n ← v.getInt?
    if -128 ≤ n ∧ n ≤ 127 then some n.toInt8 else none

instance : FromJson Int16 where
  fromJson? v := do
    let n ← v.getInt?
    if -32768 ≤ n ∧ n ≤ 32767 then some n.toInt16 else none

instance : FromJson Int32 where
  fromJson? v := do
    let n ← v.getInt?
    if -2147483648 ≤ n ∧ n ≤ 2147483647 then some n.toInt32 else none

instance : FromJson Int64 where
  fromJson? v := do
    let n ← v.getInt?
    some n.toInt64

/-! ## Container Instances -/

instance {α : Type} [FromJson α] : FromJson (Option α) where
  fromJson?
    | .null => some none
    | v => some (fromJson? v)

instance {α : Type} [FromJson α] : FromJson (Array α) where
  fromJson? v := do
    let arr ← v.getArr?
    let mut results : Array α := #[]
    for item in arr do
      let a ← fromJson? item
      results := results.push a
    some results

instance {α : Type} [FromJson α] : FromJson (List α) where
  fromJson? v := do
    let arr : Array α ← fromJson? v
    some arr.toList

/-! ## Tuple Instances -/

instance {α β : Type} [FromJson α] [FromJson β] : FromJson (α × β) where
  fromJson? v := do
    let arr ← v.getArr?
    if arr.size != 2 then none
    else do
      let v0 ← arr[0]?
      let v1 ← arr[1]?
      let a ← fromJson? v0
      let b ← fromJson? v1
      some (a, b)

instance {α β γ : Type} [FromJson α] [FromJson β] [FromJson γ] : FromJson (α × β × γ) where
  fromJson? v := do
    let arr ← v.getArr?
    if arr.size != 3 then none
    else do
      let v0 ← arr[0]?
      let v1 ← arr[1]?
      let v2 ← arr[2]?
      let a ← fromJson? v0
      let b ← fromJson? v1
      let c ← fromJson? v2
      some (a, b, c)

/-! ## Special Instances -/

instance : FromJson Value where
  fromJson? v := some v

instance : FromJson JsonNumber where
  fromJson? v := v.getNum?

instance : FromJson Unit where
  fromJson?
    | .null => some ()
    | _ => none

end Staple.Json
