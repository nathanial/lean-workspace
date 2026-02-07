/- 
  Ledger.Persist.Compaction

  Backward-compatible wrapper around PersistentConnection.compact.
-/

import Ledger.Persist.Connection

namespace Ledger.Persist.Compaction

abbrev CompactionResult := PersistentConnection.CompactionResult

/-- Compact a persistent connection by snapshotting and trimming journal. -/
def compact (pc : PersistentConnection) : IO (PersistentConnection × CompactionResult) :=
  pc.compact

end Ledger.Persist.Compaction
