/-
  Chronicle - File-based logging library for Lean 4

  A configurable logging library that writes to files, with support for:
  - Multiple log levels (TRACE, DEBUG, INFO, WARN, ERROR)
  - Plain text and JSON output formats
  - Loom web framework integration (middleware and ActionM helpers)

  ## Quick Start

  ```lean
  import Chronicle

  def main : IO Unit := do
    let config := Chronicle.Config.default "logs/app.log"
      |>.withLevel .debug
      |>.withFormat .json

    Chronicle.Logger.withLogger config fun logger => do
      logger.info "Application started"
      logger.debug "Debug information"
      logger.warn "Warning message"
      logger.error "Error occurred"
  ```

  ## Loom Integration

  ```lean
  import Chronicle
  import Loom

  def runApp : IO Unit := do
    let logConfig := Chronicle.Config.default "logs/server.log"
    let logger ← Chronicle.Logger.create logConfig

    let app := Loom.app config
      |>.use (Chronicle.Loom.fileLogging logger)
      -- ... routes
    app.run "0.0.0.0" 3000
  ```
-/

-- Core types
import Chronicle.Level
import Chronicle.Format
import Chronicle.Config
import Chronicle.Logger
import Chronicle.MultiLogger
