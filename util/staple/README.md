# Staple

Essential Lean 4 utilities and macros.

## Features

### `include_str%` - Compile-time File Embedding

Embed file contents as string literals at compile time:

```lean
import Staple

-- Read a file relative to the current source file
def myTemplate : String := include_str% "templates/page.html"

-- Read a config file
def configJson : String := include_str% "../config.json"
```

The file path is resolved relative to the source file containing the `include_str%` call.

## Requirements

- Lean 4.26.0

## Building

```bash
lake build
```

## Usage

Add to your `lakefile.lean`:

```lean
require staple from git "https://github.com/nathanial/staple" @ "v0.0.1"
```

Then import in your Lean files:

```lean
import Staple
```

## License

MIT License - see [LICENSE](LICENSE)
