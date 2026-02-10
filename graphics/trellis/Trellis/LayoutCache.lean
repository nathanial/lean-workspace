/-
  Trellis Layout Cache
  Bounded LRU cache for local-coordinate subtree layout results.
-/
import Std.Data.HashMap
import Trellis.Types
import Trellis.Result

namespace Trellis

/-- Cached local subtree layouts keyed by layout-affecting inputs. -/
structure CachedSubtree where
  /-- Local coordinates with subtree root at (0,0); root layout is first. -/
  layouts : Array ComputedLayout
deriving Inhabited

/-- Key for subtree layout cache entries. -/
structure LayoutCacheKey where
  subtreeId : Nat
  signature : UInt64
  availableWidth : Length
  availableHeight : Length
  subgridSignature : UInt64
deriving BEq, Inhabited

private def hashLength (x : Length) : UInt64 :=
  hash (toString (repr x))

instance : Hashable LayoutCacheKey where
  hash k :=
    let h0 := hash k.subtreeId
    let h1 := mixHash h0 (hash k.signature)
    let h2 := mixHash h1 (hashLength k.availableWidth)
    let h3 := mixHash h2 (hashLength k.availableHeight)
    mixHash h3 (hash k.subgridSignature)

/-- Default maximum number of cached subtrees. -/
def defaultLayoutCacheCapacity : Nat := 1024

/-- LRU cache entry for a cached subtree. -/
structure LayoutCacheEntry where
  value : CachedSubtree
  prev : Option LayoutCacheKey := none
  next : Option LayoutCacheKey := none

/-- Persistent LRU cache for subtree layout reuse across frames. -/
structure LayoutCache where
  cache : Std.HashMap LayoutCacheKey LayoutCacheEntry := {}
  head : Option LayoutCacheKey := none
  tail : Option LayoutCacheKey := none
  capacity : Nat := defaultLayoutCacheCapacity
deriving Inhabited

namespace LayoutCache

/-- Create an empty cache with default capacity. -/
def empty : LayoutCache :=
  { cache := {}
    head := none
    tail := none
    capacity := defaultLayoutCacheCapacity }

/-- Create an empty cache with explicit capacity. -/
def withCapacity (capacity : Nat) : LayoutCache :=
  { cache := {}
    head := none
    tail := none
    capacity := capacity }

/-- Number of entries in the cache. -/
def size (lc : LayoutCache) : Nat :=
  lc.cache.size

/-- Clear all entries. -/
def clear (lc : LayoutCache) : LayoutCache :=
  { lc with cache := {}, head := none, tail := none }

/-- Look up a cached subtree. -/
def find? (lc : LayoutCache) (key : LayoutCacheKey) : Option CachedSubtree :=
  (lc.cache[key]?).map (·.value)

private def updateEntry (lc : LayoutCache) (key : LayoutCacheKey) (entry : LayoutCacheEntry) : LayoutCache :=
  { lc with cache := lc.cache.insert key entry }

private def detach (lc : LayoutCache) (entry : LayoutCacheEntry) : LayoutCache :=
  let prev := entry.prev
  let next := entry.next
  let lc :=
    match prev with
    | some p =>
      match lc.cache[p]? with
      | some pEntry => updateEntry lc p { pEntry with next := next }
      | none => lc
    | none =>
      { lc with head := next }
  let lc :=
    match next with
    | some n =>
      match lc.cache[n]? with
      | some nEntry => updateEntry lc n { nEntry with prev := prev }
      | none => lc
    | none =>
      { lc with tail := prev }
  lc

private def appendToTail (lc : LayoutCache) (key : LayoutCacheKey) (entry : LayoutCacheEntry) : LayoutCache :=
  match lc.tail with
  | none =>
    let entry' := { entry with prev := none, next := none }
    { lc with cache := lc.cache.insert key entry', head := some key, tail := some key }
  | some tailKey =>
    match lc.cache[tailKey]? with
    | some tailEntry =>
      let lc := updateEntry lc tailKey { tailEntry with next := some key }
      let entry' := { entry with prev := some tailKey, next := none }
      { lc with cache := lc.cache.insert key entry', tail := some key }
    | none =>
      let entry' := { entry with prev := none, next := none }
      { lc with cache := lc.cache.insert key entry', head := some key, tail := some key }

private def removeEntry (lc : LayoutCache) (key : LayoutCacheKey) (entry : LayoutCacheEntry) : LayoutCache :=
  let prev := entry.prev
  let next := entry.next
  let lc :=
    match prev with
    | some p =>
      match lc.cache[p]? with
      | some pEntry => updateEntry lc p { pEntry with next := next }
      | none => lc
    | none =>
      { lc with head := next }
  let lc :=
    match next with
    | some n =>
      match lc.cache[n]? with
      | some nEntry => updateEntry lc n { nEntry with prev := prev }
      | none => lc
    | none =>
      { lc with tail := prev }
  { lc with cache := lc.cache.erase key }

private def evictIfNeeded (lc : LayoutCache) : LayoutCache :=
  if lc.cache.size <= lc.capacity then
    lc
  else
    match lc.head with
    | none => lc
    | some headKey =>
      match lc.cache[headKey]? with
      | some headEntry => removeEntry lc headKey headEntry
      | none => { lc with head := none, tail := none }

/-- Mark an entry as most-recently used. -/
def touch (lc : LayoutCache) (key : LayoutCacheKey) : LayoutCache :=
  match lc.cache[key]? with
  | none => lc
  | some entry =>
    if lc.tail == some key then
      lc
    else
      let lc := detach lc entry
      appendToTail lc key entry

/-- Insert/update a cached subtree and enforce LRU capacity. -/
def insert (lc : LayoutCache) (key : LayoutCacheKey) (value : CachedSubtree) : LayoutCache :=
  let lc :=
    match lc.cache[key]? with
    | some entry =>
      let entry' := { entry with value := value }
      touch (updateEntry lc key entry') key
    | none =>
      let entry : LayoutCacheEntry := { value := value }
      appendToTail lc key entry
  evictIfNeeded lc

end LayoutCache

end Trellis
