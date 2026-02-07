/- 
  Ledger.Persist.Policy

  Compaction and history-retention policy for persistent connections.
-/

namespace Ledger.Persist

/-- How much transaction history to preserve across compaction/snapshot cycles. -/
inductive HistoryRetention where
  /-- Keep only current state in snapshots (fast startup, bounded history). -/
  | bounded
  /-- Preserve full transaction history in snapshots (slower growth over time). -/
  | preserveFull
  deriving Repr, Inhabited, BEq

/-- Policy for automatic snapshot/compaction behavior. -/
structure CompactionPolicy where
  /-- Enable automatic compaction checks on startup and writes. -/
  enabled : Bool := true
  /-- History retention mode when writing snapshots. -/
  history : HistoryRetention := .bounded
  /-- Trigger compaction when journal reaches this many bytes. -/
  maxJournalBytes : Nat := 1 * 1024 * 1024
  /-- Trigger compaction when this many entries accumulated since last snapshot. -/
  maxEntriesSinceSnapshot : Nat := 500
  /-- Minimum time between auto-compactions in milliseconds. -/
  minCompactionIntervalMs : Nat := 15000
  deriving Repr, Inhabited

namespace CompactionPolicy

/-- Default policy favors bounded history and startup performance. -/
def default : CompactionPolicy := {}

/-- Convenience policy that preserves full history across compaction. -/
def preserveFull : CompactionPolicy := { default with history := .preserveFull }

end CompactionPolicy

end Ledger.Persist
