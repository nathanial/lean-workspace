/-
  Tracer.Core.TraceFlags - W3C trace flags

  8-bit flags field from W3C Trace Context specification.
  Currently only the sampled flag (bit 0) is defined.
-/

namespace Tracer

/-- W3C trace flags (8 bits) -/
structure TraceFlags where
  value : UInt8
  deriving Repr, BEq, Inhabited

namespace TraceFlags

/-- Trace is sampled (will be recorded) -/
def sampled : TraceFlags := { value := 0x01 }

/-- Trace is not sampled -/
def notSampled : TraceFlags := { value := 0x00 }

/-- Check if the sampled flag is set -/
def isSampled (f : TraceFlags) : Bool := f.value &&& 0x01 != 0

/-- Set the sampled flag -/
def setSampled (f : TraceFlags) (sampled : Bool) : TraceFlags :=
  if sampled then { value := f.value ||| 0x01 }
  else { value := f.value &&& 0xFE }

/-- Convert a single hex character to its numeric value -/
private def hexCharToNat (c : Char) : Option Nat :=
  if '0' ≤ c && c ≤ '9' then some (c.toNat - '0'.toNat)
  else if 'a' ≤ c && c ≤ 'f' then some (c.toNat - 'a'.toNat + 10)
  else if 'A' ≤ c && c ≤ 'F' then some (c.toNat - 'A'.toNat + 10)
  else none

/-- Parse from 2-character hex string -/
def fromHex (s : String) : Option TraceFlags := do
  if s.length != 2 then none
  else
    let chars := s.toList
    let high ← hexCharToNat chars[0]!
    let low ← hexCharToNat chars[1]!
    some { value := (high * 16 + low).toUInt8 }

/-- Convert a nibble (0-15) to a lowercase hex character -/
private def nibbleToHexChar (n : Nat) : Char :=
  if n < 10 then Char.ofNat ('0'.toNat + n)
  else Char.ofNat ('a'.toNat + n - 10)

/-- Convert to 2-character lowercase hex string -/
def toHex (f : TraceFlags) : String :=
  let n := f.value.toNat
  let high := nibbleToHexChar (n / 16)
  let low := nibbleToHexChar (n % 16)
  String.singleton high ++ String.singleton low

instance : ToString TraceFlags where
  toString := toHex

end TraceFlags
end Tracer
