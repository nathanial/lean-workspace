/-
  Staple.Json.Value - JSON value AST

  The core JSON value type representing any valid JSON document.
-/
import Staple.Json.Number

namespace Staple.Json

/-- A JSON value, representing the full JSON data model.

    JSON values can be:
    - `null` - the null literal
    - `bool` - true or false
    - `num` - a numeric value (integer or floating-point)
    - `str` - a string value
    - `arr` - an ordered array of values
    - `obj` - an object with string keys and value members -/
inductive Value where
  | null
  | bool (b : Bool)
  | num (n : JsonNumber)
  | str (s : String)
  | arr (items : Array Value)
  | obj (fields : Array (String × Value))
  deriving Repr, BEq, Inhabited

namespace Value

/-! ## Constructors -/

/-- Create a JSON string value -/
def mkStr (s : String) : Value := .str s

/-- Create a JSON number from Int -/
def mkInt (n : Int) : Value := .num (.int n)

/-- Create a JSON number from Nat -/
def mkNat (n : Nat) : Value := .num (.int n)

/-- Create a JSON number from Float -/
def mkFloat (f : Float) : Value := .num (.float f)

/-- Create a JSON boolean -/
def mkBool (b : Bool) : Value := .bool b

/-- Create a JSON array -/
def mkArr (items : Array Value) : Value := .arr items

/-- Create a JSON object from key-value pairs -/
def mkObj (fields : Array (String × Value)) : Value := .obj fields

/-- Create a JSON object from a list of key-value pairs -/
def mkObjFromList (fields : List (String × Value)) : Value := .obj fields.toArray

/-! ## Type predicates -/

def isNull : Value → Bool
  | .null => true
  | _ => false

def isBool : Value → Bool
  | .bool _ => true
  | _ => false

def isNum : Value → Bool
  | .num _ => true
  | _ => false

def isStr : Value → Bool
  | .str _ => true
  | _ => false

def isArr : Value → Bool
  | .arr _ => true
  | _ => false

def isObj : Value → Bool
  | .obj _ => true
  | _ => false

/-! ## Accessors -/

/-- Get the boolean value, if this is a bool -/
def getBool? : Value → Option Bool
  | .bool b => some b
  | _ => none

/-- Get the numeric value, if this is a number -/
def getNum? : Value → Option JsonNumber
  | .num n => some n
  | _ => none

/-- Get the integer value, if this is an integer number -/
def getInt? : Value → Option Int
  | .num (.int n) => some n
  | .num (.float f) => if f == f.floor then some f.toUInt64.toNat else none
  | _ => none

/-- Get the Nat value, if this is a non-negative integer -/
def getNat? : Value → Option Nat
  | .num n =>
    let i := n.toInt
    if i >= 0 then some i.toNat else none
  | _ => none

/-- Get the float value, if this is a number -/
def getFloat? : Value → Option Float
  | .num n => some n.toFloat
  | _ => none

/-- Get the string value, if this is a string -/
def getStr? : Value → Option String
  | .str s => some s
  | _ => none

/-- Get the array items, if this is an array -/
def getArr? : Value → Option (Array Value)
  | .arr items => some items
  | _ => none

/-- Get the object fields, if this is an object -/
def getObj? : Value → Option (Array (String × Value))
  | .obj fields => some fields
  | _ => none

/-! ## Object field access -/

/-- Get a field from an object by key -/
def getField? (key : String) : Value → Option Value
  | .obj fields => fields.find? (·.1 == key) |>.map (·.2)
  | _ => none

/-- Get a field and extract its value as a specific type -/
def getFieldAs? {α : Type} (key : String) (extract : Value → Option α) (v : Value) : Option α :=
  v.getField? key >>= extract

/-- Get a string field -/
def getStrField? (key : String) (v : Value) : Option String :=
  v.getFieldAs? key getStr?

/-- Get an integer field -/
def getIntField? (key : String) (v : Value) : Option Int :=
  v.getFieldAs? key getInt?

/-- Get a Nat field -/
def getNatField? (key : String) (v : Value) : Option Nat :=
  v.getFieldAs? key getNat?

/-- Get a boolean field -/
def getBoolField? (key : String) (v : Value) : Option Bool :=
  v.getFieldAs? key getBool?

/-- Get an array field -/
def getArrField? (key : String) (v : Value) : Option (Array Value) :=
  v.getFieldAs? key getArr?

/-- Get an object field -/
def getObjField? (key : String) (v : Value) : Option (Array (String × Value)) :=
  v.getFieldAs? key getObj?

/-! ## Array access -/

/-- Get an element from an array by index -/
def getIndex? (idx : Nat) : Value → Option Value
  | .arr items => items[idx]?
  | _ => none

/-! ## Modification -/

/-- Set a field in an object (adds or updates) -/
def setField (key : String) (value : Value) : Value → Value
  | .obj fields =>
    let filtered := fields.filter (·.1 != key)
    .obj (filtered.push (key, value))
  | v => v  -- No-op for non-objects

/-- Remove a field from an object -/
def removeField (key : String) : Value → Value
  | .obj fields => .obj (fields.filter (·.1 != key))
  | v => v

/-- Map a function over array elements -/
def mapArr (f : Value → Value) : Value → Value
  | .arr items => .arr (items.map f)
  | v => v

/-! ## Utilities -/

/-- Get all keys from an object -/
def keys : Value → Array String
  | .obj fields => fields.map (·.1)
  | _ => #[]

/-- Get all values from an object -/
def values : Value → Array Value
  | .obj fields => fields.map (·.2)
  | _ => #[]

/-- Check if an object has a specific key -/
def hasKey (key : String) : Value → Bool
  | .obj fields => fields.any (·.1 == key)
  | _ => false

/-- Get the size (array length or object field count) -/
def size : Value → Nat
  | .arr items => items.size
  | .obj fields => fields.size
  | _ => 0

end Value

end Staple.Json
