/-
  Lighthouse - Ledger Database Inspector
  A terminal UI debugger for ledger databases
-/

import Lighthouse

def main (args : List String) : IO Unit := do
  match args with
  | [dbPath] =>
    Lighthouse.UI.run dbPath
  | _ =>
    IO.eprintln "Usage: lighthouse <database.jsonl>"
    IO.Process.exit 1
