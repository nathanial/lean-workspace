/-
  Widget layout-signature tests for Arbor.
-/
import AfferentTests.Framework
import Afferent.UI.Arbor

namespace AfferentTests.LayoutSignatureTests

open Crucible
open AfferentTests
open Afferent.Arbor
open Afferent

testSuite "Layout Signature Tests"

private def fontA : FontId := { id := 1, name := "mono-14", size := 14.0 }
private def fontB : FontId := { id := 2, name := "mono-18", size := 18.0 }

test "text signature changes for layout-affecting inputs" := do
  let base := Widget.text 1 none "abc" fontA Color.white .left (some 80) none
  let changedContent := Widget.text 1 none "abcd" fontA Color.white .left (some 80) none
  let changedFont := Widget.text 1 none "abc" fontB Color.white .left (some 80) none
  let changedWrap := Widget.text 1 none "abc" fontA Color.white .left (some 120) none
  ensure (base.layoutSignature != changedContent.layoutSignature)
    "expected signature change when text content changes"
  ensure (base.layoutSignature != changedFont.layoutSignature)
    "expected signature change when font changes"
  ensure (base.layoutSignature != changedWrap.layoutSignature)
    "expected signature change when wrap width changes"

test "signature is stable for render-only visual changes" := do
  let textBase := Widget.text 1 none "abc" fontA Color.white .left (some 80) none
  let textColorChanged := Widget.text 1 none "abc" fontA Color.red .left (some 80) none
  let rectBase := Widget.rect 2 none { minWidth := some 32, minHeight := some 16, backgroundColor := some Color.blue }
  let rectVisualChanged := Widget.rect 2 none {
    minWidth := some 32
    minHeight := some 16
    backgroundColor := some Color.green
    borderColor := some Color.white
    cornerRadius := 8
  }
  shouldBe textBase.layoutSignature textColorChanged.layoutSignature
  shouldBe rectBase.layoutSignature rectVisualChanged.layoutSignature

test "custom layout key participates in signature" := do
  let base : Widget :=
    .custom 3 none {} { CustomSpec.default with layoutKey := some 11 }
  let changed : Widget :=
    .custom 3 none {} { CustomSpec.default with layoutKey := some 12 }
  ensure (base.layoutSignature != changed.layoutSignature)
    "expected signature change when custom layout key changes"

test "container signature changes for structural child updates" := do
  let style : BoxStyle := { width := .length 200, height := .length 40 }
  let a := Widget.spacer 10 none 20 10
  let b := Widget.spacer 11 none 30 10
  let base := Widget.flex 1 none (Trellis.FlexContainer.row 4) style #[a, b]
  let dropped := Widget.flex 1 none (Trellis.FlexContainer.row 4) style #[a]
  let reordered := Widget.flex 1 none (Trellis.FlexContainer.row 4) style #[b, a]
  ensure (base.layoutSignature != dropped.layoutSignature)
    "expected signature change when child count changes"
  ensure (base.layoutSignature != reordered.layoutSignature)
    "expected signature change when child order changes"

end AfferentTests.LayoutSignatureTests
