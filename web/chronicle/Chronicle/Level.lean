/-
  Chronicle.Level - Log level definitions

  Defines the standard logging levels with ordering support for threshold filtering.
-/

namespace Chronicle

/-- Log levels in order of increasing severity -/
inductive Level where
  | trace
  | debug
  | info
  | warn
  | error
deriving Repr, BEq, Inhabited

namespace Level

/-- Convert level to numeric value for comparison -/
def toNat : Level → Nat
  | .trace => 0
  | .debug => 1
  | .info => 2
  | .warn => 3
  | .error => 4

/-- Convert level to uppercase string -/
def toString : Level → String
  | .trace => "TRACE"
  | .debug => "DEBUG"
  | .info => "INFO"
  | .warn => "WARN"
  | .error => "ERROR"

/-- Convert level to padded string (5 chars) for aligned text output -/
def padded : Level → String
  | .trace => "TRACE"
  | .debug => "DEBUG"
  | .info => "INFO "
  | .warn => "WARN "
  | .error => "ERROR"

/-- Parse level from string (case-insensitive) -/
def fromString (s : String) : Option Level :=
  match s.toLower with
  | "trace" => some .trace
  | "debug" => some .debug
  | "info" => some .info
  | "warn" => some .warn
  | "warning" => some .warn
  | "error" => some .error
  | _ => none

instance : Ord Level where
  compare a b := compare a.toNat b.toNat

instance : LE Level where
  le a b := a.toNat ≤ b.toNat

instance : LT Level where
  lt a b := a.toNat < b.toNat

instance : DecidableEq Level := fun a b =>
  match a, b with
  | .trace, .trace => isTrue rfl
  | .debug, .debug => isTrue rfl
  | .info, .info => isTrue rfl
  | .warn, .warn => isTrue rfl
  | .error, .error => isTrue rfl
  | .trace, .debug | .trace, .info | .trace, .warn | .trace, .error => isFalse (fun h => by cases h)
  | .debug, .trace | .debug, .info | .debug, .warn | .debug, .error => isFalse (fun h => by cases h)
  | .info, .trace | .info, .debug | .info, .warn | .info, .error => isFalse (fun h => by cases h)
  | .warn, .trace | .warn, .debug | .warn, .info | .warn, .error => isFalse (fun h => by cases h)
  | .error, .trace | .error, .debug | .error, .info | .error, .warn => isFalse (fun h => by cases h)

instance : DecidableRel (α := Level) (· ≤ ·) := fun a b =>
  if h : a.toNat ≤ b.toNat then isTrue h else isFalse h

instance : DecidableRel (α := Level) (· < ·) := fun a b =>
  if h : a.toNat < b.toNat then isTrue h else isFalse h

/-- Check if a level meets a minimum threshold -/
def meetsThreshold (level : Level) (threshold : Level) : Bool :=
  level.toNat ≥ threshold.toNat

end Level
end Chronicle
