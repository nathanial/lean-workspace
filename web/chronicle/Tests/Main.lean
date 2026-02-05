/-
  Chronicle Test Suite
  Main entry point for running all tests.
-/

import Chronicle
import Crucible

open Crucible

/-- Check if a string contains a substring -/
def String.containsSubstr (s : String) (sub : String) : Bool :=
  (s.splitOn sub).length > 1

namespace Tests.Level

open Chronicle

testSuite "Chronicle.Level"

test "level ordering trace < debug" :=
  shouldSatisfy (Level.trace < Level.debug) "trace < debug"

test "level ordering debug < info" :=
  shouldSatisfy (Level.debug < Level.info) "debug < info"

test "level ordering info < warn" :=
  shouldSatisfy (Level.info < Level.warn) "info < warn"

test "level ordering warn < error" :=
  shouldSatisfy (Level.warn < Level.error) "warn < error"

test "meetsThreshold same level" :=
  shouldSatisfy (Level.meetsThreshold .info .info) "info meets info"

test "meetsThreshold higher meets lower" :=
  shouldSatisfy (Level.meetsThreshold .error .debug) "error meets debug"

test "meetsThreshold lower does not meet higher" :=
  shouldSatisfy (!(Level.meetsThreshold .debug .info)) "debug does not meet info"

test "toString returns uppercase" := do
  Level.trace.toString ≡ "TRACE"
  Level.debug.toString ≡ "DEBUG"
  Level.info.toString ≡ "INFO"
  Level.warn.toString ≡ "WARN"
  Level.error.toString ≡ "ERROR"

test "fromString parses lowercase" := do
  Level.fromString "trace" ≡ some Level.trace
  Level.fromString "debug" ≡ some Level.debug
  Level.fromString "info" ≡ some Level.info
  Level.fromString "warn" ≡ some Level.warn
  Level.fromString "error" ≡ some Level.error

test "fromString parses uppercase" := do
  Level.fromString "TRACE" ≡ some Level.trace
  Level.fromString "INFO" ≡ some Level.info

test "fromString returns none for invalid" :=
  Level.fromString "invalid" ≡ none

test "fromString handles warning alias" :=
  Level.fromString "warning" ≡ some Level.warn



end Tests.Level

namespace Tests.Format

open Crucible
open Chronicle

testSuite "Chronicle.Format"

test "formatText includes level" := do
  let entry : LogEntry := {
    timestamp := 1234567890000000  -- 1234.567 seconds
    level := .info
    message := "test message"
  }
  let text := entry.formatText
  shouldSatisfy (text.containsSubstr "[INFO") "should contain level"

test "formatText includes message" := do
  let entry : LogEntry := {
    timestamp := 0
    level := .warn
    message := "warning here"
  }
  let text := entry.formatText
  shouldSatisfy (text.containsSubstr "warning here") "should contain message"

test "formatText includes duration when present" := do
  let entry : LogEntry := {
    timestamp := 0
    level := .info
    message := "request"
    durationMs := some 42.5
  }
  let text := entry.formatText
  shouldSatisfy (text.containsSubstr "ms)") "should contain duration suffix"

test "formatJson is valid structure" := do
  let entry : LogEntry := {
    timestamp := 1000
    level := .error
    message := "error occurred"
  }
  let json := entry.formatJson
  shouldSatisfy (json.startsWith "{") "should start with {"
  shouldSatisfy (json.endsWith "}") "should end with }"

test "formatJson includes required fields" := do
  let entry : LogEntry := {
    timestamp := 5000
    level := .debug
    message := "debug msg"
  }
  let json := entry.formatJson
  shouldSatisfy (json.containsSubstr "\"timestamp\":5000") "should have timestamp"
  shouldSatisfy (json.containsSubstr "\"level\":\"DEBUG\"") "should have level"
  shouldSatisfy (json.containsSubstr "\"message\":\"debug msg\"") "should have message"

test "formatJson escapes special characters" := do
  let entry : LogEntry := {
    timestamp := 0
    level := .info
    message := "line1\nline2\"quoted\""
  }
  let json := entry.formatJson
  shouldSatisfy (json.containsSubstr "\\n") "should escape newlines"
  shouldSatisfy (json.containsSubstr "\\\"") "should escape quotes"

test "formatJson includes optional fields when present" := do
  let entry : LogEntry := {
    timestamp := 0
    level := .info
    message := "request"
    path := some "/api/users"
    method := some "GET"
    statusCode := some 200
    durationMs := some 15.5
  }
  let json := entry.formatJson
  shouldSatisfy (json.containsSubstr "\"path\":\"/api/users\"") "should have path"
  shouldSatisfy (json.containsSubstr "\"method\":\"GET\"") "should have method"
  shouldSatisfy (json.containsSubstr "\"status\":200") "should have status"



