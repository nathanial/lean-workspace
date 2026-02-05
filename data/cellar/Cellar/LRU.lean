/-
  Cellar LRU (Least Recently Used) Cache Eviction Logic
  Generic over key type K.
-/
import Cellar.Config

namespace Cellar

/-- Select entries to evict to bring cache under size limit.
    Returns list of entries to evict (oldest first). -/
def selectEvictions [BEq K] [Hashable K] (index : CacheIndex K) (newFileSize : Nat)
    : List (CacheEntry K) :=
  let targetMax := index.config.maxSizeBytes
  if index.totalSizeBytes + newFileSize <= targetMax then
    []  -- No eviction needed
  else
    -- Sort entries by lastAccessTime (oldest first)
    let sorted := index.entries.toList.map Prod.snd
      |>.toArray.qsort (fun a b => a.lastAccessTime < b.lastAccessTime)
      |>.toList

    -- Calculate how much space we need to free
    let currentTotal := index.totalSizeBytes + newFileSize
    let needToFree := currentTotal - targetMax

    -- Accumulate entries to evict until we have enough space
    Id.run do
      let mut toEvict : List (CacheEntry K) := []
      let mut freedBytes : Nat := 0
      for entry in sorted do
        if freedBytes >= needToFree then
          break
        toEvict := entry :: toEvict
        freedBytes := freedBytes + entry.sizeBytes
      return toEvict.reverse  -- Return in oldest-first order

/-- Update index after adding a new entry -/
def addEntry [BEq K] [Hashable K] (index : CacheIndex K) (entry : CacheEntry K)
    : CacheIndex K :=
  { index with
    entries := index.entries.insert entry.key entry
    totalSizeBytes := index.totalSizeBytes + entry.sizeBytes
  }

/-- Update index after evicting entries -/
def removeEntries [BEq K] [Hashable K] (index : CacheIndex K) (evicted : List (CacheEntry K))
    : CacheIndex K :=
  let entries' := evicted.foldl (fun m e => m.erase e.key) index.entries
  let removedSize := evicted.foldl (fun acc e => acc + e.sizeBytes) 0
  { index with
    entries := entries'
    totalSizeBytes := index.totalSizeBytes - removedSize
  }

/-- Update access time for an entry (on cache hit) -/
def touchEntry [BEq K] [Hashable K] (index : CacheIndex K) (key : K) (newTime : Nat)
    : CacheIndex K :=
  match index.entries[key]? with
  | some entry =>
    let entry' := { entry with lastAccessTime := newTime }
    { index with entries := index.entries.insert key entry' }
  | none => index  -- Entry not in index (shouldn't happen)

/-- Check if adding a file would exceed the cache limit -/
def wouldExceedLimit [BEq K] [Hashable K] (index : CacheIndex K) (newFileSize : Nat) : Bool :=
  index.totalSizeBytes + newFileSize > index.config.maxSizeBytes

end Cellar
