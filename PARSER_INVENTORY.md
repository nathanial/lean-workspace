# Parser Implementations Inventory

This document catalogs all custom parser implementations in the lean-workspace.

**Total Projects with Parsers:** 15
**Total Parser Files:** 60+

## Summary by Category

| Category | Projects | What They Parse |
|----------|----------|-----------------|
| Util | sift | Parser combinator library (foundation) |
| Web | herald, markup, stencil | HTTP, HTML, templates |
| Data | chisel, totem, tabular, staple | SQL, TOML, CSV/TSV, JSON |
| Network | protolean | Protocol Buffers (.proto) |
| Graphics | tincture, vane | Colors, ANSI escape sequences |
| Util | rune, smalltalk, parlance | Regex, Smalltalk language, CLI args |
| Apps | tracker | YAML frontmatter (Sift) |

---

## Parser Combinator Library

### sift (Parser Combinator Library)
- **Location:** `util/sift/`
- **Purpose:** Monadic parser combinator library providing foundation for other parsers
- **Approach:** Parsec-style combinators with position tracking
- **Main Files:**
  - `Sift/Core.lean` - Parser monad, ParseState, ParseError
  - `Sift/Primitives.lean` - satisfy, char, string, stringCI, anyChar, peek, peekString, atEnd
  - `Sift/Combinators.lean` - many, sepBy, between, choice, chainl1, manyTill
  - `Sift/Char.lean` - Character classes (digit, letter, hspace, hexDigit, etc.)
  - `Sift/Text.lean` - Text utilities (natural, integer, float, identifier, digitsWithUnderscores)
  - `Sift/Prec.lean` - Precedence climbing combinator for expression parsing
- **Features:** Position tracking (line/column), descriptive error messages, backtracking with `attempt`, lookahead, unicode escape parsing, precedence climbing
- **Used By:** totem, tabular, staple, protolean, smalltalk, stencil, chisel, markup, tracker

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
- **Approach:** Built on Sift parser combinator library with tag stack state
- **Main Files:**
  - `Markup/Parser/Entities.lean` - Parser type, helpers, HTML entity decoding
  - `Markup/Parser/Attributes.lean` - HTML attribute parsing
  - `Markup/Parser/Elements.lean` - HTML tags, void elements, raw text elements
  - `Markup/Parser/Document.lean` - Top-level document parsing with mutual recursion
- **Features:** Void elements, raw text elements, comments, doctypes, self-closing tags, position-aware errors via Sift.ParseError

### stencil (Template Engine Parser)
- **Location:** `web/stencil/`
- **Parses:** Jinja2-style template syntax
- **Approach:** Built on Sift parser combinator library with user state
- **Main Files:**
  - `Stencil/Parser/Parse.lean` - Template parsing using Sift combinators
  - `Stencil/Parser/Primitives.lean` - Stencil-specific helpers wrapping Sift
  - `Stencil/Parser/State.lean` - StencilState (tagStack, trimNextLeading) as Sift user state
- **Features:** Variable references, filters, for/if/block tags, comments, trim markers, position-aware errors via Sift.ParseError

---

## Network Category

### protolean (Protocol Buffers Parser)
- **Location:** `network/protolean/`
- **Parses:** Protocol Buffer 3 definition files (.proto)
- **Approach:** Built on Sift parser combinator library
- **Main Files:**
  - `Protolean/Parser/Lexer.lean` - Tokenization (comments, identifiers, literals)
  - `Protolean/Parser/Proto.lean` - Proto3 grammar parsing
- **Features:** Scalar types, map types, field types, messages, services, options, position-aware errors

---

## Data Category

### chisel (SQL Parser)
- **Location:** `data/chisel/`
- **Parses:** SQL (SELECT, INSERT, UPDATE, DELETE, DDL, CREATE INDEX)
- **Approach:** Built on Sift parser combinator library
- **Main Files:**
  - `Chisel/Parser.lean` - All statement parsers (SELECT, DML, DDL) with precedence climbing
  - `Chisel/Parser/Lexer.lean` - SQL keywords, tokenization using Sift primitives
  - `Chisel/Parser/Param.lean` - Parameter placeholders and binding
- **Features:** Subqueries, joins, aggregates, CASE expressions, CAST, 7-level operator precedence, position-aware errors via Sift.ParseError

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
- **Parses:** CSV and TSV delimited data (RFC 4180 compliant)
- **Approach:** Built on Sift parser combinator library
- **Main Files:**
  - `Tabular/Parser/Field.lean` - Field parsing with quote handling
  - `Tabular/Parser/Record.lean` - Row parsing
  - `Tabular/Parser/Document.lean` - Full table with headers
- **Features:** Configurable delimiter/quoting/escaping, ragged row support, embedded newlines in quoted fields

### staple (JSON Parser)
- **Location:** `util/staple/`
- **Parses:** JSON data (RFC 8259 compliant)
- **Approach:** Built on Sift parser combinator library
- **Main Files:** `Staple/Json/Parse.lean`
- **Features:** Strings with escapes (including \uXXXX unicode), numbers (int/float), arrays, objects, line/column error positions

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
- **Approach:** Built on Sift parser combinator library
- **Main Files:**
  - `Smalltalk/Parse.lean` - Full grammar with mutual recursion
  - `Smalltalk/AST.lean` - Smalltalk AST definitions
- **Features:** Messages, methods, blocks, pragmas, class definitions, literals, position-aware errors

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
- **Approach:** Built on Sift parser combinator library
- **Main Files:** `Tracker/Core/Parser.lean`
- **Features:** YAML-style key-value pairs, arrays (strings and numbers), progress entries with timestamps, position-aware errors via Sift.ParseError

---

## Parser Technology Patterns

| Pattern | Used By |
|---------|---------|
| Sift Combinator Library | totem, tabular, staple, protolean, smalltalk, stencil, chisel, markup, tracker |
| Hand-Written Recursive Descent | herald |
| Finite State Machine | vane, rune, parlance |
| Custom Monadic Parser (ExceptT/StateM) | Most hand-written parsers |
| Byte-Level Streaming | herald |
| Position Tracking (for errors) | sift, totem, tabular, staple, protolean, smalltalk, markup, stencil, tracker, chisel |

---

*Updated: 2026-01-07*
