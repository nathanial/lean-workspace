import Crucible
import Afferent.UI.Canopy.Widget.Input.TimePicker
import Afferent.UI.Canopy.Theme

open Crucible
open Afferent.Canopy
open Afferent.Arbor

testSuite "afferent-time-picker"

def testFont : Afferent.Arbor.FontId :=
  { Afferent.Arbor.FontId.default with id := 0, name := "test", size := 14.0 }

def testTheme : Theme :=
  { Theme.dark with font := testFont, smallFont := testFont }

test "TimeValue.from12Hour converts edge cases correctly" := do
  let midnight := TimeValue.from12Hour 12 0 0 true
  let noon := TimeValue.from12Hour 12 0 0 false
  let afternoon := TimeValue.from12Hour 3 7 9 false
  ensure (midnight.hours == 0) s!"Expected 12 AM -> 0, got {midnight.hours}"
  ensure (noon.hours == 12) s!"Expected 12 PM -> 12, got {noon.hours}"
  ensure (afternoon.hours == 15) s!"Expected 3 PM -> 15, got {afternoon.hours}"

test "Time formatting helpers produce padded output" := do
  let t : TimeValue := { hours := 15, minutes := 7, seconds := 5 }
  ensure (TimeValue.format24 t true == "15:07:05") "Expected padded 24-hour format"
  ensure (TimeValue.format12 t true == "03:07:05 PM") "Expected padded 12-hour format"
  ensure (TimePicker.displayHours { t with hours := 0 } false == "12")
    "12-hour display should show 12 for midnight"

test "TimePicker increment/decrement helpers wrap values" := do
  let t : TimeValue := { hours := 23, minutes := 0, seconds := 59 }
  let incH := TimePicker.incHours t true
  let decM := TimePicker.decMinutes t
  let incS := TimePicker.incSeconds t
  let toggled := TimePicker.togglePeriod { hours := 10, minutes := 0, seconds := 0 }
  ensure (incH.hours == 0) "24-hour increment should wrap 23->0"
  ensure (decM.minutes == 59) "Minute decrement should wrap 0->59"
  ensure (incS.seconds == 0) "Second increment should wrap 59->0"
  ensure (toggled.hours == 22) "AM/PM toggle should add 12 hours"

test "timePickerVisual child layout depends on config flags" := do
  let time : TimeValue := { hours := 13, minutes := 5, seconds := 9 }
  let cfg24NoSeconds : TimePickerConfig := { use24Hour := true, showSeconds := false }
  let cfg12WithSeconds : TimePickerConfig := { use24Hour := false, showSeconds := true }
  let container24 : ComponentId := 100
  let container12 : ComponentId := 101

  let visual24 := timePickerVisual
    container24
    110 111 112 113 114 115 116
    time
    false false false false false false false
    testTheme cfg24NoSeconds
  let (widget24, _) ← visual24.run {}

  let visual12 := timePickerVisual
    container12
    120 121 122 123 124 125 126
    time
    false false false false false false false
    testTheme cfg12WithSeconds
  let (widget12, _) ← visual12.run {}

  match widget24 with
  | .flex _ _ _ _ children (some cid) =>
      ensure (cid == container24) s!"Expected container component id {container24}, got {cid}"
      ensure (children.size == 3) s!"Expected 3 children (HH:MM), got {children.size}"
  | _ => ensure false "Expected 24-hour time picker root widget with component id"

  match widget12 with
  | .flex _ _ _ _ children (some cid) =>
      ensure (cid == container12) s!"Expected container component id {container12}, got {cid}"
      ensure (children.size == 6) s!"Expected 6 children (HH:MM:SS + AM/PM), got {children.size}"
  | _ => ensure false "Expected 12-hour time picker root widget with component id"

test "ampmButtonVisual renders the expected label text" := do
  let ampmId : ComponentId := 200
  let (button, _) ← (ampmButtonVisual ampmId false false testTheme).run {}
  match button with
  | .flex _ _ _ _ children (some cid) =>
      ensure (cid == ampmId) s!"Expected AM/PM component id {ampmId}, got {cid}"
      ensure (children.size == 1) "AM/PM button should contain one text child"
      match children[0]! with
      | .text _ _ content .. =>
          ensure (content == "PM") s!"Expected PM label, got '{content}'"
      | _ => ensure false "Expected text child for AM/PM button label"
  | _ => ensure false "Expected AM/PM button widget with component id"

def main : IO UInt32 := runAllSuites
