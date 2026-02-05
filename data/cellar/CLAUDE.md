# CLAUDE.md

Generic disk cache library for Lean 4 with LRU eviction.

## Build & Test

```bash
lake build
lake test
```

## Project Structure

```
Cellar/
  Config.lean   -- CacheConfig, CacheEntry, CacheIndex types
  LRU.lean      -- LRU eviction logic (selectEvictions, addEntry, removeEntries, touchEntry)
  IO.lean       -- File I/O operations (atomic writes via temp file + rename)
Tests/
  Main.lean     -- Test driver
  Config.lean   -- Config type tests
  LRU.lean      -- LRU algorithm tests
  IO.lean       -- File I/O tests
```

## Key Types

- `CacheConfig` - Cache directory path and max size in bytes
- `CacheEntry K` - Metadata for cached file (key, filePath, sizeBytes, lastAccessTime)
- `CacheIndex K` - In-memory index of cached files (requires `BEq K` and `Hashable K`)

## Key Functions

- `CacheIndex.empty` - Create empty index from config
- `selectEvictions` - Get entries to evict before adding new file (LRU order)
- `addEntry` / `removeEntries` - Modify index
- `touchEntry` - Update access time on cache hit
- `writeFile` - Atomic write (temp file + rename)
- `nowMs` - Current monotonic time in milliseconds

## Dependencies

- crucible (test framework)
