/-
  Staple.Json.ToJson - Serialization typeclass

  Provides the ToJson typeclass for converting Lean values to JSON.
-/
import Staple.Json.Value
import Staple.Json.Render

namespace Staple.Json

/-- Typeclass for converting values to JSON.

    Implement this typeclass to enable JSON serialization for your types.

    Example:
    ```
    structure User where
      name : String
      age : Nat

    instance : ToJson User where
      toJson u := Value.mkObj #[
        ("name", toJson u.name),
        ("age", toJson u.age)
      ]
    ```
-/
class ToJson (α : Type) where
  toJson : α → Value

export ToJson (toJson)

/-! ## Primitive Instances -/

instance : ToJson Bool where
  toJson b := .bool b

instance : ToJson Nat where
  toJson n := .num (.int n)

instance : ToJson Int where
  toJson n := .num (.int n)

instance : ToJson Float where
  toJson f := .num (.float f)

instance : ToJson String where
  toJson s := .str s

instance : ToJson Char where
  toJson c := .str (String.singleton c)

/-! ## Unsigned Integer Instances -/

instance : ToJson UInt8 where
  toJson n := .num (.int n.toNat)

instance : ToJson UInt16 where
  toJson n := .num (.int n.toNat)

instance : ToJson UInt32 where
  toJson n := .num (.int n.toNat)

instance : ToJson UInt64 where
  toJson n := .num (.int n.toNat)

/-! ## Signed Integer Instances -/

instance : ToJson Int8 where
  toJson n := .num (.int n.toInt)

instance : ToJson Int16 where
  toJson n := .num (.int n.toInt)

instance : ToJson Int32 where
  toJson n := .num (.int n.toInt)

instance : ToJson Int64 where
  toJson n := .num (.int n.toInt)

/-! ## Container Instances -/

instance {α : Type} [ToJson α] : ToJson (Option α) where
  toJson
    | none => .null
    | some a => toJson a

instance {α : Type} [ToJson α] : ToJson (Array α) where
  toJson arr := .arr (arr.map toJson)

instance {α : Type} [ToJson α] : ToJson (List α) where
  toJson lst := .arr (lst.map toJson).toArray

/-! ## Tuple Instances -/

instance {α β : Type} [ToJson α] [ToJson β] : ToJson (α × β) where
  toJson p := .arr #[toJson p.1, toJson p.2]

instance {α β γ : Type} [ToJson α] [ToJson β] [ToJson γ] : ToJson (α × β × γ) where
  toJson p := .arr #[toJson p.1, toJson p.2.1, toJson p.2.2]

/-! ## Special Instances -/

instance : ToJson Value where
  toJson v := v

instance : ToJson JsonNumber where
  toJson n := .num n

instance : ToJson Unit where
  toJson _ := .null

/-! ## Convenience Functions -/

/-- Convert a value to a compact JSON string -/
def toJsonString {α : Type} [ToJson α] (a : α) : String :=
  (toJson a).compress

/-- Convert a value to a pretty-printed JSON string -/
def toJsonPretty {α : Type} [ToJson α] (a : α) (indent : Nat := 2) : String :=
  (toJson a).pretty indent

end Staple.Json
