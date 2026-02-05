/-
  Cellar Configuration and Types
  Generic disk cache configuration parameterized over key type.
-/
import Std.Data.HashMap

namespace Cellar

/-- Configuration for disk cache -/
structure CacheConfig where
  /-- Base directory for cached files -/
  cacheDir : String := "./cache"
  /-- Maximum total size of cached files in bytes -/
  maxSizeBytes : Nat := 2000 * 1024 * 1024  -- 2 GB default
  deriving Repr, Inhabited

/-- Metadata for a cached file (used for LRU tracking) -/
structure CacheEntry (K : Type) where
  /-- The key identifying this cache entry -/
  key : K
  /-- Path to the cached file on disk -/
  filePath : String
  /-- Size of the cached file in bytes -/
  sizeBytes : Nat
  /-- Last access time (monotonic timestamp in ms) -/
  lastAccessTime : Nat
  deriving Repr, Inhabited

instance [BEq K] : BEq (CacheEntry K) where
  beq a b := a.filePath == b.filePath

/-- In-memory index of cached files for LRU tracking -/
structure CacheIndex (K : Type) [BEq K] [Hashable K] where
  /-- Map from keys to cache entries -/
  entries : Std.HashMap K (CacheEntry K)
  /-- Total size of all cached files in bytes -/
  totalSizeBytes : Nat
  /-- Cache configuration -/
  config : CacheConfig
  deriving Inhabited

namespace CacheIndex

/-- Create an empty cache index with the given configuration -/
def empty [BEq K] [Hashable K] (config : CacheConfig) : CacheIndex K :=
  { entries := {}, totalSizeBytes := 0, config := config }

/-- Get a cache entry by key -/
def get? [BEq K] [Hashable K] (index : CacheIndex K) (key : K) : Option (CacheEntry K) :=
  index.entries[key]?

/-- Check if a key exists in the cache -/
def contains [BEq K] [Hashable K] (index : CacheIndex K) (key : K) : Bool :=
  index.entries.contains key

end CacheIndex

end Cellar
