/-
  Tracer.Core.TraceId - 128-bit trace identifier

  A trace ID uniquely identifies a distributed trace across all services.
  Represented as two UInt64 values for efficient storage and comparison.
-/

namespace Tracer

/-- 128-bit trace identifier represented as two 64-bit values -/
structure TraceId where
  high : UInt64
  low : UInt64
  deriving Repr, BEq, Inhabited

namespace TraceId

/-- The invalid/zero trace ID -/
def invalid : TraceId := { high := 0, low := 0 }

/-- Check if this is a valid (non-zero) trace ID -/
def isValid (id : TraceId) : Bool :=
  id.high != 0 || id.low != 0

/-- Generate a random trace ID using IO.rand -/
def generate : IO TraceId := do
  let high ← IO.rand 0 UInt64.size.pred
  let low ← IO.rand 0 UInt64.size.pred
  -- Ensure we don't generate an invalid (all-zero) ID
  if high == 0 && low == 0 then
    pure { high := 1, low := 0 }
  else
    pure { high := high.toUInt64, low := low.toUInt64 }

-- TODO: Replace with Staple.Hex.hexCharToNat after staple release
/-- Convert a single hex character to its numeric value -/
private def hexCharToNat (c : Char) : Option Nat :=
  if '0' ≤ c && c ≤ '9' then some (c.toNat - '0'.toNat)
  else if 'a' ≤ c && c ≤ 'f' then some (c.toNat - 'a'.toNat + 10)
  else if 'A' ≤ c && c ≤ 'F' then some (c.toNat - 'A'.toNat + 10)
  else none

/-- Parse a 16-character hex string to UInt64 -/
private def hexToUInt64 (s : String) : Option UInt64 := do
  if s.length != 16 then none
  else
    let chars := s.toList
    let result ← chars.foldlM (init := 0) fun acc c => do
      let digit ← hexCharToNat c
      pure (acc * 16 + digit)
    some result.toUInt64

/-- Parse a 32-character lowercase hex string to TraceId -/
def fromHex (s : String) : Option TraceId := do
  if s.length != 32 then none
  else
    let highStr := s.take 16
    let lowStr := s.drop 16
    let high ← hexToUInt64 highStr
    let low ← hexToUInt64 lowStr
    some { high, low }

-- TODO: Replace with Staple.Hex.nibbleToHexChar after staple release
/-- Convert a nibble (0-15) to a lowercase hex character -/
private def nibbleToHexChar (n : Nat) : Char :=
  if n < 10 then Char.ofNat ('0'.toNat + n)
  else Char.ofNat ('a'.toNat + n - 10)

/-- Convert UInt64 to 16-character lowercase hex string -/
private def uint64ToHex (n : UInt64) : String :=
  let rec go (value : Nat) (count : Nat) (acc : String) : String :=
    if count == 0 then acc
    else
      let nibble := value % 16
      let char := nibbleToHexChar nibble
      go (value / 16) (count - 1) (String.singleton char ++ acc)
  termination_by count
  decreasing_by simp_all; omega
  go n.toNat 16 ""

/-- Convert to 32-character lowercase hex string -/
def toHex (id : TraceId) : String :=
  uint64ToHex id.high ++ uint64ToHex id.low

instance : ToString TraceId where
  toString := toHex

end TraceId
end Tracer
