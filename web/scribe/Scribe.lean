/-
  Scribe - Monadic HTML Builder for Lean 4

  A type-safe, composable HTML builder using a monad for fluent construction.

  Example:
  ```lean
  import Scribe
  open Scribe

  def page : HtmlM Unit := do
    html do
      body do
        h1 (text "Welcome")
        p (text "This is Scribe.")
        form [] do
          input [type_ "text", name_ "email"]
  ```
-/

import Scribe.Html
import Scribe.Attr
import Scribe.AttrValues
import Scribe.Builder
import Scribe.Elements
import Scribe.RouteAttrs
import Scribe.Svg

-- Component system
import Scribe.Component
import Scribe.Components.Card
import Scribe.Components.Modal
import Scribe.Components.Panel
import Scribe.Components.Form
import Scribe.Components.Navigation
import Scribe.Components.Alert
