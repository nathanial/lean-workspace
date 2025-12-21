# Compression Support

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Large (requires FFI for compression libraries)
**Dependencies:** None

## Description

Add optional transparent compression/decompression of cached data.

## Rationale

Can significantly reduce disk usage for compressible data, though adds complexity.

## Proposed Changes

- Add `compression : CompressionType` to `CacheConfig` (None, Gzip, Zstd)
- Implement compression wrappers in IO module
- Store compression metadata in cache entries

## Affected Files

- `Cellar/Config.lean`
- `Cellar/IO.lean`
- Potentially new `Cellar/Compress.lean`
