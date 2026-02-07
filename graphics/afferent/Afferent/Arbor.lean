/-
  Arbor - Afferent Widget Core

  Arbor provides the declarative widget model, layout/measurement pipeline,
  event system, and render-command IR used by Afferent.

  In this repository, production rendering executes through Afferent's
  Canvas/Metal backend in `Afferent.Widget.Backend`.

  Key abstractions:
  - RenderCommand: backend-agnostic drawing operations
  - TextMeasurer: text measurement interface (implemented by Afferent fonts)
  - Widget: declarative widget tree (flex, grid, text, scroll, etc.)

  Usage:
  1. Build a widget tree using the DSL (row, column, text', box, etc.)
  2. Measure the tree with `measureWidget`
  3. Compute layout with `Trellis.layout`
  4. Collect render commands with `collectCommands`
  5. Execute commands with the Afferent widget backend
-/

-- Core types
import Afferent.Arbor.Core.Types
import Afferent.Arbor.Core.TextMeasurer

-- Render commands
import Afferent.Arbor.Render.Command
import Afferent.Arbor.Render.Builder
import Afferent.Arbor.Render.Collect

-- Widget system
import Afferent.Arbor.Widget.Core
import Afferent.Arbor.Widget.DSL
import Afferent.Arbor.Widget.TextLayout
import Afferent.Arbor.Widget.Measure
import Afferent.Arbor.Widget.MeasureCache

-- Event system
import Afferent.Arbor.Event.Types
import Afferent.Arbor.Event.HitTest
import Afferent.Arbor.Event.Scroll
import Afferent.Arbor.App.UI

-- CSS-like styling DSL
import Afferent.Arbor.Style.CSS
