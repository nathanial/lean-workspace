/-
  Chronicle.MultiLogger - Logger that writes to multiple outputs

  Allows simultaneous logging to multiple files with different formats.
-/

import Chronicle.Logger

namespace Chronicle

/-- A logger that writes to multiple file outputs -/
structure MultiLogger where
  /-- Array of underlying loggers -/
  loggers : Array Logger

namespace MultiLogger

/-- Create a multi-logger from a list of configurations -/
def create (configs : List Config) : IO MultiLogger := do
  let mut loggers : Array Logger := #[]
  for config in configs do
    let logger ← Logger.create config
    loggers := loggers.push logger
  pure { loggers }

/-- Close all underlying loggers -/
def close (ml : MultiLogger) : IO Unit := do
  for logger in ml.loggers do
    logger.close

/-- Log a message to all outputs -/
def log (ml : MultiLogger) (level : Level) (message : String)
    (context : List (String × String) := []) : IO Unit := do
  for logger in ml.loggers do
    logger.log level message context

/-- Log a structured entry to all outputs -/
def logRequest (ml : MultiLogger) (entry : LogEntry) : IO Unit := do
  for logger in ml.loggers do
    logger.logRequest entry

/-- Log at TRACE level -/
def trace (ml : MultiLogger) (msg : String) : IO Unit :=
  ml.log .trace msg

/-- Log at DEBUG level -/
def debug (ml : MultiLogger) (msg : String) : IO Unit :=
  ml.log .debug msg

/-- Log at INFO level -/
def info (ml : MultiLogger) (msg : String) : IO Unit :=
  ml.log .info msg

/-- Log at WARN level -/
def warn (ml : MultiLogger) (msg : String) : IO Unit :=
  ml.log .warn msg

/-- Log at ERROR level -/
def error (ml : MultiLogger) (msg : String) : IO Unit :=
  ml.log .error msg

/-- Log with context key-value pairs -/
def logWithContext (ml : MultiLogger) (level : Level) (msg : String)
    (ctx : List (String × String)) : IO Unit :=
  ml.log level msg ctx

/-- Create a multi-logger, run an action, then close it -/
def withMultiLogger (configs : List Config) (action : MultiLogger → IO α) : IO α := do
  let ml ← create configs
  try
    action ml
  finally
    ml.close

end MultiLogger
end Chronicle
