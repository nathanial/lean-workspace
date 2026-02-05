/-
  Chronicle.Config - Logger configuration

  Provides configuration options with a fluent builder pattern.
-/

import Chronicle.Level
import Chronicle.Format

namespace Chronicle

/-- Logger configuration -/
structure Config where
  /-- Path to the log file -/
  filePath : System.FilePath
  /-- Minimum log level to write (messages below this are filtered) -/
  minLevel : Level := Level.info
  /-- Output format (text or json) -/
  format : Format := Format.text
  /-- Whether to also print to stderr -/
  alsoStderr : Bool := false
deriving Repr

namespace Config

/-- Create a default configuration with the given file path -/
def default (path : System.FilePath) : Config := {
  filePath := path
  minLevel := .info
  format := .text
  alsoStderr := false
}

/-- Set the minimum log level -/
def withLevel (c : Config) (level : Level) : Config :=
  { c with minLevel := level }

/-- Set the output format -/
def withFormat (c : Config) (fmt : Format) : Config :=
  { c with format := fmt }

/-- Enable or disable stderr output -/
def withStderr (c : Config) (enabled : Bool) : Config :=
  { c with alsoStderr := enabled }

/-- Set the file path -/
def withPath (c : Config) (path : System.FilePath) : Config :=
  { c with filePath := path }

end Config
end Chronicle
