# Docgen

Documentation generator for Lean 4 projects. Extracts documentation from compiled Lean projects and generates a static HTML documentation site.

## Overview

Docgen parses Lean 4 doc comments (`/-! ... -/` for modules, `/-- ... -/` for declarations) and produces a browsable HTML documentation site with:
- Module hierarchy with navigation sidebar
- Declaration pages with type signatures and doc comments
- Search functionality
- Source links (configurable)

## Build Commands

```bash
lake build              # Build the library
lake build docgen:exe   # Build the CLI executable
lake test               # Run tests
.lake/build/bin/docgen --help  # Show CLI help
```

## CLI Usage

```bash
# Generate docs for current project
docgen build

# With options
docgen build --output ./site --title "My Library"

# Include private/internal declarations
docgen build --include-private --include-internal

# With source links
docgen build --source-url "https://github.com/user/repo" --source-branch main
```

## Project Structure

```
Docgen/
├── Core/
│   ├── Types.lean       # DocItem, DocModule, DocProject, ItemKind
│   └── Config.lean      # Configuration options
├── Extract/
│   ├── Environment.lean # Load Lean environments
│   ├── DocStrings.lean  # Extract doc comments
│   ├── Signatures.lean  # Pretty-print type signatures
│   └── Module.lean      # Group items by module
├── Render/
│   ├── Html.lean        # Page templates using Scribe
│   ├── Navigation.lean  # Sidebar and breadcrumbs
│   └── Search.lean      # JSON search index
├── Generate/
│   ├── Site.lean        # Site generation orchestration
│   └── Assets.lean      # Static asset handling
└── CLI.lean             # Parlance CLI definitions
```

## Dependencies

- **parlance** - CLI argument parsing and styled output
- **scribe** - Type-safe HTML generation
- **staple** - Compile-time file embedding (`include_str%`)
- **crucible** - Test framework

## Key Types

### DocItem
Represents a single documented declaration:
```lean
structure DocItem where
  name : Lean.Name
  kind : ItemKind           -- def_, theorem_, structure_, etc.
  signature : String        -- Pretty-printed type
  docString : Option String
  sourceFile : Option String
  sourceLine : Option Nat
  visibility : Visibility
```

### DocModule
Represents a module with its declarations:
```lean
structure DocModule where
  name : Lean.Name
  moduleDoc : Option String  -- /-! ... -/
  items : Array DocItem
  submodules : Array Lean.Name
```

### Config
Configuration for documentation generation:
```lean
structure Config where
  projectRoot : String
  outputDir : String := "docs"
  title : Option String
  includePrivate : Bool := false
  includeInternal : Bool := false
  sourceUrl : Option String
  sourceBranch : String := "main"
```

## Output Structure

Generated documentation site:
```
docs/
├── index.html              # Project overview
├── search-index.json       # Search data
├── search.js               # Search JavaScript
├── style.css               # Documentation CSS
├── Module.html             # Per-module pages
└── Module/
    └── Submodule.html
```

## Testing

```bash
lake build docgen_tests && .lake/build/bin/docgen_tests
```

Tests cover:
- Core type operations (ItemKind, DocItem, DocModule)
- Configuration filtering
- Search index generation
