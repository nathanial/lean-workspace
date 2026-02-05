/-
  Chronicle.Logger - Core logger with file I/O

  Provides the main Logger structure and logging functions.
-/

import Chronicle.Config
import Chronicle.Format

namespace Chronicle

/-- A logger that writes to a file -/
structure Logger where
  /-- Logger configuration -/
  config : Config
  /-- File handle for writing -/
  handle : IO.FS.Handle

namespace Logger

/-- Create a new logger, opening the file for append -/
def create (config : Config) : IO Logger := do
  -- Ensure parent directory exists
  if let some parent := config.filePath.parent then
    IO.FS.createDirAll parent
  let handle ← IO.FS.Handle.mk config.filePath .append
  pure { config, handle }

/-- Close the logger's file handle -/
def close (logger : Logger) : IO Unit := do
  logger.handle.flush

/-- Check if a level should be logged based on the threshold -/
def shouldLog (logger : Logger) (level : Level) : Bool :=
  level.meetsThreshold logger.config.minLevel

/-- Log a message at a specific level with optional context -/
def log (logger : Logger) (level : Level) (message : String)
    (context : List (String × String) := []) : IO Unit := do
  if !logger.shouldLog level then return ()

  let timestamp ← IO.monoNanosNow
  let entry : LogEntry := {
    timestamp := timestamp
    level := level
    message := message
    context := context
  }
  let line := entry.format logger.config.format
  logger.handle.putStrLn line
  logger.handle.flush

  if logger.config.alsoStderr then
    IO.eprintln line

/-- Log a structured log entry (for HTTP requests) -/
def logRequest (logger : Logger) (entry : LogEntry) : IO Unit := do
  if !logger.shouldLog entry.level then return ()
  let line := entry.format logger.config.format
  logger.handle.putStrLn line
  logger.handle.flush

  if logger.config.alsoStderr then
    IO.eprintln line

/-- Log at TRACE level -/
def trace (logger : Logger) (msg : String) : IO Unit :=
  logger.log .trace msg

/-- Log at DEBUG level -/
def debug (logger : Logger) (msg : String) : IO Unit :=
  logger.log .debug msg

/-- Log at INFO level -/
def info (logger : Logger) (msg : String) : IO Unit :=
  logger.log .info msg

/-- Log at WARN level -/
def warn (logger : Logger) (msg : String) : IO Unit :=
  logger.log .warn msg

/-- Log at ERROR level -/
def error (logger : Logger) (msg : String) : IO Unit :=
  logger.log .error msg

/-- Log at a level with context key-value pairs -/
def logWithContext (logger : Logger) (level : Level) (msg : String)
    (ctx : List (String × String)) : IO Unit :=
  logger.log level msg ctx

/-- Create a logger, run an action, then close the logger -/
def withLogger (config : Config) (action : Logger → IO α) : IO α := do
  let logger ← create config
  try
    action logger
  finally
    logger.close

end Logger
end Chronicle
