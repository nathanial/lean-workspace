/-
  Chronos Demo
  Demonstrates wall clock time functionality.
-/

import Chronos

open Chronos

def main : IO Unit := do
  IO.println "=== Chronos Demo ==="
  IO.println ""

  -- Get current timestamp
  let ts ← Timestamp.now
  IO.println s!"Unix Timestamp:"
  IO.println s!"  seconds:     {ts.seconds}"
  IO.println s!"  nanoseconds: {ts.nanoseconds}"
  IO.println s!"  as float:    {ts.toFloat}"
  IO.println ""

  -- Get UTC time
  let utc ← DateTime.nowUtc
  IO.println s!"UTC Time:"
  IO.println s!"  ISO 8601:    {utc.toIso8601}"
  IO.println s!"  Full:        {utc.toIso8601Full}"
  IO.println s!"  Date:        {utc.toDateString}"
  IO.println s!"  Time:        {utc.toTimeString}"
  IO.println ""

  -- Get local time
  let localDt ← DateTime.nowLocal
  IO.println s!"Local Time:"
  IO.println s!"  ISO 8601:    {localDt.toIso8601}"
  IO.println s!"  Full:        {localDt.toIso8601Full}"
  IO.println ""

  -- Timezone info
  let offset ← DateTime.getTimezoneOffset
  let offsetHours := offset.toInt / 3600
  let offsetMins := (offset.toInt % 3600).natAbs / 60
  let sign := if offset >= 0 then "+" else "-"
  IO.println s!"Timezone:"
  IO.println s!"  Offset:      {sign}{offsetHours.natAbs}:{if offsetMins < 10 then "0" else ""}{offsetMins}"
  IO.println s!"  Seconds:     {offset}"
  IO.println ""

  -- Demonstrate roundtrip
  IO.println "Roundtrip Test:"
  let ts2 ← utc.toTimestamp
  IO.println s!"  Original ts: {ts.seconds}.{ts.nanoseconds}"
  IO.println s!"  After UTC:   {ts2.seconds}.{ts2.nanoseconds}"
  IO.println ""

  -- Date utilities
  IO.println "Date Utilities:"
  IO.println s!"  2024 is leap year: {DateTime.isLeapYear 2024}"
  IO.println s!"  2023 is leap year: {DateTime.isLeapYear 2023}"
  IO.println s!"  Days in Feb 2024:  {DateTime.daysInMonth 2024 2}"
  IO.println s!"  Days in Feb 2023:  {DateTime.daysInMonth 2023 2}"
