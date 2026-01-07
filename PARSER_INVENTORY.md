# Parser Implementations Inventory

This document catalogs all custom parser implementations in the lean-workspace.

**Total Projects with Parsers:** 15
**Total Parser Files:** 64+

## Summary by Category

| Category | Projects | What They Parse |
|----------|----------|-----------------|
| Util | sift | Parser combinator library (foundation) |
| Web | herald, markup, stencil | HTTP, HTML, templates |
| Data | chisel, totem, tabular, staple | SQL, TOML, CSV/TSV, JSON |
| Network | protolean | Protocol Buffers (.proto) |
| Graphics | tincture, vane | Colors, ANSI escape sequences |
| Util | rune, smalltalk, parlance | Regex, Smalltalk language, CLI args |
| Apps | tracker | YAML frontmatter |

---

## Parser Combinator Library

### sift (Parser Combinator Library)
- **Location:** `util/sift/`
- **Purpose:** Monadic parser combinator library providing foundation for other parsers
- **Approach:** Parsec-style combinators with position tracking
- **Main Files:**
  - `Sift/Core.lean` - Parser monad, ParseState, ParseError
  - `Sift/Primitives.lean` - satisfy, char, string, anyChar, peek, peekString, atEnd
  - `Sift/Combinators.lean` - many, sepBy, between, choice, chainl1, manyTill
  - `Sift/Char.lean` - Character classes (digit, letter, hspace, hexDigit, etc.)
  - `Sift/Text.lean` - Text utilities (natural, integer, float, identifier, digitsWithUnderscores)
- **Features:** Position tracking (line/column), descriptive error messages, backtracking with `attempt`, lookahead, unicode escape parsing
- **Used By:** totem

---

## Web Category

### herald (HTTP Parser)
- **Location:** `web/herald/`
- **Parses:** HTTP requests and responses (RFC 7230 compliant)
- **Approach:** Byte-level streaming decoder with low-level primitives
- **Main Files:**
  - `Herald/Parser/Decoder.lean` - Core byte decoder
  - `Herald/Parser/Primitives.lean` - CRLF, tokens, whitespace, hex
  - `Herald/Parser/RequestLine.lean` - HTTP request line
  - `Herald/Parser/StatusLine.lean` - HTTP response line
  - `Herald/Parser/Headers.lean` - HTTP headers
  - `Herald/Parser/Body.lean` - Request/response body
  - `Herald/Parser/Chunked.lean` - Chunked transfer encoding
  - `Herald/Parser/Message.lean` - Complete message assembly

### markup (HTML Parser)
- **Location:** `web/markup/`
- **Parses:** HTML documents
- **Approach:** Hand-written recursive descent with position tracking
- **Main Files:**
  - `Markup/Parser/Document.lean` - Top-level document parsing
  - `Markup/Parser/Elements.lean` - HTML tags, void elements
  - `Markup/Parser/Attributes.lean` - HTML attributes
  - `Markup/Parser/Entities.lean` - HTML entities
  - `Markup/Parser/Primitives.lean` - Low-level primitives
  - `Markup/Parser/State.lean` - Parser state
- **Features:** Void elements, raw text elements, comments, doctypes, self-closing tags

### stencil (Template Engine Parser)
- **Location:** `web/stencil/`
- **Parses:** Jinja2-style template syntax
- **Approach:** Position-tracking state machine parser
- **Main Files:**
  - `Stencil/Parser/Parse.lean` - Template parsing
  - `Stencil/Parser/Primitives.lean` - Filters, variables
  - `Stencil/Parser/State.lean` - Parser state with position/trim tracking
- **Features:** Variable references, filters, for/if/block tags, comments, trim markers

---

## Network Category

### protolean (Protocol Buffers Parser)
- **Location:** `network/protolean/`
- **Parses:** Protocol Buffer 3 definition files (.proto)
- **Approach:** Lexer + parser using `Std.Internal.Parsec` combinators
- **Main Files:**
  - `Protolean/Parser/Lexer.lean` - Tokenization (comments, identifiers, literals)
  - `Protolean/Parser/Proto.lean` - Proto3 grammar parsing
- **Features:** Scalar types, map types, field types, messages, services, options

---

## Data Category

### chisel (SQL Parser)
- **Location:** `data/chisel/`
- **Parses:** SQL (SELECT, INSERT, UPDATE, DELETE, DDL, CREATE INDEX)
- **Approach:** Hand-written recursive descent with operator precedence (7 levels)
- **Main Files:**
  - `Chisel/Parser/Core.lean` - Core parser combinators
  - `Chisel/Parser/Lexer.lean` - SQL keywords, tokenization
  - `Chisel/Parser/DML.lean` - INSERT, UPDATE, DELETE
  - `Chisel/Parser/DDL.lean` - CREATE TABLE, ALTER TABLE
  - `Chisel/Parser/Select.lean` - SELECT statements
  - `Chisel/Parser/Expr.lean` - Expressions with precedence
  - `Chisel/Parser/Param.lean` - Parameter placeholders
- **Features:** Subqueries, joins, aggregates, CASE expressions, CAST

