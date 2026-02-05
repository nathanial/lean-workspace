/-
  Chronos.Error
  Error types for explicit error handling with EIO.
-/

namespace Chronos

/-- Errors that can occur in chronos operations. -/
inductive ChronosError where
  /-- System clock is unavailable or failed. -/
  | clockUnavailable (msg : String)
  /-- Failed to convert timestamp to date/time components. -/
  | conversionFailed (msg : String)
  /-- Failed to convert date/time components to timestamp. -/
  | timestampFailed (msg : String)
  /-- Invalid timezone name. -/
  | invalidTimezone (name : String)
  /-- Timezone conversion failed. -/
  | timezoneConversionFailed (msg : String)
  /-- Generic system error. -/
  | systemError (msg : String)
  deriving Repr, BEq, Inhabited

namespace ChronosError

/-- Convert error to human-readable message. -/
def toString : ChronosError → String
  | clockUnavailable msg => s!"Clock unavailable: {msg}"
  | conversionFailed msg => s!"Conversion failed: {msg}"
  | timestampFailed msg => s!"Timestamp failed: {msg}"
  | invalidTimezone name => s!"Invalid timezone: {name}"
  | timezoneConversionFailed msg => s!"Timezone conversion failed: {msg}"
  | systemError msg => s!"System error: {msg}"

instance : ToString ChronosError := ⟨ChronosError.toString⟩

/-- Convert to IO.Error for use with IO monad. -/
def toIOError (e : ChronosError) : IO.Error :=
  IO.Error.userError e.toString

end ChronosError

/-- Chronos operations that can fail with explicit errors. -/
abbrev ChronosM := EIO ChronosError

/-- Run a ChronosM action, converting errors to IO exceptions. -/
def ChronosM.toIO (action : ChronosM α) : IO α := do
  match ← action.toIO' with
  | .ok a => pure a
  | .error e => throw e.toIOError

/-- Run a ChronosM action, returning an Except. -/
def ChronosM.run (action : ChronosM α) : IO (Except ChronosError α) :=
  action.toIO'

/-- Lift an IO action into ChronosM with a custom error transformer. -/
def ChronosM.liftIO (action : IO α) (onError : IO.Error → ChronosError) : ChronosM α :=
  action.toEIO onError

end Chronos
