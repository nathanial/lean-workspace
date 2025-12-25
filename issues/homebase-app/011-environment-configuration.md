# Environment-Based Configuration

## Summary

Currently, configuration values like secret keys and database paths are hardcoded. Implement environment-based configuration for different deployment environments.

## Current State

In `HomebaseApp/Main.lean`:

```lean
let config : Loom.AppConfig := {
  port := 3000
  sessionSecret := "super-secret-key-change-in-production"
  dbPath := "data/homebase.jsonl"
}
```

## Problems

1. **Secret key hardcoded**: Same key in dev and production
2. **No env separation**: Can't have different configs for dev/staging/prod
3. **Secrets in source**: Should not be in version control
4. **Port hardcoded**: May conflict with other services

## Requirements

### Environment Variables

Support these environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | 3000 | HTTP server port |
| `SESSION_SECRET` | (none) | Session signing key (required in prod) |
| `DATABASE_PATH` | data/homebase.jsonl | Ledger database file |
| `LOG_LEVEL` | info | Logging level (trace/debug/info/warn/error) |
| `LOG_FORMAT` | text | Log format (text/json) |
| `LOG_PATH` | logs/homebase.log | Log file path |
| `ENVIRONMENT` | development | Environment name |

### Configuration Module

Create `HomebaseApp/Config.lean`:

```lean
structure AppConfig where
  port : UInt16
  sessionSecret : String
  dbPath : String
  logLevel : Chronicle.Level
  logFormat : Chronicle.Format
  logPath : String
  environment : String
  deriving Repr

def loadConfig : IO AppConfig := do
  let env := (← IO.getEnv "ENVIRONMENT").getD "development"

  -- In production, require SESSION_SECRET
  let secret ← match ← IO.getEnv "SESSION_SECRET" with
    | some s => pure s
    | none =>
      if env == "production" then
        throw (IO.Error.userError "SESSION_SECRET required in production")
      else
        pure "dev-secret-not-for-production"

  let port := (← IO.getEnv "PORT").bind String.toNat? |>.getD 3000
  let dbPath := (← IO.getEnv "DATABASE_PATH").getD "data/homebase.jsonl"
  let logLevel := parseLogLevel ((← IO.getEnv "LOG_LEVEL").getD "info")
  let logFormat := parseLogFormat ((← IO.getEnv "LOG_FORMAT").getD "text")
  let logPath := (← IO.getEnv "LOG_PATH").getD "logs/homebase.log"

  return {
    port := port.toUInt16
    sessionSecret := secret
    dbPath
    logLevel
    logFormat
    logPath
    environment := env
  }

def parseLogLevel (s : String) : Chronicle.Level :=
  match s.toLower with
  | "trace" => .trace
  | "debug" => .debug
  | "info" => .info
  | "warn" => .warn
  | "error" => .error
  | _ => .info

def parseLogFormat (s : String) : Chronicle.Format :=
  match s.toLower with
  | "json" => .json
  | _ => .text
```

### Usage in Main

```lean
def main : IO Unit := do
  let config ← loadConfig

  IO.println s!"Starting homebase-app in {config.environment} mode"
  IO.println s!"  Port: {config.port}"
  IO.println s!"  Database: {config.dbPath}"
  IO.println s!"  Log level: {config.logLevel}"

  let appConfig : Loom.AppConfig := {
    port := config.port
    sessionSecret := config.sessionSecret
    dbPath := config.dbPath
  }

  -- Continue with app setup...
```

### .env File Support (Optional)

Create `HomebaseApp/DotEnv.lean`:

```lean
def loadDotEnv (path : String := ".env") : IO Unit := do
  if ← System.FilePath.pathExists path then
    let contents ← IO.FS.readFile path
    for line in contents.splitOn "\n" do
      if let some (key, value) := parseDotEnvLine line then
        IO.setEnv key value

def parseDotEnvLine (line : String) : Option (String × String) :=
  let line := line.trim
  if line.isEmpty || line.startsWith "#" then none
  else
    match line.splitOn "=" with
    | [key, value] => some (key.trim, value.trim.trimChar '"')
    | _ => none
```

### Example .env Files

`.env.development`:
```bash
PORT=3000
DATABASE_PATH=data/homebase-dev.jsonl
LOG_LEVEL=debug
LOG_FORMAT=text
ENVIRONMENT=development
```

`.env.production`:
```bash
PORT=8080
DATABASE_PATH=/var/lib/homebase/data.jsonl
LOG_LEVEL=info
LOG_FORMAT=json
LOG_PATH=/var/log/homebase/app.log
ENVIRONMENT=production
# SESSION_SECRET set via deployment secrets
```

### .gitignore Update

```
.env
.env.local
.env.production
```

## Acceptance Criteria

- [ ] All config values read from environment
- [ ] Sensible defaults for development
- [ ] Required values enforced in production
- [ ] .env file support for local development
- [ ] Config logged on startup (without secrets)
- [ ] Documentation for all config options

## Technical Notes

- `IO.getEnv` is the Lean 4 way to read env vars
- Consider TOML/YAML config file as alternative
- Secrets should come from environment, not files
- Docker/K8s can inject env vars at runtime

## Priority

Medium - Important for deployment but not blocking

## Estimate

Small - Straightforward implementation
