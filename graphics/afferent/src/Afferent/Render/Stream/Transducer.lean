/-
  Afferent Render Stream Transducers
  Stateful stream-to-stream transforms with explicit finalization.
-/

namespace Afferent.Render

/-- Stateful stream transducer.
    - `init`: initial state
    - `step`: consume one input item and produce zero or more outputs
    - `done`: flush outputs at end-of-stream -/
structure Transducer (α β σ : Type) where
  init : σ
  step : σ → α → σ × Array β
  done : σ → Array β

namespace Transducer

/-- Run a transducer and return both final state and outputs. -/
def runArrayWithState (t : Transducer α β σ) (input : Array α) : σ × Array β := Id.run do
  let mut st := t.init
  let mut out : Array β := #[]
  for x in input do
    let (next, ys) := t.step st x
    st := next
    out := out ++ ys
  (st, out ++ t.done st)

/-- Run a transducer over an input array. -/
def runArray (t : Transducer α β σ) (input : Array α) : Array β := Id.run do
  (runArrayWithState t input).2

/-- Map outputs from a transducer. -/
def map (f : β → γ) (t : Transducer α β σ) : Transducer α γ σ where
  init := t.init
  step st x :=
    let (next, ys) := t.step st x
    (next, ys.map f)
  done st := (t.done st).map f

/-- Compose transducers left-to-right. -/
def compose
    (a : Transducer α β σ₁)
    (b : Transducer β γ σ₂)
    : Transducer α γ (σ₁ × σ₂) where
  init := (a.init, b.init)
  step st x := Id.run do
    let (aSt, bSt) := st
    let (aNext, aOut) := a.step aSt x
    let mut nextB := bSt
    let mut out : Array γ := #[]
    for y in aOut do
      let (bNext, bOut) := b.step nextB y
      nextB := bNext
      out := out ++ bOut
    pure ((aNext, nextB), out)
  done st := Id.run do
    let (aSt, bSt) := st
    let mut out : Array γ := #[]
    let mut nextB := bSt
    for y in a.done aSt do
      let (bNext, bOut) := b.step nextB y
      nextB := bNext
      out := out ++ bOut
    pure (out ++ b.done nextB)

/-- Run a transducer and fold outputs online in a monadic consumer.
    This avoids materializing an intermediate output array. -/
def runFoldWithStateM [Monad m]
    (t : Transducer α β σ)
    (input : Array α)
    (initAcc : τ)
    (f : τ → β → m τ)
    : m (σ × τ) := do
  let mut st := t.init
  let mut acc := initAcc
  for x in input do
    let (next, ys) := t.step st x
    st := next
    for y in ys do
      acc ← f acc y
  for y in t.done st do
    acc ← f acc y
  pure (st, acc)

/-- Run a transducer and fold outputs online in a monadic consumer. -/
def runFoldM [Monad m]
    (t : Transducer α β σ)
    (input : Array α)
    (initAcc : τ)
    (f : τ → β → m τ)
    : m τ := do
  let (_, acc) ← runFoldWithStateM t input initAcc f
  pure acc

end Transducer

end Afferent.Render
