# Chronicle Roadmap

This document outlines potential improvements, new features, and cleanup opportunities for the Chronicle logging library.

## Current State Summary

Chronicle is a file-based logging library for Lean 4 with the following capabilities:

**Current Features:**
- Five log levels: TRACE, DEBUG, INFO, WARN, ERROR with threshold filtering
- Two output formats: plain text and structured JSON
- File-based logging with automatic parent directory creation
- Optional stderr mirroring
- Builder pattern configuration via fluent API
- HTTP request context fields (path, method, statusCode, durationMs, requestId)
- MultiLogger for writing to multiple outputs simultaneously
- RAII-style `withLogger` for automatic resource cleanup
- Loom web framework integration (middleware in `Loom.Chronicle` module)
- Audit logging support via `Loom.Audit` module

**File Structure:**
- `Chronicle/Level.lean` - Log level enum with ordering and parsing
- `Chronicle/Format.lean` - LogEntry structure and text/JSON formatters
- `Chronicle/Config.lean` - Configuration with builder pattern
- `Chronicle/Logger.lean` - Core logger with file I/O
- `Chronicle/MultiLogger.lean` - Multi-output logger wrapper

**Test Coverage:**
- Level ordering and threshold tests
- Format output tests (text and JSON)
- Config builder tests
- Logger file I/O tests
- Missing: MultiLogger tests, edge case tests, performance tests

---

## Feature Enhancements

### [Priority: High] Log Rotation

**Description:** Implement automatic log file rotation based on size, time, or both.

**Rationale:** Production applications generate large log files that need rotation to prevent disk exhaustion. This is a fundamental feature of mature logging libraries (log4j, slog, zap).

**Proposed API:**
```lean
inductive RotationPolicy where
  | none                           -- No rotation
  | bySize (maxBytes : Nat)        -- Rotate when file exceeds size
  | daily                          -- Rotate daily at midnight
  | hourly                         -- Rotate every hour
  | byCount (maxEntries : Nat)     -- Rotate after N log entries

structure Config where
  -- ... existing fields ...
  rotation : RotationPolicy := .none
  maxBackups : Nat := 5            -- Number of old files to keep
```

**Affected Files:** `Chronicle/Config.lean`, `Chronicle/Logger.lean`, new `Chronicle/Rotation.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: High] Async/Buffered Logging

**Description:** Add buffered logging with periodic or threshold-based flushing to reduce I/O overhead.

**Rationale:** Currently every log call results in a file write and flush. This is inefficient for high-throughput applications. Buffering would significantly improve performance.

**Proposed API:**
```lean
inductive FlushPolicy where
  | immediate                      -- Flush every write (current behavior)
  | onBuffer (size : Nat)          -- Flush when buffer reaches N bytes
  | periodic (intervalMs : Nat)    -- Flush every N milliseconds
  | onLevel (level : Level)        -- Flush when level >= threshold

structure Config where
  -- ... existing fields ...
  flushPolicy : FlushPolicy := .immediate
  bufferSize : Nat := 8192         -- Buffer size in bytes
```

**Affected Files:** `Chronicle/Config.lean`, `Chronicle/Logger.lean`, new `Chronicle/Buffer.lean`

**Estimated Effort:** Medium

**Dependencies:** May need background task support for periodic flushing

---

### [Priority: High] Request ID Generation and Correlation

**Description:** Auto-generate unique request IDs and propagate them through log entries for request tracing.

**Rationale:** The `LogEntry` structure has a `requestId` field but there is no mechanism to auto-generate or propagate IDs. This is essential for debugging distributed systems and correlating logs across services.

**Proposed API:**
```lean
def generateRequestId : IO String  -- UUID or ULID generation

