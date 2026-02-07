import Crucible
import Afferent.Canopy.Widget.Input.TextInput
import Afferent.Canopy.Widget.Input.PasswordInput
import Afferent.Canopy.Widget.Input.ComboBox
import Afferent.Canopy.Widget.Input.SearchInput
import Afferent.Canopy.Theme
import Afferent.Arbor.Event.Types

open Crucible
open Afferent.Canopy
open Afferent.Arbor

testSuite "afferent-text-inputs"

def testFont : Afferent.Arbor.FontId :=
  { Afferent.Arbor.FontId.default with id := 0, name := "test", size := 14.0 }

def testTheme : Theme :=
  { Theme.dark with font := testFont, smallFont := testFont }

test "TextInput.handleKeyPress respects max length" := do
  let state : TextInputState := { value := "abc", cursor := 3 }
  let event : KeyEvent := { key := .char 'd', modifiers := {} }
  let result := TextInput.handleKeyPress event state (some 3)
  ensure (result.value == "abc") s!"Expected unchanged text, got '{result.value}'"
  ensure (result.cursor == 3) s!"Expected cursor 3, got {result.cursor}"

test "TextInput.handleKeyPress cmd+left moves cursor to start" := do
  let state : TextInputState := { value := "hello", cursor := 4 }
  let event : KeyEvent := { key := .left, modifiers := { cmd := true } }
  let result := TextInput.handleKeyPress event state none
  ensure (result.cursor == 0) s!"Expected cursor 0, got {result.cursor}"

test "PasswordInput masking helpers hide text content" := do
  ensure (PasswordInput.maskString 4 == "****") "maskString should create repeated asterisks"
  ensure (PasswordInput.maskedText "secret" == "******") "maskedText should match input length"

test "ComboBox filtering handles case sensitivity correctly" := do
  let options := #["Alpha", "beta", "Gamma"]
  let insensitive := ComboBox.filterOptions options "AL" false
  let sensitive := ComboBox.filterOptions options "AL" true
  ensure (insensitive.size == 1) s!"Expected 1 case-insensitive match, got {insensitive.size}"
  ensure (insensitive[0]! == (0, "Alpha")) "Case-insensitive match should return Alpha"
  ensure (sensitive.isEmpty) "Case-sensitive filter should not match uppercase AL"

test "SearchInput icon and clear specs report expected intrinsic sizes" := do
  let dims : SearchInput.Dimensions := { iconSize := 20.0, iconPadding := 6.0, clearButtonSize := 18.0 }
  let iconSpec := SearchInput.searchIconSpec testTheme dims
  let clearSpec := SearchInput.clearButtonSpec testTheme false dims
  let (iconW, iconH) := iconSpec.measure 0 0
  let (clearW, clearH) := clearSpec.measure 0 0
  ensure (iconW == 26.0 && iconH == 20.0)
    s!"Expected icon size (26,20), got ({iconW},{iconH})"
  ensure (clearW == 18.0 && clearH == 18.0)
    s!"Expected clear size (18,18), got ({clearW},{clearH})"

def main : IO UInt32 := runAllSuites
