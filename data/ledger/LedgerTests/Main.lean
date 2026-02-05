/-
  Ledger Tests

  Main test runner that imports all test modules.
-/

import Crucible
import LedgerTests.Core
import LedgerTests.Database
import LedgerTests.Retraction
import LedgerTests.Query
import LedgerTests.Binding
import LedgerTests.Predicate
import LedgerTests.Pull
import LedgerTests.TimeTravel
import LedgerTests.DSL
import LedgerTests.Persistence
import LedgerTests.Derive
import LedgerTests.Performance
import LedgerTests.RangeQuery
import LedgerTests.Schema
import LedgerTests.Aggregates
import LedgerTests.Rules
import LedgerTests.Macros
import LedgerTests.TxFunctions

open Crucible

def main : IO Unit := do
  IO.println "╔══════════════════════════════════════╗"
  IO.println "║     Ledger Database Tests            ║"
  IO.println "╚══════════════════════════════════════╝"
  IO.println ""

  let exitCode ← runAllSuites

  IO.println ""
  if exitCode == 0 then
    IO.println "All tests passed!"
  else
    IO.println "Some tests failed"
    IO.Process.exit 1
