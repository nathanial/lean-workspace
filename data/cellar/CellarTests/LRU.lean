/-
  Tests for Cellar LRU Eviction Logic
-/
import Crucible
import Cellar

open Crucible
open Cellar

namespace CellarTests.LRU

testSuite "LRU Eviction"

-- Helper to create a test entry
def mkEntry (key : String) (size : Nat) (time : Nat) : CacheEntry String :=
  { key := key, filePath := s!"/cache/{key}", sizeBytes := size, lastAccessTime := time }

test "wouldExceedLimit returns false when under limit" := do
  let config : CacheConfig := { maxSizeBytes := 1000 }
  let index : CacheIndex String := CacheIndex.empty config
  wouldExceedLimit index 500 ≡ false

test "wouldExceedLimit returns false at exact limit" := do
  let config : CacheConfig := { maxSizeBytes := 1000 }
  let index : CacheIndex String := CacheIndex.empty config
  wouldExceedLimit index 1000 ≡ false

test "wouldExceedLimit returns true when over limit" := do
  let config : CacheConfig := { maxSizeBytes := 1000 }
  let index : CacheIndex String := CacheIndex.empty config
  wouldExceedLimit index 1001 ≡ true

test "wouldExceedLimit accounts for existing entries" := do
  let config : CacheConfig := { maxSizeBytes := 1000 }
  let index : CacheIndex String := CacheIndex.empty config
  let index' := addEntry index (mkEntry "a" 600 100)
  wouldExceedLimit index' 400 ≡ false
  wouldExceedLimit index' 401 ≡ true

test "addEntry increments totalSizeBytes" := do
  let index : CacheIndex String := CacheIndex.empty {}
  let index' := addEntry index (mkEntry "a" 100 1000)
  index'.totalSizeBytes ≡ 100
  let index'' := addEntry index' (mkEntry "b" 200 2000)
  index''.totalSizeBytes ≡ 300

test "addEntry inserts into entries map" := do
  let index : CacheIndex String := CacheIndex.empty {}
  let entry := mkEntry "test" 100 1000
  let index' := addEntry index entry
  index'.entries.size ≡ 1
  index'.contains "test" ≡ true

test "removeEntries decrements totalSizeBytes" := do
  let index : CacheIndex String := CacheIndex.empty {}
  let e1 := mkEntry "a" 100 1000
  let e2 := mkEntry "b" 200 2000
  let index' := addEntry (addEntry index e1) e2
  index'.totalSizeBytes ≡ 300
  let index'' := removeEntries index' [e1]
  index''.totalSizeBytes ≡ 200

test "removeEntries removes from entries map" := do
  let index : CacheIndex String := CacheIndex.empty {}
  let e1 := mkEntry "a" 100 1000
  let e2 := mkEntry "b" 200 2000
  let index' := addEntry (addEntry index e1) e2
  let index'' := removeEntries index' [e1]
  index''.contains "a" ≡ false
  index''.contains "b" ≡ true

test "touchEntry updates lastAccessTime" := do
  let index : CacheIndex String := CacheIndex.empty {}
  let entry := mkEntry "a" 100 1000
  let index' := addEntry index entry
  let index'' := touchEntry index' "a" 5000
  match index''.get? "a" with
  | some e => e.lastAccessTime ≡ 5000
  | none => throw (IO.userError "entry not found")

test "touchEntry preserves other fields" := do
  let index : CacheIndex String := CacheIndex.empty {}
  let entry := mkEntry "a" 100 1000
  let index' := addEntry index entry
  let index'' := touchEntry index' "a" 5000
  index''.totalSizeBytes ≡ 100
  match index''.get? "a" with
  | some e =>
    e.sizeBytes ≡ 100
    e.filePath ≡ "/cache/a"
  | none => throw (IO.userError "entry not found")

test "selectEvictions returns empty when under limit" := do
  let config : CacheConfig := { maxSizeBytes := 1000 }
  let index : CacheIndex String := CacheIndex.empty config
  let index' := addEntry index (mkEntry "a" 100 1000)
  let evictions := selectEvictions index' 100
  evictions.length ≡ 0

test "selectEvictions returns oldest entry first" := do
  let config : CacheConfig := { maxSizeBytes := 200 }
  let index : CacheIndex String := CacheIndex.empty config
  let index' := addEntry index (mkEntry "old" 100 1000)
  let index'' := addEntry index' (mkEntry "new" 100 2000)
  -- Adding 100 more would exceed 200, need to evict
  let evictions := selectEvictions index'' 100
  evictions.length ≡ 1
  match evictions[0]? with
  | some e => e.key ≡ "old"
  | none => throw (IO.userError "no eviction")

test "selectEvictions evicts multiple entries for large files" := do
  let config : CacheConfig := { maxSizeBytes := 300 }
  let index : CacheIndex String := CacheIndex.empty config
  -- Add 3 entries of 100 bytes each
  let index' := addEntry index (mkEntry "oldest" 100 1000)
  let index'' := addEntry index' (mkEntry "middle" 100 2000)
  let index''' := addEntry index'' (mkEntry "newest" 100 3000)
  -- total = 300, adding 150 needs to free at least 150
  let evictions := selectEvictions index''' 150
  -- Should evict oldest and middle (200 bytes freed)
  evictions.length ≡ 2
  match evictions[0]? with
  | some e => e.key ≡ "oldest"
  | none => throw (IO.userError "expected oldest first")
  match evictions[1]? with
  | some e => e.key ≡ "middle"
  | none => throw (IO.userError "expected middle second")

test "integration: add, touch, evict cycle" := do
  let config : CacheConfig := { maxSizeBytes := 200 }
  let index : CacheIndex String := CacheIndex.empty config
  -- Add two entries
  let e1 := mkEntry "a" 100 1000
  let e2 := mkEntry "b" 100 2000
  let index' := addEntry (addEntry index e1) e2
  -- Touch "a" to make it newer
  let index'' := touchEntry index' "a" 3000
  -- Now "b" is older (time 2000) than "a" (time 3000)
  let evictions := selectEvictions index'' 100
  evictions.length ≡ 1
  match evictions[0]? with
  | some e => e.key ≡ "b"  -- "b" should be evicted, not "a"
  | none => throw (IO.userError "no eviction")


end CellarTests.LRU
