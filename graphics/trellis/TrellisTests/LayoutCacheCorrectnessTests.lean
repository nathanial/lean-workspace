import Crucible
import Trellis

namespace TrellisTests.LayoutCacheCorrectnessTests

open Crucible
open Trellis

testSuite "Layout Cache Correctness Tests"

private def cachedSubtree : LayoutNode :=
  LayoutNode.column 10 #[
    LayoutNode.leaf' 11 30 12,
    LayoutNode.leaf' 12 36 14
  ] (gap := 3) (box := { width := .length 100, height := .length 60 })

private def treeWithSpacer (spacerWidth : Float) : LayoutNode :=
  LayoutNode.row 0 #[
    LayoutNode.leaf' 1 spacerWidth 10,
    cachedSubtree
  ] (box := { width := .length 320, height := .length 140 })

private def treeWithJustify (justify : JustifyContent) : LayoutNode :=
  let props : FlexContainer := { FlexContainer.row with justifyContent := justify }
  LayoutNode.flexBox 0 props #[
    cachedSubtree,
    LayoutNode.leaf' 2 24 10
  ] (box := { width := .length 320, height := .length 140 })

private def elasticTree : LayoutNode :=
  LayoutNode.column 0 #[
    LayoutNode.column 10 #[
      LayoutNode.leaf' 11 40 14,
      LayoutNode.leaf' 12 50 14
    ] (gap := 2)
  ]

test "cached and uncached layouts are equivalent for same input tree" := do
  let prev ← getLayoutInstrumentationConfig
  try
    setLayoutInstrumentationConfig { layoutCacheEnabled := true, strictValidationMode := false }
    resetLayoutCache
    resetLayoutInstrumentation
    let tree := treeWithSpacer 16
    let baseline := layout tree 320 140
    let (first, firstStats) ← layoutTrackedIO tree 320 140
    let (second, secondStats) ← layoutTrackedIO tree 320 140
    shouldBe baseline.layouts first.layouts
    shouldBe baseline.layouts second.layouts
    shouldSatisfy (firstStats.layoutCacheMisses > 0) "first pass should populate cache"
    shouldSatisfy (secondStats.layoutCacheHits > 0) "second pass should hit cache"
    shouldSatisfy (secondStats.recomputedNodeCount < tree.nodeCount)
      "cache hit should reduce recomputed nodes"
  finally
    setLayoutInstrumentationConfig prev
    resetLayoutCache
    resetLayoutInstrumentation

test "parent offset changes translate cached child subtree without recompute" := do
  let prev ← getLayoutInstrumentationConfig
  try
    setLayoutInstrumentationConfig { layoutCacheEnabled := true, strictValidationMode := false }
    resetLayoutCache
    resetLayoutInstrumentation
    let treeA := treeWithSpacer 10
    let treeB := treeWithSpacer 30
    let (first, _firstStats) ← layoutTrackedIO treeA 320 140
    let (second, secondStats) ← layoutTrackedIO treeB 320 140
    shouldSatisfy (secondStats.layoutCacheHits > 0)
      "expected cached subtree hit when only ancestor placement changes"
    shouldSatisfy (secondStats.reusedNodeCount > 0) "expected reused descendant nodes"
    let firstChild := first.get! 11
    let secondChild := second.get! 11
    shouldBeNear (secondChild.x - firstChild.x) 20 0.01
    shouldBeNear (secondChild.y - firstChild.y) 0 0.01
  finally
    setLayoutInstrumentationConfig prev
    resetLayoutCache
    resetLayoutInstrumentation

test "ancestor container changes that preserve child constraints keep child cache hit" := do
  let prev ← getLayoutInstrumentationConfig
  try
    setLayoutInstrumentationConfig { layoutCacheEnabled := true, strictValidationMode := false }
    resetLayoutCache
    resetLayoutInstrumentation
    let treeA := treeWithJustify .flexStart
    let treeB := treeWithJustify .flexEnd
    let (_first, _firstStats) ← layoutTrackedIO treeA 320 140
    let (second, secondStats) ← layoutTrackedIO treeB 320 140
    shouldSatisfy (secondStats.layoutCacheHits > 0)
      "expected subtree cache hit when ancestor justify-content changes"
    shouldSatisfy (secondStats.recomputedNodeCount < treeB.nodeCount)
      "expected partial recompute only"
    let moved := second.get! 11
    shouldSatisfy (moved.x > 0) "child subtree should be translated by ancestor change"
  finally
    setLayoutInstrumentationConfig prev
    resetLayoutCache
    resetLayoutInstrumentation

test "available-size changes invalidate subtree cache keys and force recompute" := do
  let prev ← getLayoutInstrumentationConfig
  try
    setLayoutInstrumentationConfig { layoutCacheEnabled := true, strictValidationMode := false }
    resetLayoutCache
    resetLayoutInstrumentation
    let _ ← layoutTrackedIO elasticTree 200 120
    let (_second, secondStats) ← layoutTrackedIO elasticTree 280 120
    shouldBe secondStats.layoutCacheHits 0
    shouldSatisfy (secondStats.layoutCacheMisses > 0) "available size change should miss cache"
    shouldBe secondStats.recomputedNodeCount elasticTree.nodeCount
  finally
    setLayoutInstrumentationConfig prev
    resetLayoutCache
    resetLayoutInstrumentation

end TrellisTests.LayoutCacheCorrectnessTests