-- In Loom middleware:
def fileLoggingWithCorrelation (logger : Logger) : Middleware
-- Reads X-Request-ID header or generates new one, adds to response headers
```

**Affected Files:** `Chronicle/Logger.lean`, `/loom/Loom/Chronicle.lean`

**Estimated Effort:** Small

**Dependencies:** UUID/ULID generation (could use simple timestamp + random)

---

### [Priority: Medium] Structured Logging with Typed Fields

**Description:** Add type-safe structured logging with compile-time field validation.

**Rationale:** The current `context : List (String x String)` loses type information. Typed fields would enable better query/filter capabilities and catch errors at compile time.

**Proposed API:**
```lean
inductive LogValue where
  | str (s : String)
  | int (n : Int)
  | float (f : Float)
  | bool (b : Bool)
  | list (vs : List LogValue)
  | map (kvs : List (String × LogValue))

structure LogEntry where
  -- ... existing fields ...
  fields : List (String × LogValue) := []  -- Replaces context
```

**Affected Files:** `Chronicle/Format.lean`, `Chronicle/Logger.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Log Filtering by Category/Module

**Description:** Support per-module or per-category log level configuration.

**Rationale:** Applications often need different log levels for different components (e.g., DEBUG for application code, WARN for libraries). This is standard in Java logging (log4j) and Rust (env_logger).

**Proposed API:**
```lean
structure Config where
  -- ... existing fields ...
  categoryLevels : HashMap String Level := {}  -- Category -> min level

def Logger.logWithCategory (cat : String) (level : Level) (msg : String) : IO Unit
```

**Affected Files:** `Chronicle/Config.lean`, `Chronicle/Logger.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Medium] Sampling/Rate Limiting

**Description:** Add configurable sampling to reduce log volume for high-frequency events.

**Rationale:** In high-throughput systems, logging every event can be prohibitive. Sampling allows capturing representative data without overwhelming storage.

**Proposed API:**
```lean
inductive Sampling where
  | none
  | rate (oneInN : Nat)            -- Log 1 in N messages
  | rateByLevel (rates : Level → Nat)  -- Per-level sampling
```

**Affected Files:** `Chronicle/Config.lean`, `Chronicle/Logger.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Medium] Console Output Formatting

**Description:** Add colored/styled console output for stderr logging with optional ANSI codes.

**Rationale:** Development logging is more readable with colors (red for errors, yellow for warnings). The `alsoStderr` option currently outputs plain text.

**Proposed API:**
```lean
inductive ConsoleFormat where
  | plain                          -- No coloring
  | colored                        -- ANSI colors by level
  | coloredWithContext             -- Colors + key highlighting

structure Config where
  -- ... existing fields ...
  consoleFormat : ConsoleFormat := .plain
```

**Affected Files:** `Chronicle/Config.lean`, `Chronicle/Logger.lean`, new `Chronicle/Console.lean`

**Estimated Effort:** Small

**Dependencies:** Could integrate with `Parlance` for ANSI styling

---

### [Priority: Low] Syslog Output

**Description:** Add output target for syslog (Unix) for system integration.

**Rationale:** Enterprise and containerized applications often require syslog integration for centralized log collection.

**Affected Files:** New `Chronicle/Syslog.lean` with FFI bindings

**Estimated Effort:** Medium

**Dependencies:** POSIX syslog FFI

---

### [Priority: Low] Remote Logging (HTTP/gRPC)

**Description:** Add network output targets for sending logs to remote collectors.

**Rationale:** Modern observability platforms (Datadog, Splunk, ELK) accept logs via HTTP. Direct integration eliminates the need for log shippers.

**Affected Files:** New `Chronicle/Remote.lean`, would use `wisp` for HTTP

**Estimated Effort:** Large

**Dependencies:** `wisp` HTTP client

---

### [Priority: Low] Exception/Error Context Capture

**Description:** Automatically capture stack traces and exception context on error-level logs.

**Rationale:** Error logs are more useful with context about where they occurred. This would require integration with Lean's exception handling.

**Affected Files:** `Chronicle/Logger.lean`, `Chronicle/Format.lean`

**Estimated Effort:** Medium

**Dependencies:** Lean runtime introspection (may be limited)

---

## Performance Improvements

### [Priority: High] Reduce String Allocation in Formatters

