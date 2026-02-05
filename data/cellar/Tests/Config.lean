/-
  Tests for Cellar Configuration and CacheIndex
-/
import Crucible
import Cellar

open Crucible
open Cellar

namespace Tests.Config

testSuite "CacheConfig"

test "default cacheDir is ./cache" := do
  let config : CacheConfig := {}
  config.cacheDir ≡ "./cache"

test "default maxSizeBytes is 2GB" := do
  let config : CacheConfig := {}
  config.maxSizeBytes ≡ 2000 * 1024 * 1024

test "custom config values" := do
  let config : CacheConfig := { cacheDir := "/tmp/test", maxSizeBytes := 1000 }
  config.cacheDir ≡ "/tmp/test"
  config.maxSizeBytes ≡ 1000


end Tests.Config

namespace Tests.CacheIndex

testSuite "CacheIndex"

test "empty creates index with zero size" := do
  let config : CacheConfig := { maxSizeBytes := 1000 }
  let index : CacheIndex String := CacheIndex.empty config
  index.totalSizeBytes ≡ 0

test "empty creates index with given config" := do
  let config : CacheConfig := { cacheDir := "/custom", maxSizeBytes := 5000 }
  let index : CacheIndex String := CacheIndex.empty config
  index.config.cacheDir ≡ "/custom"
  index.config.maxSizeBytes ≡ 5000

test "get? returns None for missing key" := do
  let index : CacheIndex String := CacheIndex.empty {}
  let result := index.get? "missing"
  shouldBeNone result

test "contains returns false for missing key" := do
  let index : CacheIndex String := CacheIndex.empty {}
  index.contains "missing" ≡ false

test "get? returns Some after addEntry" := do
  let index : CacheIndex String := CacheIndex.empty {}
  let entry : CacheEntry String := {
    key := "test-key"
    filePath := "/cache/test"
    sizeBytes := 100
    lastAccessTime := 1000
  }
  let index' := addEntry index entry
  let result := index'.get? "test-key"
  shouldBeSome result entry

test "contains returns true after addEntry" := do
  let index : CacheIndex String := CacheIndex.empty {}
  let entry : CacheEntry String := {
    key := "test-key"
    filePath := "/cache/test"
    sizeBytes := 100
    lastAccessTime := 1000
  }
  let index' := addEntry index entry
  index'.contains "test-key" ≡ true


end Tests.CacheIndex
