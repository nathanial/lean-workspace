# Chronicle

A file-based logging library for Lean 4 with configurable text and JSON output formats.

## Features

- **Multiple log levels**: TRACE, DEBUG, INFO, WARN, ERROR
- **Configurable output formats**: Plain text or structured JSON
- **File-based logging**: Logs to files with automatic directory creation
- **Optional stderr mirroring**: Can output to both file and stderr
- **Loom integration**: Middleware for HTTP request logging and ActionM helpers
- **Builder pattern configuration**: Fluent API for setting up loggers

## Installation

Add to your `lakefile.lean`:

```lean
require chronicle from git "https://github.com/nathanial/chronicle" @ "v0.0.1"
```

## Quick Start

```lean
import Chronicle

def main : IO Unit := do
  -- Create a logger configuration
  let config := Chronicle.Config.default "logs/app.log"
    |>.withLevel .debug
    |>.withFormat .json

  -- Use withLogger for automatic cleanup
  Chronicle.Logger.withLogger config fun logger => do
    logger.info "Application started"
    logger.debug "Debug information"
    logger.warn "Warning message"
    logger.error "Error occurred"
```

## Configuration

```lean
-- Create default config (INFO level, text format)
let config := Chronicle.Config.default "logs/app.log"

-- Customize with builder pattern
let config := Chronicle.Config.default "logs/app.log"
  |>.withLevel .trace      -- Set minimum log level
  |>.withFormat .json      -- Use JSON output format
  |>.withStderr true       -- Also print to stderr
```

### Log Levels

| Level | Description |
|-------|-------------|
| `trace` | Fine-grained debugging information |
| `debug` | Debugging information |
| `info` | General information (default threshold) |
| `warn` | Warning messages |
| `error` | Error messages |

### Output Formats

**Text format** (default):
```
[1234.567] [INFO ] Application started
[1234.890] [DEBUG] Processing request (42.5ms)
```

**JSON format**:
```json
{"timestamp":1234567000000,"level":"INFO","message":"Application started"}
{"timestamp":1234890000000,"level":"DEBUG","message":"Processing request","duration_ms":42.5}
```

## Loom Integration

Chronicle integrates with the Loom web framework for HTTP request logging.

### Middleware

```lean
import Chronicle
import Loom

def runApp : IO Unit := do
  let logConfig := Chronicle.Config.default "logs/server.log"
    |>.withFormat .json
  let logger ← Chronicle.Logger.create logConfig

  let app := Loom.app config
    |>.use (Chronicle.Loom.fileLogging logger)  -- Log all requests
    |>.use Middleware.securityHeaders
    |>.get "/" "home" homeAction
    -- ... more routes

  app.run "0.0.0.0" 3000
```

### Available Middleware

- `Chronicle.Loom.fileLogging`: Basic file logging
- `Chronicle.Loom.combinedLogging`: File + optional stderr logging
- `Chronicle.Loom.errorLogging`: Logs errors at ERROR level, warnings at WARN level

### ActionM Helpers

Log from within Loom actions:

```lean
def myAction : Loom.ActionM Herald.Core.Response := do
  Chronicle.Loom.ActionM.logInfo logger "Processing request"
  Chronicle.Loom.ActionM.logDebug logger "User ID: 123"
  -- ... action logic
  Chronicle.Loom.ActionM.logError logger "Something went wrong"
  pure response
```

## API Reference

### Chronicle.Level

```lean
inductive Level where
  | trace | debug | info | warn | error

def Level.meetsThreshold (level threshold : Level) : Bool
def Level.toString : Level → String
def Level.fromString : String → Option Level
```

### Chronicle.Config

```lean
structure Config where
  filePath : System.FilePath
  minLevel : Level := .info
  format : Format := .text
  alsoStderr : Bool := false

def Config.default (path : System.FilePath) : Config
def Config.withLevel (c : Config) (l : Level) : Config
def Config.withFormat (c : Config) (f : Format) : Config
def Config.withStderr (c : Config) (enabled : Bool) : Config
```

### Chronicle.Logger

```lean
structure Logger where
  config : Config
  handle : IO.FS.Handle

def Logger.create (config : Config) : IO Logger
def Logger.close (logger : Logger) : IO Unit
def Logger.withLogger (config : Config) (action : Logger → IO α) : IO α

-- Logging methods
def Logger.log (l : Logger) (level : Level) (msg : String) : IO Unit
def Logger.trace (l : Logger) (msg : String) : IO Unit
def Logger.debug (l : Logger) (msg : String) : IO Unit
def Logger.info (l : Logger) (msg : String) : IO Unit
def Logger.warn (l : Logger) (msg : String) : IO Unit
def Logger.error (l : Logger) (msg : String) : IO Unit
```

### Chronicle.LogEntry

For structured logging with HTTP request context:

```lean
structure LogEntry where
  timestamp : Nat
  level : Level
  message : String
  context : List (String × String) := []
  requestId : Option String := none
  path : Option String := none
  method : Option String := none
  statusCode : Option Nat := none
  durationMs : Option Float := none
```

## Building

```bash
cd chronicle
lake build        # Build the library
lake test         # Run tests
```

## License

MIT License - see [LICENSE](LICENSE) for details.
