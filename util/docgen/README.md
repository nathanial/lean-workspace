# Docgen

A documentation generator for Lean 4 projects. Extracts documentation from compiled Lean projects and generates a static HTML documentation site.

## Features

- Extracts module-level (`/-! ... -/`) and declaration-level (`/-- ... -/`) doc comments
- Generates browsable HTML documentation with navigation sidebar
- Produces search index for client-side search
- Configurable source links to GitHub/GitLab
- Dark mode support
- Clean, responsive design

## Installation

Add to your `lakefile.lean`:

```lean
require docgen from git "https://github.com/nathanial/docgen" @ "v0.0.1"
```

Or build from source:

```bash
git clone https://github.com/nathanial/docgen
cd docgen
lake build docgen:exe
```

## Usage

```bash
# Generate docs for current project
docgen build

# Specify output directory
docgen build --output ./site

# Set project title
docgen build --title "My Library"

# Include private declarations
docgen build --include-private

# Include internal/auxiliary definitions
docgen build --include-internal

# Add source links
docgen build --source-url "https://github.com/user/repo" --source-branch main

# Show help
docgen --help
```

## Output

Docgen generates a static HTML site:

```
docs/
├── index.html              # Project overview with module list
├── search-index.json       # Search data for client-side search
├── search.js               # Search JavaScript
├── style.css               # Documentation CSS
└── Module/
    └── Submodule.html      # Per-module documentation pages
```

## Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `--output`, `-o` | Output directory | `./docs` |
| `--title` | Project title | Detected from lakefile |
| `--include-private` | Include private declarations | `false` |
| `--include-internal` | Include internal/auxiliary definitions | `false` |
| `--source-url` | Repository URL for source links | None |
| `--source-branch` | Branch/tag for source links | `main` |

## Dependencies

- [parlance](https://github.com/nathanial/parlance) - CLI argument parsing
- [scribe](https://github.com/nathanial/scribe) - HTML generation
- [staple](https://github.com/nathanial/staple) - Compile-time file embedding

## Development

```bash
# Build library
lake build

# Build executable
lake build docgen:exe

# Run tests
lake test
```

## License

MIT License - see [LICENSE](LICENSE) for details.
