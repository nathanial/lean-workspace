/-
  Chroma - Color Picker Application
  Demo UI for the custom Arbor color picker widget.
-/
import Afferent
import Afferent.App.UIRunner
import Afferent.UI.Arbor
import Afferent.Runtime.FFI
import Afferent.UI.Widget
import Chroma.ColorPicker
import Chroma.Constants
import Trellis
import Tincture

open Afferent
open Chroma
open Tincture

def main : IO Unit := do
  IO.println "Chroma - Color Picker"

  let screenScale ← Afferent.FFI.getScreenScale
  let sizes := uiSizes
  let physWidth := (sizes.baseWidth * screenScale).toUInt32
  let physHeight := (sizes.baseHeight * screenScale).toUInt32

  let canvas ← Canvas.create physWidth physHeight "Chroma - Color Picker"

  let titleFont ← Font.load defaultFontPath (sizes.titleFontSize * screenScale).toUInt32
  let bodyFont ← Font.load defaultFontPath (sizes.bodyFontSize * screenScale).toUInt32
  let (fontReg1, titleId) := FontRegistry.empty.register titleFont "title"
  let (fontReg, bodyId) := fontReg1.register bodyFont "body"

  let bg := Color.fromHex "#1a1a2e" |>.getD (Color.rgb 0.1 0.1 0.18)
  let app : Afferent.App.UIApp PickerModel PickerMsg := {
    view := fun model =>
      let config : ColorPickerConfig := {
        size := sizes.pickerSize * screenScale
        ringThickness := sizes.ringThickness * screenScale
        segments := 144
        selectedHue := model.hue
        knobWidth := sizes.knobWidth * screenScale
        knobHeight := sizes.knobHeight * screenScale
        background := some (Color.gray 0.12)
        borderColor := some (Color.gray 0.35)
      }
      pickerUI titleId bodyId config screenScale
    update := updatePicker
    background := bg
    layout := .centeredIntrinsic
    sendHover := true
  }

  Afferent.App.run canvas fontReg {} app

  IO.println "Done!"
