# Scribe

A type-safe, monadic HTML builder for Lean 4.

## Features

- **Monadic Builder**: Use do-notation for fluent HTML construction
- **Type-Safe**: Full compile-time checking of element structure
- **Control Flow**: Natural use of `if`, `for`, and `match` in templates
- **HTML Escaping**: Automatic escaping of text and attribute values
- **Comprehensive**: 60+ HTML elements, 50+ attribute helpers

## Installation

Add to your `lakefile.lean`:

```lean
require scribe from git "https://github.com/nathanial/scribe" @ "v0.0.1"
```

## Usage

```lean
import Scribe
open Scribe

def page (title : String) (items : List String) : String := HtmlM.render do
  html [] do
    head [] do
      Scribe.title title
      meta_ [charset_ "UTF-8"]
    body [] do
      div [class_ "container"] do
        h1 (text title)
        p (text "Welcome to Scribe!")
        ul [] do
          for item in items do
            li [] (text item)

#eval page "Hello" ["one", "two", "three"]
-- <html><head><title>Hello</title><meta charset="UTF-8"></head><body>...
```

## API Overview

### Builder Monad

```lean
-- Build HTML and render to string
HtmlM.render : HtmlM Unit → String

-- Build HTML and get Html value
HtmlM.build : HtmlM Unit → Html

-- Emit text (escaped)
text : String → HtmlM Unit

-- Emit raw HTML (not escaped)
raw : String → HtmlM Unit
```

### Elements

All standard HTML elements are available:

```lean
-- Document structure
html, head, body, title, meta_, link, script, style

-- Semantic sections
header, footer, main, nav, aside, section_, article

-- Block elements
div, p, h1-h6, ul, ol, li, table, tr, td, th, pre, blockquote

-- Inline elements
span, a, strong, em, code, br, img

-- Forms
form, input, textarea, button, select, option, label
```

### Attributes

```lean
-- Common attributes
class_ "container"
id_ "main"
href_ "/path"
src_ "image.png"

-- Form attributes
type_ "text"
name_ "username"
value_ "default"
placeholder_ "Enter text"
required_
disabled_

-- Data attributes
data_ "id" "123"  -- data-id="123"

-- Generic
attr_ "custom" "value"
```

## Examples

### Conditional Content

```lean
def greeting (loggedIn : Bool) (name : String) : String := HtmlM.render do
  div [] do
    if loggedIn then
      p (text s!"Welcome back, {name}!")
    else
      a [href_ "/login"] (text "Please log in")
```

### Lists from Data

```lean
def userList (users : List User) : String := HtmlM.render do
  table [] do
    thead [] do
      tr [] do
        th [] (text "Name")
        th [] (text "Email")
    tbody [] do
      for user in users do
        tr [] do
          td [] (text user.name)
          td [] (text user.email)
```

### Form Building

```lean
def loginForm : String := HtmlM.render do
  form [action_ "/login", method_ "POST"] do
    div [class_ "form-group"] do
      label [for_ "email"] (text "Email")
      input [type_ "email", name_ "email", id_ "email", required_]
    div [class_ "form-group"] do
      label [for_ "password"] (text "Password")
      input [type_ "password", name_ "password", id_ "password", required_]
    button [type_ "submit", class_ "btn"] (text "Log In")
```

## Build

```bash
lake build        # Build library
lake test         # Run tests (30 tests)
```

## License

MIT
