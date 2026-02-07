/-
  Widget Coverage Tests
  Broad unit coverage for Canopy widget helpers that previously lacked tests.
-/
import Afferent.Tests.Framework
import Afferent.Canopy.Widget.Input.Button
import Afferent.Canopy.Widget.Input.Slider
import Afferent.Canopy.Widget.Input.Switch
import Afferent.Canopy.Widget.Input.Stepper
import Afferent.Canopy.Widget.Input.RangeSlider
import Afferent.Canopy.Widget.Input.RadioButton
import Afferent.Canopy.Widget.Input.DatePicker
import Afferent.Canopy.Widget.Input.TimePicker
import Afferent.Canopy.Widget.Navigation.Pagination
import Afferent.Canopy.Widget.Layout.SplitPane
import Afferent.Canopy.Widget.Layout.Popover
import Afferent.Canopy.Widget.Display.Avatar
import Afferent.Canopy.Widget.Display.Badge
import Trellis

namespace Afferent.Tests.WidgetCoverageTests

open Crucible
open Afferent.Tests
open Afferent.Canopy
open Trellis

testSuite "Widget Coverage Tests"

def testFont : Afferent.Arbor.FontId :=
  { Afferent.Arbor.FontId.default with id := 0, name := "test", size := 14.0 }
def testTheme : Theme := { Theme.dark with font := testFont, smallFont := testFont }

/-! ## Button -/

test "Button.borderWidth by variant" := do
  ensure (Button.borderWidth .outline == 1.0) "Outline buttons should have border width 1"
  ensure (Button.borderWidth .ghost == 0.0) "Ghost buttons should have border width 0"
  ensure (Button.borderWidth .primary == 0.0) "Primary buttons should have border width 0"

test "Button.backgroundColor state precedence" := do
  let colors := Button.variantColors testTheme .primary
  let disabled := Button.backgroundColor colors { disabled := true, pressed := true, hovered := true }
  let pressed := Button.backgroundColor colors { pressed := true, hovered := true }
  let hovered := Button.backgroundColor colors { hovered := true }
  let base := Button.backgroundColor colors {}
  ensure (disabled == colors.backgroundDisabled) "Disabled should take precedence"
  ensure (pressed == colors.backgroundPressed) "Pressed should take precedence over hover"
  ensure (hovered == colors.backgroundHover) "Hovered should use hover background"
  ensure (base == colors.background) "Default state should use base background"

/-! ## Slider / Switch / Radio -/

test "Slider.trackSpec measure uses default dimensions" := do
  let dims := Slider.defaultDimensions
  let spec := Slider.trackSpec 0.5 false false testTheme dims
  let (w, h) := spec.measure 0 0
  ensure (w == dims.trackWidth) s!"Expected width {dims.trackWidth}, got {w}"
  ensure (h == dims.thumbSize) s!"Expected height {dims.thumbSize}, got {h}"

test "Switch.trackSpec measure uses default dimensions" := do
  let dims := Switch.defaultDimensions
  let spec := Switch.trackSpec true false testTheme dims
  let (w, h) := spec.measure 0 0
  ensure (w == dims.trackWidth) s!"Expected width {dims.trackWidth}, got {w}"
  ensure (h == dims.trackHeight) s!"Expected height {dims.trackHeight}, got {h}"

test "RadioButton.circleSpec measure returns provided size" := do
  let size := 20.0
  let spec := RadioButton.circleSpec true false testTheme size
  let (w, h) := spec.measure 0 0
  ensure (w == size) s!"Expected width {size}, got {w}"
  ensure (h == size) s!"Expected height {size}, got {h}"

/-! ## Stepper / RangeSlider -/

test "Stepper.clamp respects min/max bounds" := do
  let config : StepperConfig := { min := -3, max := 7 }
  ensure (Stepper.clamp (-10) config == -3) "Value below min should clamp to min"
  ensure (Stepper.clamp 42 config == 7) "Value above max should clamp to max"
  ensure (Stepper.clamp 4 config == 4) "In-range value should pass through"

test "Stepper.valueWidth never goes negative" := do
  let normal : StepperConfig := { width := 140, buttonWidth := 32 }
  let narrow : StepperConfig := { width := 40, buttonWidth := 24 }
  ensure (Stepper.valueWidth normal == 76) "Expected value area width 76"
  ensure (Stepper.valueWidth narrow == 0) "Value width should clamp to zero"

test "RangeSlider.clampRange orders and clamps endpoints" := do
  let (l1, h1) := RangeSlider.clampRange 0.8 0.2
  ensure (l1 == 0.2 && h1 == 0.8) "Range should be ordered"
  let (l2, h2) := RangeSlider.clampRange (-1.0) 2.0
  ensure (l2 == 0.0 && h2 == 1.0) "Range should be clamped to [0,1]"

test "RangeSlider.applyDrag updates only targeted thumb" := do
  let (low1, high1) := RangeSlider.applyDrag .low 0.9 0.3 0.6
  ensure (low1 == 0.6 && high1 == 0.6) "Low thumb cannot cross high thumb"
  let (low2, high2) := RangeSlider.applyDrag .high 0.1 0.4 0.7
  ensure (low2 == 0.4 && high2 == 0.4) "High thumb cannot cross low thumb"
  let (low3, high3) := RangeSlider.applyDrag .none 0.1 0.4 0.7
  ensure (low3 == 0.4 && high3 == 0.7) "No target should leave range unchanged"

/-! ## DatePicker / TimePicker -/

