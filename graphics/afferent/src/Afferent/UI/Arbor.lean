/-
  Arbor - Afferent Widget Core

  Arbor provides the declarative widget model, layout/measurement pipeline,
  event system, and drawing DSL used by Afferent.

  In this repository, production rendering executes through Afferent's
  Canvas/Metal backend in `Afferent.Widget`.

  Key abstractions:
  - RenderM: immediate drawing operations over CanvasM with FontRegistry access
  - TextMeasurer: text measurement interface (implemented by Afferent fonts)
  - Widget: declarative widget tree (flex, grid, text, scroll, etc.)

  Usage:
  1. Build a widget tree using the DSL (row, column, text', box, etc.)
  2. Measure the tree with `measureWidget`
  3. Compute layout with `Trellis.layout`
  4. Render directly with `Afferent.Widget.renderMeasuredArborWidget`
-/

-- Core types
import Afferent.UI.Arbor.Core.Types
import Afferent.UI.Arbor.Core.TextMeasurer

-- Render commands
import Afferent.Draw.Command
import Afferent.Draw.Builder
import Afferent.Draw.Collect

-- Widget system
import Afferent.UI.Arbor.Widget.Core
import Afferent.UI.Arbor.Widget.DSL
import Afferent.UI.Arbor.Widget.TextLayout
import Afferent.UI.Arbor.Widget.Measure

-- Event system
import Afferent.UI.Arbor.Event.Types
import Afferent.UI.Arbor.Event.HitTest
import Afferent.UI.Arbor.Event.Scroll
import Afferent.UI.Arbor.App.UI

-- CSS-like styling DSL
import Afferent.UI.Arbor.Style.CSS
