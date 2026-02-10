/-
  ComponentRegistry Unit Tests
-/
import Crucible
import Reactive
import Afferent.UI.Canopy.Reactive.Inputs

open Crucible
open Reactive Reactive.Host
open Afferent.Canopy.Reactive

namespace AfferentDemosTests.Registry

testSuite "ComponentRegistry"

test "register generates unique component ids" := do
  let result ← SpiderM.runFresh do
    let reg ← ComponentRegistry.create
    let n1 ← SpiderM.liftIO <| reg.register "button"
    let n2 ← SpiderM.liftIO <| reg.register "button"
    let n3 ← SpiderM.liftIO <| reg.register "checkbox"
    pure (n1, n2, n3)
  result.1 ≡ 0
  result.2.1 ≡ 1
  result.2.2 ≡ 2

test "input tracking" := do
  let result ← SpiderM.runFresh do
    let reg ← ComponentRegistry.create
    let _ ← SpiderM.liftIO <| reg.register "button" (isInput := false)
    let _ ← SpiderM.liftIO <| reg.register "text-input" (isInput := true)
    let _ ← SpiderM.liftIO <| reg.register "text-input" (isInput := true)
    let inputs ← SpiderM.liftIO reg.inputIds.get
    let interactives ← SpiderM.liftIO reg.interactiveIds.get
    pure (inputs.size, interactives.size)
  result.1 ≡ 2
  result.2 ≡ 3

test "non-interactive widgets not tracked" := do
  let result ← SpiderM.runFresh do
    let reg ← ComponentRegistry.create
    let _ ← SpiderM.liftIO <| reg.register "label" (isInput := false) (isInteractive := false)
    let _ ← SpiderM.liftIO <| reg.register "button"
    let interactives ← SpiderM.liftIO reg.interactiveIds.get
    pure interactives.size
  result ≡ 1

test "counter increments globally" := do
  let result ← SpiderM.runFresh do
    let reg ← ComponentRegistry.create
    let n1 ← SpiderM.liftIO <| reg.register "a"
    let n2 ← SpiderM.liftIO <| reg.register "b"
    let n3 ← SpiderM.liftIO <| reg.register "a"
    pure (n1, n2, n3)
  result.1 ≡ 0
  result.2.1 ≡ 1
  result.2.2 ≡ 2

test "initial focus is none" := do
  let initial ← SpiderM.runFresh do
    let reg ← ComponentRegistry.create
    reg.focusedInput.sample
  initial ≡ none

test "focus can be fired" := do
  SpiderM.runFresh do
    let reg ← ComponentRegistry.create
    let id ← SpiderM.liftIO <| reg.register "text-input" (isInput := true)
    SpiderM.liftIO <| reg.fireFocus (some id)

test "registries are independent" := do
  let result ← SpiderM.runFresh do
    let reg1 ← ComponentRegistry.create
    let reg2 ← ComponentRegistry.create
    let n1 ← SpiderM.liftIO <| reg1.register "button"
    let n2 ← SpiderM.liftIO <| reg2.register "button"
    pure (n1, n2)
  result.1 ≡ 0
  result.2 ≡ 0

test "mixed input and interactive flags" := do
  let result ← SpiderM.runFresh do
    let reg ← ComponentRegistry.create
    let _ ← SpiderM.liftIO <| reg.register "text-input" (isInput := true) (isInteractive := true)
    let _ ← SpiderM.liftIO <| reg.register "readonly" (isInput := true) (isInteractive := false)
    let inputs ← SpiderM.liftIO reg.inputIds.get
    let interactives ← SpiderM.liftIO reg.interactiveIds.get
    pure (inputs.size, interactives.size)
  result.1 ≡ 2
  result.2 ≡ 1



end AfferentDemosTests.Registry