test "DatePicker leap year and month length helpers" := do
  ensure (DatePicker.isLeapYear 2024) "2024 should be leap year"
  ensure (!DatePicker.isLeapYear 2100) "2100 should not be leap year"
  ensure (DatePicker.daysInMonth 2024 2 == 29) "Feb 2024 should have 29 days"
  ensure (DatePicker.daysInMonth 2025 2 == 28) "Feb 2025 should have 28 days"

test "DatePicker.dayOfWeek known date checks" := do
  -- 2024-01-01 was Monday => 1 when Sunday=0
  let dow := DatePicker.dayOfWeek { year := 2024, month := 1, day := 1 }
  ensure (dow == 1) s!"Expected Monday=1, got {dow}"

test "DatePicker.monthGrid size and populated day count" := do
  let grid := DatePicker.monthGrid 2024 2
  let countDays := grid.foldl (init := 0) fun acc cell =>
    if cell.isSome then acc + 1 else acc
  ensure (grid.size == 42) s!"Expected 42 cells, got {grid.size}"
  ensure (countDays == 29) s!"Expected 29 populated days, got {countDays}"

test "TimeValue 12-hour conversion and formatting" := do
  let midnight := TimeValue.from12Hour 12 5 9 true
  let afternoon := TimeValue.from12Hour 3 7 0 false
  ensure (midnight.hours == 0) "12:xx AM should map to hour 0"
  ensure (afternoon.hours == 15) "3:xx PM should map to hour 15"
  ensure (TimeValue.format24 afternoon false == "15:07") "24-hour format should be HH:MM"
  ensure (TimeValue.format12 afternoon false == "03:07 PM") "12-hour format should include period"

test "TimePicker increment/decrement helpers wrap correctly" := do
  let t0 : TimeValue := { hours := 23, minutes := 59, seconds := 0 }
  let t1 := TimePicker.incHours t0 true
  let t2 := TimePicker.decMinutes { t0 with minutes := 0 }
  let t3 := TimePicker.togglePeriod { hours := 10, minutes := 0, seconds := 0 }
  ensure (t1.hours == 0) "24-hour increment should wrap 23->0"
  ensure (t2.minutes == 59) "Minute decrement should wrap 0->59"
  ensure (t3.hours == 22) "Toggle period should add 12 hours"

/-! ## Pagination / SplitPane / Popover -/

test "Pagination.calculatePageButtons includes boundaries and ellipsis" := do
  let buttons := Pagination.calculatePageButtons 5 10 {}
  ensure (buttons[0]! == .prev) "First button should be prev"
  ensure (buttons.back?.isSome && buttons.back?.get! == .next) "Last button should be next"
  ensure (buttons.contains (.page 0)) "Should include first page"
  ensure (buttons.contains (.page 9)) "Should include last page"
  ensure (buttons.contains .ellipsis) "Should include ellipsis for skipped pages"

test "Pagination.isClickable respects current/edge states" := do
  ensure (!Pagination.isClickable .ellipsis 3 10) "Ellipsis should not be clickable"
  ensure (!Pagination.isClickable (.page 3) 3 10) "Current page should not be clickable"
  ensure (!Pagination.isClickable .prev 0 10) "Prev disabled on first page"
  ensure (!Pagination.isClickable .next 9 10) "Next disabled on last page"
  ensure (Pagination.isClickable (.page 4) 3 10) "Different page should be clickable"

test "SplitPane.clampRatio enforces min pane sizes" := do
  let config : SplitPaneConfig := { minPaneSize := 100, handleThickness := 10 }
  let low := SplitPane.clampRatio 0.0 500 config
  let high := SplitPane.clampRatio 1.0 500 config
  shouldBeNear low (100.0 / 490.0)
  shouldBeNear high (1.0 - (100.0 / 490.0))

test "SplitPane.ratioFromPosition computes centered ratio" := do
  let rect : LayoutRect := { x := 100, y := 50, width := 400, height := 300 }
  let config : SplitPaneConfig := { orientation := .horizontal, minPaneSize := 0, handleThickness := 10 }
  let ratio := SplitPane.ratioFromPosition .horizontal config rect 300
  shouldBeNear ratio 0.5

test "Popover.positionStyle sets expected anchors" := do
  let bottom := Popover.positionStyle .bottom 8
  let rightEnd := Popover.positionStyle .rightEnd 12
  ensure (bottom.position == .absolute) "Popover should use absolute positioning"
  ensure (bottom.layer == .overlay) "Popover should render on overlay layer"
  ensure (bottom.top == some 8 && bottom.left == some 0) "Bottom popover should anchor at top+left"
  ensure (rightEnd.left == some 12 && rightEnd.bottom == some 0) "Right-end popover should anchor left+bottom"

/-! ## Display Widgets -/

test "Avatar size and color helpers are stable" := do
  ensure (Avatar.sizePixels .small == 24.0) "Small avatar should be 24px"
  ensure (Avatar.fontSize .large == 20.0) "Large avatar font should be 20px"
  let c1 := Avatar.colorFromString "NH"
  let c2 := Avatar.colorFromString "NH"
  ensure (c1 == c2) "Color hash should be deterministic for same initials"
  ensure (Avatar.defaultColors.contains c1) "Generated color should come from palette"

test "Badge variant color helpers map to expected palette" := do
  let primary := Badge.variantBackgroundColor testTheme .primary
  let warning := Badge.variantBackgroundColor testTheme .warning
  ensure (primary == testTheme.primary.background) "Primary badge should use primary background"
  ensure (warning != primary) "Warning badge should differ from primary"
  ensure (Badge.variantTextColor testTheme .error == Color.white) "Badge text color should be white"

end Afferent.Tests.WidgetCoverageTests
