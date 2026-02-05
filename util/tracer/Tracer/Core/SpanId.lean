/-
  Tracer.Core.SpanId - 64-bit span identifier

  A span ID uniquely identifies a span within a trace.
-/

namespace Tracer

/-- 64-bit span identifier -/
structure SpanId where
  value : UInt64
  deriving Repr, BEq, Inhabited

namespace SpanId

/-- The invalid/zero span ID -/
def invalid : SpanId := { value := 0 }

/-- Check if this is a valid (non-zero) span ID -/
def isValid (id : SpanId) : Bool := id.value != 0

/-- Generate a random span ID using IO.rand -/
def generate : IO SpanId := do
  let value ← IO.rand 1 UInt64.size.pred  -- Start from 1 to avoid invalid
  pure { value := value.toUInt64 }

-- TODO: Replace with Staple.Hex.hexCharToNat after staple release
/-- Convert a single hex character to its numeric value -/
private def hexCharToNat (c : Char) : Option Nat :=
  if '0' ≤ c && c ≤ '9' then some (c.toNat - '0'.toNat)
  else if 'a' ≤ c && c ≤ 'f' then some (c.toNat - 'a'.toNat + 10)
  else if 'A' ≤ c && c ≤ 'F' then some (c.toNat - 'A'.toNat + 10)
  else none

/-- Parse a 16-character hex string to SpanId -/
def fromHex (s : String) : Option SpanId := do
  if s.length != 16 then none
  else
    let chars := s.toList
    let result ← chars.foldlM (init := 0) fun acc c => do
      let digit ← hexCharToNat c
      pure (acc * 16 + digit)
    some { value := result.toUInt64 }

-- TODO: Replace with Staple.Hex.nibbleToHexChar after staple release
/-- Convert a nibble (0-15) to a lowercase hex character -/
private def nibbleToHexChar (n : Nat) : Char :=
  if n < 10 then Char.ofNat ('0'.toNat + n)
  else Char.ofNat ('a'.toNat + n - 10)

/-- Convert to 16-character lowercase hex string -/
def toHex (id : SpanId) : String :=
  let rec go (value : Nat) (count : Nat) (acc : String) : String :=
    if count == 0 then acc
    else
      let nibble := value % 16
      let char := nibbleToHexChar nibble
      go (value / 16) (count - 1) (String.singleton char ++ acc)
  termination_by count
  decreasing_by simp_all; omega
  go id.value.toNat 16 ""

instance : ToString SpanId where
  toString := toHex

end SpanId
end Tracer
