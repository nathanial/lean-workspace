/-
  Tracer.Sampler - Sampling strategies

  Samplers determine which traces should be recorded and exported.
-/

import Tracer.Config

namespace Tracer

-- Sampler is defined in Config.lean
namespace Sampler

/-- Always sample all traces -/
def alwaysOn : Sampler :=
  { shouldSample := fun _ => pure true }

/-- Never sample any traces -/
def alwaysOff : Sampler :=
  { shouldSample := fun _ => pure false }

/-- Sample with a given probability (0.0 to 1.0) -/
def probability (rate : Float) : Sampler :=
  { shouldSample := fun _ => do
      if rate <= 0.0 then pure false
      else if rate >= 1.0 then pure true
      else
        let rand ← IO.rand 0 999999
        pure (Float.ofNat rand / 1000000.0 < rate)
  }

/-- Parent-based sampling: inherit decision from parent, use root sampler for new traces -/
def parentBased (rootSampler : Sampler) : Sampler :=
  { shouldSample := fun ctx => do
      -- If this is a child span (has valid trace ID from parent), inherit parent's decision
      if ctx.isSampled then pure true
      else if ctx.traceId.isValid then pure false
      -- For root spans, use the provided root sampler
      else rootSampler.shouldSample ctx
  }

/-- Rate-limited sampling: sample up to N traces per second -/
def rateLimited (tracesPerSecond : Nat) : IO Sampler := do
  -- Simple token bucket implementation
  let lastSecondRef ← IO.mkRef (0 : Nat)
  let tokenCountRef ← IO.mkRef tracesPerSecond
  pure {
    shouldSample := fun _ => do
      let now ← IO.monoNanosNow
      let currentSecond := now / 1_000_000_000
      let lastSecond ← lastSecondRef.get
      -- Reset tokens at the start of each second
      if currentSecond > lastSecond then
        lastSecondRef.set currentSecond
        tokenCountRef.set tracesPerSecond
      -- Try to consume a token
      let tokens ← tokenCountRef.get
      if tokens > 0 then
        tokenCountRef.set (tokens - 1)
        pure true
      else
        pure false
  }

end Sampler
end Tracer
