import Crucible
import Trellis

namespace TrellisTests.LayoutSignatureTests

open Crucible
open Trellis

testSuite "Layout Signature Tests"

private def baseTree : LayoutNode :=
  LayoutNode.row 0 #[
    LayoutNode.leaf' 1 40 12,
    LayoutNode.leaf' 2 24 18
  ] (gap := 6)

test "signature changes when size-relevant fields change" := do
  let changedWidth :=
    LayoutNode.row 0 #[
      LayoutNode.leaf' 1 80 12,
      LayoutNode.leaf' 2 24 18
    ] (gap := 6)
  let changedGap :=
    LayoutNode.row 0 #[
      LayoutNode.leaf' 1 40 12,
      LayoutNode.leaf' 2 24 18
    ] (gap := 10)
  ensure (baseTree.layoutSignature != changedWidth.layoutSignature)
    "expected signature change when child size changes"
  ensure (baseTree.layoutSignature != changedGap.layoutSignature)
    "expected signature change when container gap changes"

test "signature is stable across identity-only id changes" := do
  let sameLayoutDifferentIds :=
    LayoutNode.row 1000 #[
      LayoutNode.leaf' 101 40 12,
      LayoutNode.leaf' 102 24 18
    ] (gap := 6)
  shouldBe baseTree.layoutSignature sameLayoutDifferentIds.layoutSignature

test "signature differs for structural child changes" := do
  let droppedChild :=
    LayoutNode.row 0 #[
      LayoutNode.leaf' 1 40 12
    ] (gap := 6)
  let reordered :=
    LayoutNode.row 0 #[
      LayoutNode.leaf' 2 24 18,
      LayoutNode.leaf' 1 40 12
    ] (gap := 6)
  ensure (baseTree.layoutSignature != droppedChild.layoutSignature)
    "expected signature change when child count changes"
  ensure (baseTree.layoutSignature != reordered.layoutSignature)
    "expected signature change when child order changes"

end TrellisTests.LayoutSignatureTests
