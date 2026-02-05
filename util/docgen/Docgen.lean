import Docgen.Core.Types
import Docgen.Core.Config
import Docgen.Extract.Environment
import Docgen.Extract.DocStrings
import Docgen.Extract.Signatures
import Docgen.Extract.Module
import Docgen.Render.Html
import Docgen.Render.Navigation
import Docgen.Render.Search
import Docgen.Generate.Assets
import Docgen.Generate.Site
import Docgen.CLI

/-!
# Docgen - Documentation Generator for Lean 4

A standalone CLI tool that extracts documentation from compiled Lean 4 projects
and generates a static HTML documentation site.

## Quick Start

```bash
# Generate docs for current project
docgen build

# With options
docgen build --output ./site --title "My Library"

# Include private declarations
docgen build --include-private
```

## Features

- Extracts doc comments (`/-! ... -/` and `/-- ... -/`)
- Generates navigable HTML with sidebar and search
- Pretty-prints type signatures
- Supports source links to GitHub/GitLab
-/