end Tests.Format

namespace Tests.Config

open Crucible
open Chronicle

testSuite "Chronicle.Config"

test "default creates config with path" := do
  let cfg := Config.default "test.log"
  cfg.filePath.toString ≡ "test.log"

test "default uses info level" := do
  let cfg := Config.default "test.log"
  cfg.minLevel ≡ Level.info

test "default uses text format" := do
  let cfg := Config.default "test.log"
  cfg.format ≡ Format.text

test "default has stderr disabled" := do
  let cfg := Config.default "test.log"
  shouldSatisfy (!cfg.alsoStderr) "stderr should be disabled by default"

test "withLevel changes level" := do
  let cfg := Config.default "test.log"
    |>.withLevel .debug
  cfg.minLevel ≡ Level.debug

test "withFormat changes format" := do
  let cfg := Config.default "test.log"
    |>.withFormat .json
  cfg.format ≡ Format.json

test "withStderr enables stderr" := do
  let cfg := Config.default "test.log"
    |>.withStderr true
  shouldSatisfy cfg.alsoStderr "stderr should be enabled"

test "builder chain works" := do
  let cfg := Config.default "app.log"
    |>.withLevel .trace
    |>.withFormat .json
    |>.withStderr true
  cfg.filePath.toString ≡ "app.log"
  cfg.minLevel ≡ Level.trace
  cfg.format ≡ Format.json
  shouldSatisfy cfg.alsoStderr "stderr should be enabled in chain"



end Tests.Config

namespace Tests.Logger

open Crucible
open Chronicle

testSuite "Chronicle.Logger"

test "create and write to file" := do
  let tempPath : System.FilePath := "/tmp/chronicle_test_basic.log"
  let cfg := Config.default tempPath
  let logger ← Logger.create cfg
  logger.info "test log message"
  logger.close

  let content ← IO.FS.readFile tempPath
  shouldSatisfy (content.containsSubstr "test log message") "should contain message"

  -- Cleanup
  IO.FS.removeFile tempPath

test "respects log level threshold" := do
  let tempPath : System.FilePath := "/tmp/chronicle_test_level.log"
  let cfg := Config.default tempPath |>.withLevel .warn
  let logger ← Logger.create cfg
  logger.debug "debug message"  -- Should be filtered
  logger.warn "warn message"    -- Should be logged
  logger.error "error message"  -- Should be logged
  logger.close

  let content ← IO.FS.readFile tempPath
  shouldSatisfy (!content.containsSubstr "debug message") "should not contain debug"
  shouldSatisfy (content.containsSubstr "warn message") "should contain warn"
  shouldSatisfy (content.containsSubstr "error message") "should contain error"

  IO.FS.removeFile tempPath

test "json format produces valid json" := do
  let tempPath : System.FilePath := "/tmp/chronicle_test_json.log"
  let cfg := Config.default tempPath |>.withFormat .json
  let logger ← Logger.create cfg
  logger.info "json test"
  logger.close

  let content ← IO.FS.readFile tempPath
  shouldSatisfy (content.containsSubstr "{") "should contain {"
  shouldSatisfy (content.containsSubstr "\"level\":\"INFO\"") "should have level field"

  IO.FS.removeFile tempPath

test "withLogger properly closes handle" := do
  let tempPath : System.FilePath := "/tmp/chronicle_test_with.log"
  let cfg := Config.default tempPath

  Logger.withLogger cfg fun logger => do
    logger.info "inside withLogger"

  -- File should exist and have content
  let content ← IO.FS.readFile tempPath
  shouldSatisfy (content.containsSubstr "inside withLogger") "should have logged content"

  IO.FS.removeFile tempPath

test "creates parent directories" := do
  let tempPath : System.FilePath := "/tmp/chronicle_test_nested/subdir/app.log"
  let cfg := Config.default tempPath
  let logger ← Logger.create cfg
  logger.info "nested test"
  logger.close

  let content ← IO.FS.readFile tempPath
  shouldSatisfy (content.containsSubstr "nested test") "should have logged content"

  -- Cleanup
  IO.FS.removeFile tempPath
  IO.FS.removeDirAll "/tmp/chronicle_test_nested"



end Tests.Logger

-- Main entry point
open Crucible

def main : IO UInt32 := do
  IO.println "Chronicle Logging Library Tests"
  IO.println "================================"
  IO.println ""

  let result ← runAllSuites

  IO.println ""
  if result != 0 then
    IO.println "Some tests failed!"
    return 1
  else
    IO.println "All tests passed!"
    return 0