**Current State:** The `escapeJson` function uses string concatenation in a fold, creating many intermediate strings.

**Proposed Change:** Use a `StringBuilder` or `Array Char` accumulator for O(n) formatting instead of O(n^2).

**Benefits:** Significant performance improvement for log entries with long messages or many special characters.

**Affected Files:** `Chronicle/Format.lean` (lines 63-72)

**Estimated Effort:** Small

---

### [Priority: Medium] Lazy Message Evaluation

**Current State:** Log messages are evaluated even when below threshold level.

**Proposed Change:** Accept `Unit -> String` thunks for expensive message construction.

**Proposed API:**
```lean
def Logger.debugLazy (logger : Logger) (mkMsg : Unit → String) : IO Unit :=
  if logger.shouldLog .debug then
    logger.log .debug (mkMsg ())
  else
    pure ()
```

**Benefits:** Avoids computing expensive log messages that will be filtered.

**Affected Files:** `Chronicle/Logger.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Pre-allocated Entry Pool

**Current State:** Each log call allocates a new `LogEntry` structure.

**Proposed Change:** For high-frequency logging, provide an entry pool or builder that reuses allocations.

**Benefits:** Reduced GC pressure in tight loops.

**Affected Files:** `Chronicle/Format.lean`, `Chronicle/Logger.lean`

**Estimated Effort:** Medium

---

### [Priority: Low] Compile-time Level Elimination

**Current State:** Level checks happen at runtime.

**Proposed Change:** Provide compile-time macros to completely eliminate log calls below a build-time threshold.

**Benefits:** Zero runtime cost for disabled log levels.

**Affected Files:** New `Chronicle/Macros.lean`

**Estimated Effort:** Medium

---

## API Improvements

### [Priority: High] Logger Typeclass

**Description:** Define a `Loggable` typeclass for polymorphic logging.

**Rationale:** Currently code must depend on concrete `Logger` or `MultiLogger` types. A typeclass would enable more flexible composition and testing with mock loggers.

**Proposed API:**
```lean
class Loggable (m : Type → Type) where
  log : Level → String → List (String × String) → m Unit
  logEntry : LogEntry → m Unit

instance : Loggable (ReaderT Logger IO) := ...
instance : Loggable (ReaderT MultiLogger IO) := ...

-- For testing:
structure MockLogger where
  entries : IO.Ref (Array LogEntry)
instance : Loggable (ReaderT MockLogger IO) := ...
```

**Affected Files:** New `Chronicle/Class.lean`, `Chronicle/Logger.lean`, `Chronicle/MultiLogger.lean`

**Estimated Effort:** Medium

---

### [Priority: Medium] More LogEntry Builder Helpers

**Description:** Add convenience constructors for common logging patterns.

**Rationale:** Creating `LogEntry` structures is verbose. Builder helpers would improve ergonomics.

**Proposed API:**
```lean
def LogEntry.simple (level : Level) (msg : String) : IO LogEntry
def LogEntry.withFields (level : Level) (msg : String) (ctx : List (String × String)) : IO LogEntry
def LogEntry.httpRequest (method path : String) (status : Nat) (duration : Float) : IO LogEntry
```

**Affected Files:** `Chronicle/Format.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Global Logger Option

**Description:** Provide optional global logger access for simpler integration.

