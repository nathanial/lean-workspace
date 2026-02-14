/-
  Canopy Spinner Widget - Reactive Component
-/
import Reactive
import Afferent.UI.Canopy.Core
import Afferent.UI.Canopy.Theme
import Afferent.UI.Canopy.Reactive.Component
import AfferentSpinners.Canopy.Widget.Display.Spinner.Core
import AfferentSpinners.Canopy.Widget.Display.Spinner.CircleDots
import AfferentSpinners.Canopy.Widget.Display.Spinner.Ring
import AfferentSpinners.Canopy.Widget.Display.Spinner.BouncingDots
import AfferentSpinners.Canopy.Widget.Display.Spinner.Bars
import AfferentSpinners.Canopy.Widget.Display.Spinner.DualRing
import AfferentSpinners.Canopy.Widget.Display.Spinner.Orbit
import AfferentSpinners.Canopy.Widget.Display.Spinner.Pulse
import AfferentSpinners.Canopy.Widget.Display.Spinner.Helix
import AfferentSpinners.Canopy.Widget.Display.Spinner.Wave
import AfferentSpinners.Canopy.Widget.Display.Spinner.Spiral
import AfferentSpinners.Canopy.Widget.Display.Spinner.Clock
import AfferentSpinners.Canopy.Widget.Display.Spinner.Pendulum
import AfferentSpinners.Canopy.Widget.Display.Spinner.Ripple
import AfferentSpinners.Canopy.Widget.Display.Spinner.Heartbeat
import AfferentSpinners.Canopy.Widget.Display.Spinner.Gears

namespace AfferentSpinners.Canopy

open Afferent.Canopy
open Afferent.Arbor hiding Event
open Afferent

namespace Spinner

/-- Get the appropriate spec for a spinner variant. -/
def variantSpec (variant : SpinnerVariant) (t : Float) (color : Color)
    (dims : Dimensions) : CustomSpec :=
  match variant with
  | .circleDots => circleDotsSpec t color dims
  | .ring => ringSpec t color dims
  | .bouncingDots => bouncingDotsSpec t color dims
  | .bars => barsSpec t color dims
  | .dualRing => dualRingSpec t color dims
  | .orbit => orbitSpec t color dims
  | .pulse => pulseSpec t color dims
  | .helix => helixSpec t color dims
  | .wave => waveSpec t color dims
  | .spiral => spiralSpec t color dims
  | .clock => clockSpec t color dims
  | .pendulum => pendulumSpec t color dims
  | .ripple => rippleSpec t color dims
  | .heartbeat => heartbeatSpec t color dims
  | .gears => gearsSpec t color dims

end Spinner

/-- Build a spinner (WidgetBuilder version).
    - `name`: Widget name for identification
    - `t`: Animation progress (0.0 to 1.0)
    - `config`: Spinner configuration
    - `theme`: Theme for styling
-/
def spinnerVisual (name : ComponentId) (t : Float) (config : Spinner.Config)
    (theme : Theme) : WidgetBuilder := do
  let color := Spinner.getColor config theme
  let baseSpec := Spinner.variantSpec config.variant t color config.dims
  let spec := { baseSpec with skipCache := true }

  let wid ← freshId
  let props : Trellis.FlexContainer := { Trellis.FlexContainer.column 0 with alignItems := .center }

  let spinnerWidget ← custom spec {
    minWidth := some config.dims.size
    minHeight := some config.dims.size
  }

  pure (Widget.flexC wid name props {} #[spinnerWidget])

/-! ## Reactive Spinner Component (FRP-based) -/

open Reactive Reactive.Host
open Afferent.Canopy.Reactive

/-- Float modulo for animation cycling. -/
private def floatMod (x y : Float) : Float :=
  x - y * (x / y).floor

/-- Create a spinner component using WidgetM.
    Emits an animated spinner that cycles continuously.
    - `config`: Spinner configuration (variant, color, speed, dimensions)
-/
def spinner (config : Spinner.Config := {}) : WidgetM Unit := do
  let theme ← getThemeW
  let name ← registerComponentW (isInteractive := false)

  -- Generate a random time offset so multiple spinners don't animate in sync
  let cycleDuration : Float := 2.0 / config.speed
  let randomSeed ← (IO.rand 0 10000 : IO Nat)
  let timeOffset : Float := randomSeed.toFloat / 10000.0 * cycleDuration

  -- Use shared elapsed time (all widgets share ONE Dynamic, no per-widget foldDyn)
  let elapsedTime ← useElapsedTime

  -- Variants using sin/cos need raw time for seamless animation (they handle any angle).
  -- Other variants use wrapped progress [0,1) for their animation cycles.
  let useRawTime := match config.variant with
    | .ring | .dualRing => true          -- Arc rendering with angles
    | .helix | .wave | .circleDots       -- Shader DSL with sin/cos
    | .pendulum | .orbit | .bouncingDots
    | .ripple | .pulse | .bars => true
    | _ => false
  let _ ← dynWidget elapsedTime fun t => do
    let offsetT := t + timeOffset
    let animTime := if useRawTime then offsetT * config.speed else floatMod offsetT cycleDuration / cycleDuration
    emitM do pure (spinnerVisual name animTime config theme)

/-- Convenience function: Create a default ring spinner. -/
def spinnerRing (color : Option Color := none) (size : Float := 40.0) : WidgetM Unit :=
  spinner { variant := .ring, color, dims := { size } }

/-- Convenience function: Create a circle dots spinner. -/
def spinnerCircleDots (color : Option Color := none) (size : Float := 40.0) : WidgetM Unit :=
  spinner { variant := .circleDots, color, dims := { size } }

/-- Convenience function: Create a bouncing dots spinner. -/
def spinnerBouncingDots (color : Option Color := none) (size : Float := 40.0) : WidgetM Unit :=
  spinner { variant := .bouncingDots, color, dims := { size } }

end AfferentSpinners.Canopy
