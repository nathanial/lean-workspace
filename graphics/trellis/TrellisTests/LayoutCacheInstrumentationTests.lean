import Crucible
import Trellis

namespace TrellisTests.LayoutCacheInstrumentationTests

open Crucible
open Trellis

testSuite "Layout Cache Instrumentation Tests"

private def sampleTree : LayoutNode :=
  LayoutNode.row 0 #[
    LayoutNode.leaf' 1 20 10,
    LayoutNode.leaf' 2 30 12
  ] (gap := 4)

test "cache-enabled path records miss and recomputed nodes" := do
  let prev ← getLayoutInstrumentationConfig
  try
    setLayoutInstrumentationConfig { layoutCacheEnabled := true, strictValidationMode := false }
    resetLayoutInstrumentation
    let (_result, stats) ← layoutTrackedIO sampleTree 300 120
    shouldBe stats.layoutCacheHits 0
    shouldBe stats.layoutCacheMisses 1
    shouldBe stats.reusedNodeCount 0
    shouldBe stats.recomputedNodeCount sampleTree.nodeCount
    let snap ← snapshotLayoutInstrumentation
    shouldBe snap.layoutCacheHits 0
    shouldBe snap.layoutCacheMisses 1
    shouldBe snap.recomputedNodeCount sampleTree.nodeCount
  finally
    setLayoutInstrumentationConfig prev
    resetLayoutInstrumentation

test "cache toggle off disables cache path counters cleanly" := do
  let prev ← getLayoutInstrumentationConfig
  try
    setLayoutInstrumentationConfig { layoutCacheEnabled := false, strictValidationMode := false }
    resetLayoutInstrumentation
    let (_result, stats) ← layoutTrackedIO sampleTree 300 120
    shouldBe stats.layoutCacheHits 0
    shouldBe stats.layoutCacheMisses 0
    shouldBe stats.reusedNodeCount 0
    shouldBe stats.recomputedNodeCount sampleTree.nodeCount
    let snap ← snapshotLayoutInstrumentation
    shouldBe snap.layoutCacheHits 0
    shouldBe snap.layoutCacheMisses 0
    shouldBe snap.recomputedNodeCount sampleTree.nodeCount
  finally
    setLayoutInstrumentationConfig prev
    resetLayoutInstrumentation

test "strict validation mode performs equivalence check" := do
  let prev ← getLayoutInstrumentationConfig
  try
    setLayoutInstrumentationConfig { layoutCacheEnabled := true, strictValidationMode := true }
    resetLayoutInstrumentation
    let (_result, stats) ← layoutTrackedIO sampleTree 300 120
    shouldBe stats.strictValidationChecks 1
    shouldBe stats.strictValidationFailures 0
    shouldSatisfy (stats.strictValidationNanos > 0) "strict validation should be timed"
    let snap ← snapshotLayoutInstrumentation
    shouldBe snap.strictValidationChecks 1
    shouldBe snap.strictValidationFailures 0
  finally
    setLayoutInstrumentationConfig prev
    resetLayoutInstrumentation

end TrellisTests.LayoutCacheInstrumentationTests
