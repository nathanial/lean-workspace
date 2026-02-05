/-
  Cellar - Generic disk cache library for Lean 4

  Provides LRU-based disk caching with:
  - Generic key type parameterization
  - Atomic file writes
  - Automatic cache eviction
  - In-memory index for fast lookups
-/
import Cellar.Config
import Cellar.LRU
import Cellar.IO
