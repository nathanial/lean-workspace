# Add Rate Limiting

## Summary

Add rate limiting to protect against brute-force attacks on authentication and abuse of API endpoints.

## Current State

- No rate limiting on any endpoints
- Login endpoint vulnerable to brute-force
- No protection against automated abuse

## Requirements

### Rate Limit Configuration

```lean
structure RateLimitConfig where
  windowSeconds : Nat      -- Time window for counting requests
  maxRequests : Nat        -- Max requests per window
  keyExtractor : Request → String  -- How to identify clients

def authRateLimit : RateLimitConfig := {
  windowSeconds := 60
  maxRequests := 5
  keyExtractor := fun req => req.ip ++ req.param "email"
}

def generalRateLimit : RateLimitConfig := {
  windowSeconds := 60
  maxRequests := 100
  keyExtractor := fun req => req.ip
}
```

### Middleware Implementation

```lean
-- Middleware/RateLimit.lean

structure RateLimitState where
  requests : HashMap String (List Nat)  -- key → timestamps
  mutex : IO.Mutex

def rateLimitMiddleware (config : RateLimitConfig) (state : RateLimitState) : Middleware :=
  fun handler => fun ctx => do
    let key := config.keyExtractor ctx.request
    let now ← IO.monoMsNow

    state.mutex.lock
    let timestamps := state.requests.findD key []
    let windowStart := now - config.windowSeconds * 1000
    let recent := timestamps.filter (· > windowStart)

    if recent.length >= config.maxRequests then
      state.mutex.unlock
      return tooManyRequests

    state.requests := state.requests.insert key (now :: recent)
    state.mutex.unlock

    handler ctx

def tooManyRequests : Response := {
  status := 429
  headers := [("Retry-After", "60")]
  body := "Too many requests. Please try again later."
}
```

### Apply to Routes

```lean
-- In Main.lean

-- Auth routes with strict rate limit
app.group "/login" (rateLimitMiddleware authRateLimit rateLimitState) do
  app.get "" Auth.loginForm
  app.post "" Auth.login

app.group "/register" (rateLimitMiddleware authRateLimit rateLimitState) do
  app.get "" Auth.registerForm
  app.post "" Auth.register

-- All other routes with general rate limit
app.use (rateLimitMiddleware generalRateLimit rateLimitState)
```

### Response Headers

Include rate limit info in responses:

```lean
def addRateLimitHeaders (remaining : Nat) (resetTime : Nat) : Response → Response :=
  fun resp => { resp with headers := resp.headers ++ [
    ("X-RateLimit-Limit", toString config.maxRequests)
    ("X-RateLimit-Remaining", toString remaining)
    ("X-RateLimit-Reset", toString resetTime)
  ]}
```

### Per-User Rate Limiting

For authenticated endpoints:

```lean
def userRateLimit : RateLimitConfig := {
  windowSeconds := 60
  maxRequests := 200
  keyExtractor := fun req =>
    match req.session.get? "user_id" with
    | some userId => userId
    | none => req.ip
}
```

## Acceptance Criteria

- [ ] Rate limiting on auth endpoints (5/minute)
- [ ] General rate limiting on all endpoints (100/minute)
- [ ] 429 response when limit exceeded
- [ ] Retry-After header in response
- [ ] Rate limit headers on all responses
- [ ] IP + email based key for auth
- [ ] User ID based key for authenticated requests

## Technical Notes

- In-memory state is fine for single instance
- Consider Redis for distributed rate limiting
- IP extraction needs to handle X-Forwarded-For
- Consider exponential backoff for repeat offenders

## Priority

High - Security requirement

## Estimate

Small - Straightforward middleware