### totem (TOML Parser)
- **Location:** `data/totem/`
- **Parses:** TOML configuration files (TOML 1.0 compliant)
- **Approach:** Built on Sift parser combinator library
- **Main Files:**
  - `Totem/Parser/Primitives.lean` - TOML-specific helpers wrapping Sift
  - `Totem/Parser/String.lean` - String literals (basic, literal, multi-line)
  - `Totem/Parser/Number.lean` - Numbers, floats, hex, octal, binary
  - `Totem/Parser/Key.lean` - Keys including dotted keys
  - `Totem/Parser/DateTime.lean` - Datetime, date, time (RFC 3339)
  - `Totem/Parser/Value.lean` - All value types with mutual recursion
  - `Totem/Parser/Document.lean` - Full document with table conflict detection
- **Features:** All TOML value types, inline tables, array of tables, homogeneous array validation, position-aware errors via Sift.ParseError

### tabular (CSV/TSV Parser)
- **Location:** `data/tabular/`
- **Parses:** CSV and TSV delimited data
- **Approach:** State machine-based character-level parser
- **Main Files:**
  - `Tabular/Parser/State.lean` - Parser state
  - `Tabular/Parser/Primitives.lean` - Character classification
  - `Tabular/Parser/Field.lean` - Field parsing with escaping
  - `Tabular/Parser/Record.lean` - Row parsing
  - `Tabular/Parser/Document.lean` - Full table with headers
- **Features:** Configurable delimiter/quoting/escaping, ragged row support

### staple (JSON Parser)
- **Location:** `util/staple/`
- **Parses:** JSON data (RFC 8259 compliant)
- **Approach:** Recursive descent parser with state tracking
- **Main Files:** `Staple/Json/Parse.lean`
- **Features:** Strings with escapes, numbers, arrays, objects

---

## Graphics Category

### tincture (Color Parser)
- **Location:** `graphics/tincture/`
- **Parses:** Color format strings
- **Approach:** Format-specific pattern matching
- **Main Files:** `Tincture/Parse.lean`
- **Features:** Hex colors (#RGB, #RGBA, #RRGGBB, #RRGGBBAA), rgb/rgba functions, named colors

### vane (Terminal Emulator Parser)
- **Location:** `graphics/vane/`
- **Parses:** ANSI escape sequences (VT500-style terminal control)
- **Approach:** Finite state machine (ISO/IEC 6429 compliant, 11 states)
- **Main Files:**
  - `Vane/Parser/State.lean` - Parser state
  - `Vane/Parser/Machine.lean` - Main state machine
  - `Vane/Parser/CSI.lean` - Control Sequence Introducer
  - `Vane/Parser/SGR.lean` - Select Graphic Rendition (colors)
  - `Vane/Parser/OSC.lean` - Operating System Command
  - `Vane/Parser/Types.lean` - AST types
- **Features:** VT500 terminal emulation with proper state transitions

---

## Utility Category

### rune (Regex Parser)
- **Location:** `util/rune/`
- **Parses:** POSIX Extended Regular Expressions (ERE)
- **Approach:** Recursive descent with capture group management
- **Main Files:**
  - `Rune/Parser/Parser.lean` - Main regex parser
  - `Rune/AST/Types.lean` - Regex AST
- **Features:** Named captures, character classes, alternation, quantifiers, anchors

### smalltalk (Smalltalk Interpreter)
- **Location:** `util/smalltalk/`
- **Parses:** Smalltalk language source code
- **Approach:** Combinator-based parser using `Std.Internal.Parsec`
- **Main Files:**
  - `Smalltalk/Parse.lean` - Full grammar with mutual recursion
  - `Smalltalk/AST.lean` - Smalltalk AST definitions
- **Features:** Messages, methods, blocks, pragmas, class definitions, literals

### parlance (CLI Argument Parser)
- **Location:** `util/parlance/`
- **Parses:** Command-line arguments and options
- **Approach:** Token-based finite state machine
- **Main Files:**
  - `Parlance/Parse/Parser.lean` - Main argument parser
  - `Parlance/Parse/Tokenizer.lean` - Argument tokenization
  - `Parlance/Parse/Extractor.lean` - Value extraction
- **Features:** Flags, short/long options, subcommands, positional args, repeatable options

---

## Application Category

### tracker (Issue Frontmatter Parser)
- **Location:** `apps/tracker/`
- **Parses:** YAML frontmatter + Markdown body in issue files
- **Approach:** String manipulation + simple YAML parsing
- **Main Files:** `Tracker/Core/Parser.lean`
- **Features:** YAML-style key-value pairs, arrays, issue metadata extraction

---

## Parser Technology Patterns

| Pattern | Used By |
|---------|---------|
| Sift Combinator Library | totem |
| Std.Internal.Parsec Combinators | protolean, smalltalk |
| Hand-Written Recursive Descent | chisel, herald, markup, stencil, tabular |
| Finite State Machine | vane, rune, parlance |
| Custom Monadic Parser (ExceptT/StateM) | Most hand-written parsers |
| Byte-Level Streaming | herald |
| Position Tracking (for errors) | sift, markup, stencil, tracker |

---

*Updated: 2026-01-06*
