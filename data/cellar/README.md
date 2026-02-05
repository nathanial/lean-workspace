# Cellar

Generic disk cache library for Lean 4 with LRU eviction.

## Features

- **Generic key type**: Cache any data type with `BEq` and `Hashable` instances
- **LRU eviction**: Automatic eviction of least recently used entries when cache is full
- **Atomic writes**: Files written via temp file + rename to prevent corruption
- **Pure Lean**: No FFI dependencies, uses standard library file operations

## Installation

Add to your `lakefile.lean`:

```lean
require cellar from git "https://github.com/nathanial/cellar" @ "master"
```

## Usage

```lean
import Cellar

-- Define your key type
structure MyKey where
  id : Nat
  deriving BEq, Hashable, Repr

-- Create cache configuration
let config : Cellar.CacheConfig := {
  cacheDir := "./my_cache"
  maxSizeBytes := 100 * 1024 * 1024  -- 100 MB
}

-- Create empty index
let index : Cellar.CacheIndex MyKey := Cellar.CacheIndex.empty config

-- Add an entry
let entry : Cellar.CacheEntry MyKey := {
  key := { id := 42 }
  filePath := "./my_cache/42.dat"
  sizeBytes := 1024
  lastAccessTime := ← Cellar.nowMs
}
let index := Cellar.addEntry index entry

-- Check for evictions before adding new file
let evictions := Cellar.selectEvictions index newFileSize
let index := Cellar.removeEntries index evictions

-- Touch entry on access
let index := Cellar.touchEntry index { id := 42 } (← Cellar.nowMs)
```

## API

### Types

- `CacheConfig` - Cache directory and size limit configuration
- `CacheEntry K` - Metadata for a cached file (key, path, size, access time)
- `CacheIndex K` - In-memory index of cached files

### Functions

- `CacheIndex.empty` - Create empty cache index
- `selectEvictions` - Get list of entries to evict for LRU
- `addEntry` - Add entry to index
- `removeEntries` - Remove evicted entries from index
- `touchEntry` - Update access time on cache hit
- `fileExists`, `readFile`, `writeFile`, `deleteFile` - File I/O operations
- `nowMs` - Get current monotonic time in milliseconds

## License

MIT
