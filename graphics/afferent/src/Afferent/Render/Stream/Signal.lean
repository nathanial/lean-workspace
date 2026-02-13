/-
  Afferent Render Stream Signal Functions
  Arrow-style stateful reactive functions for frame-time stream composition.
-/

namespace Afferent.Render

/-- Stateful signal function (Arrow-style) over discrete frame samples. -/
structure SignalFn (α β σ : Type) where
  init : σ
  step : σ → Float → α → σ × β

namespace SignalFn

/-- Sample a signal function with a single input/time step. -/
def sample (sf : SignalFn α β σ) (dt : Float) (x : α) : σ × β :=
  sf.step sf.init dt x

/-- Map output of a signal function. -/
def map (f : β → γ) (sf : SignalFn α β σ) : SignalFn α γ σ where
  init := sf.init
  step st dt x :=
    let (next, y) := sf.step st dt x
    (next, f y)

/-- Compose two signal functions (`sf1 >>> sf2`). -/
def compose
    (sf1 : SignalFn α β σ₁)
    (sf2 : SignalFn β γ σ₂)
    : SignalFn α γ (σ₁ × σ₂) where
  init := (sf1.init, sf2.init)
  step st dt x :=
    let (s1, s2) := st
    let (s1', y) := sf1.step s1 dt x
    let (s2', z) := sf2.step s2 dt y
    ((s1', s2'), z)

/-- Arrow combinator: apply signal function to first element of a pair. -/
def first (sf : SignalFn α β σ) : SignalFn (α × γ) (β × γ) σ where
  init := sf.init
  step st dt xg :=
    let (x, g) := xg
    let (next, y) := sf.step st dt x
    (next, (y, g))

end SignalFn

end Afferent.Render