**Rationale:** Threading a logger through every function is tedious. A global option (like Go's `log` package) would be convenient for simple applications.

**Proposed API:**
```lean
def Chronicle.setGlobal (logger : Logger) : IO Unit
def Chronicle.info (msg : String) : IO Unit  -- Uses global logger
def Chronicle.debug (msg : String) : IO Unit
-- etc.
```

**Affected Files:** New `Chronicle/Global.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Environment-based Configuration

**Description:** Support configuration via environment variables.

**Rationale:** Production deployments often configure logging via environment. This is standard practice for 12-factor apps.

**Proposed API:**
```lean
def Config.fromEnv : IO Config
-- Reads LOG_LEVEL, LOG_FORMAT, LOG_FILE, LOG_STDERR from environment
```

**Affected Files:** `Chronicle/Config.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Rename `alsoStderr` to `console` or `stderr`

**Description:** The `alsoStderr` field name is verbose and unconventional.

**Rationale:** Most logging libraries use `console` or simply `stderr` for this option.

**Affected Files:** `Chronicle/Config.lean`, `Chronicle/Logger.lean`

**Estimated Effort:** Small (breaking change)

---

## Integration Opportunities

### [Priority: High] ActionM Logging Helpers

**Description:** Add logging helpers that work within Loom's `ActionM` monad.

**Rationale:** The README mentions `Chronicle.Loom.ActionM.logInfo` but this does not exist. Adding it would complete the Loom integration.

**Proposed API:**
```lean
-- In Loom.Chronicle or Chronicle.Loom.ActionM:
def logInfo (msg : String) : ActionM Unit  -- Uses logger from context
def logDebug (msg : String) : ActionM Unit
def logWarn (msg : String) : ActionM Unit
def logError (msg : String) : ActionM Unit
def logWithContext (level : Level) (msg : String) (ctx : List (String × String)) : ActionM Unit
```

**Affected Files:** `/loom/Loom/Chronicle.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Oracle Client Logging Integration

**Description:** Add logging support for the Oracle (OpenRouter) client to trace API calls.

**Rationale:** Debugging AI integrations benefits from logging request/response details.

**Affected Files:** `/oracle/Oracle/Client.lean`, new integration module

**Estimated Effort:** Small

---

### [Priority: Medium] Citadel Server Request Logging

**Description:** Add native request logging to Citadel that does not require Loom.

**Rationale:** Citadel users who do not use Loom have no built-in logging support.

**Affected Files:** `/citadel/Citadel/Server.lean`, new `Citadel/Logging.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Terminus Widget for Log Viewing

**Description:** Create a terminus widget for displaying and filtering logs in TUI applications.

**Rationale:** Applications like `lighthouse` and `enchiridion` could benefit from integrated log viewing.

**Affected Files:** New module in terminus or chronicle

**Estimated Effort:** Medium

---

### [Priority: Low] Ledger-based Structured Log Storage

**Description:** Optionally store logs in a Ledger database for queryable structured logging.

**Rationale:** Ledger's time-travel queries would enable powerful log analysis capabilities.

**Affected Files:** New `Chronicle/Ledger.lean`

**Estimated Effort:** Medium

---

## Code Cleanup / Technical Debt

### [Priority: High] Remove Duplicate Middleware Implementations

**Issue:** `Loom.Chronicle` has four nearly identical middleware functions (`fileLogging`, `errorLogging`, `fileLoggingMulti`, `errorLoggingMulti`).

**Location:** `/loom/Loom/Chronicle.lean` lines 14-95

**Action Required:** Extract shared logic into helper functions or use generics.

**Estimated Effort:** Small

---

### [Priority: Medium] Add `ToString` Instance for Level

**Issue:** `Level` has a `toString` method but no `ToString` instance.

**Location:** `Chronicle/Level.lean`

**Action Required:** Add `instance : ToString Level := { toString := Level.toString }`

**Estimated Effort:** Small

---

### [Priority: Medium] Use ISO 8601 Timestamps

**Issue:** Timestamps use monotonic nanoseconds which are not human-readable or portable.

**Location:** `Chronicle/Format.lean` lines 42-48

**Action Required:** Add wall-clock timestamp option with ISO 8601 format (requires FFI or shell workaround as in homebase-app).

**Estimated Effort:** Small

---

### [Priority: Medium] Inconsistent Context Field Naming

**Issue:** JSON output uses `context` for key-value pairs but HTTP fields are at top level.

**Location:** `Chronicle/Format.lean` lines 89-94

**Action Required:** Consider flattening context into top-level fields or making behavior configurable.

**Estimated Effort:** Small

---

### [Priority: Low] DecidableEq Instance for Level is Verbose

**Issue:** The `DecidableEq Level` instance explicitly enumerates 25 cases.

**Location:** `Chronicle/Level.lean` lines 64-75

**Action Required:** Could simplify by deriving or using `toNat` comparison.

**Estimated Effort:** Small

---

### [Priority: Low] Missing Module Documentation

**Issue:** Source files lack comprehensive module-level documentation with usage examples.

**Location:** All files in `Chronicle/`

**Action Required:** Add doc comments with examples following Lean conventions.

**Estimated Effort:** Small

---

## Testing Improvements

### [Priority: High] Add MultiLogger Tests

**Issue:** `MultiLogger` has no test coverage.

**Location:** Tests should be in `Tests/Main.lean`

**Action Required:** Add tests for:
- Creating multi-logger with multiple configs
- Writing to multiple files
- Different format combinations
- Close/cleanup behavior

**Estimated Effort:** Small

---

### [Priority: High] Add LogEntry JSON Roundtrip Tests

**Issue:** JSON output is tested for structure but not for parsability or completeness.

**Location:** `Tests/Main.lean` namespace `Tests.Format`

**Action Required:** Add tests that parse the JSON output and verify all fields.

**Estimated Effort:** Small

---

### [Priority: Medium] Add Edge Case Tests

**Issue:** Missing tests for edge cases like empty messages, special characters, very long messages.

**Location:** `Tests/Main.lean`

**Action Required:** Add tests for:
- Empty string messages
- Messages with only whitespace
- Very long messages (>64KB)
- All JSON special characters in messages
- Unicode and emoji in messages
- Null bytes in messages

**Estimated Effort:** Small

---

### [Priority: Medium] Add Concurrent Access Tests

**Issue:** No tests for multiple loggers writing to the same file.

**Location:** `Tests/Main.lean`

**Action Required:** Add tests verifying file handle behavior under concurrent access.

**Estimated Effort:** Medium

---

### [Priority: Medium] Add Performance Benchmarks

**Issue:** No performance benchmarks to detect regressions.

**Location:** New `Benchmarks/` directory

**Action Required:** Create benchmarks for:
- Log throughput (messages/second)
- Memory usage under load
- JSON vs text format overhead
- Buffered vs immediate flush comparison

**Estimated Effort:** Medium

---

### [Priority: Low] Add Property-Based Tests

**Issue:** Current tests use fixed examples rather than property-based testing.

**Location:** `Tests/Main.lean`

**Action Required:** Use `plausible` (already used by tincture/chroma) for property-based tests:
- JSON escaping roundtrips correctly
- Level ordering is total
- Threshold filtering is monotonic

**Estimated Effort:** Small

---

### [Priority: Low] Integration Tests with Loom

**Issue:** No integration tests for Loom middleware.

**Location:** `/loom/Tests/Main.lean` or new test file

**Action Required:** Add tests that:
- Verify request logging captures all expected fields
- Test error-level detection based on status codes
- Verify log file output during request handling

**Estimated Effort:** Medium

---

## Summary of Priorities

### Immediate (High Priority)
1. Log Rotation - Essential for production use
2. Async/Buffered Logging - Performance critical
3. Request ID Generation - Debugging essential
4. Logger Typeclass - API flexibility
5. ActionM Logging Helpers - Complete Loom integration
6. Add MultiLogger Tests - Test coverage gap
7. Reduce String Allocation - Easy performance win
8. Remove Duplicate Middleware - Code quality

### Near-term (Medium Priority)
1. Structured Logging with Typed Fields
2. Log Filtering by Category
3. Sampling/Rate Limiting
4. Console Output Formatting
5. Lazy Message Evaluation
6. More LogEntry Builder Helpers
7. Environment-based Configuration
8. ISO 8601 Timestamps
9. Edge Case and Concurrent Access Tests
10. Performance Benchmarks

### Future (Low Priority)
1. Syslog Output
2. Remote Logging
3. Exception Context Capture
4. Compile-time Level Elimination
5. Terminus Log Widget
6. Ledger-based Log Storage
7. Property-Based Tests
8. Loom Integration Tests
