-- Afferent FFI runtime stats bindings.
import Afferent.Runtime.FFI.Types

namespace Afferent.FFI

-- Process and allocator telemetry snapshot from mimalloc.
structure ProcessInfo where
  elapsedMs : Nat
  userMs : Nat
  systemMs : Nat
  currentRssBytes : Nat
  peakRssBytes : Nat
  currentCommitBytes : Nat
  peakCommitBytes : Nat
  pageFaults : Nat
  deriving Repr, Inhabited

namespace Runtime

@[extern "lean_afferent_runtime_get_process_info"]
opaque getProcessInfo : IO ProcessInfo

end Runtime
end Afferent.FFI

