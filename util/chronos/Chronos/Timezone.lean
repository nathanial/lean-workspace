/-
  Chronos.Timezone
  Named timezone support using IANA timezone database.
-/

import Chronos.Timestamp

namespace Chronos

/-- Opaque handle to a timezone.
    Wraps a system timezone handle that can be used to convert
    between UTC timestamps and local DateTime representations. -/
opaque TimezonePointed : NonemptyType
def Timezone := TimezonePointed.type
instance : Nonempty Timezone := TimezonePointed.property

namespace Timezone

-- ============================================================================
-- FFI declarations
-- ============================================================================

/-- Raw FFI: Load timezone by IANA name. Returns none on failure. -/
@[extern "chronos_timezone_from_name"]
private opaque fromNameFFI (name : @& String) : IO (Option Timezone)

/-- Raw FFI: Get UTC timezone. -/
@[extern "chronos_timezone_utc"]
private opaque utcFFI : IO Timezone

/-- Raw FFI: Get local system timezone. -/
@[extern "chronos_timezone_local"]
private opaque localFFI : IO Timezone

/-- Raw FFI: Get timezone name. -/
@[extern "chronos_timezone_name"]
private opaque nameFFI (tz : @& Timezone) : IO String

-- ============================================================================
-- Public API
-- ============================================================================

/-- Load a timezone by IANA name (e.g., "America/New_York", "Europe/London").
    Returns `none` if the timezone name is not recognized.

    Example:
    ```
    match ← Timezone.fromName "America/New_York" with
    | some tz => IO.println s!"Loaded: {← tz.name}"
    | none => IO.println "Invalid timezone"
    ``` -/
def fromName (name : String) : IO (Option Timezone) :=
  fromNameFFI name

/-- The UTC timezone. -/
def utc : IO Timezone := utcFFI

/-- The local system timezone. -/
def localTz : IO Timezone := localFFI

/-- Get the canonical name of this timezone.
    For named timezones, returns the IANA name (e.g., "America/New_York").
    For the local timezone, returns the system's timezone abbreviation. -/
def name (tz : Timezone) : IO String := nameFFI tz

end Timezone

end Chronos
