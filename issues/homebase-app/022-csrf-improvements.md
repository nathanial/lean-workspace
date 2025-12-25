# Improve CSRF Protection

## Summary

Review and enhance CSRF (Cross-Site Request Forgery) protection to ensure all state-changing requests are properly protected.

## Current State

- Basic CSRF token support exists in Loom
- `csrfToken` helper available in views
- Unclear if all POST/PUT/DELETE routes are protected
- Token validation implementation needs review

## Requirements

### Audit Current Implementation

Check all state-changing routes:

```lean
-- Should have CSRF protection:
POST /login
POST /register
POST /kanban/column
PUT /kanban/column/:id
DELETE /kanban/column/:id
POST /kanban/card
PUT /kanban/card/:id
DELETE /kanban/card/:id
POST /kanban/card/:id/move
-- ... all POST/PUT/DELETE routes
```

### CSRF Middleware

```lean
-- Middleware/Csrf.lean

def csrfMiddleware : Middleware := fun handler => fun ctx => do
  -- Skip for safe methods
  if ctx.request.method ∈ [.GET, .HEAD, .OPTIONS] then
    return ← handler ctx

  -- Get token from form or header
  let formToken := ctx.request.formParam? "_csrf"
  let headerToken := ctx.request.header? "X-CSRF-Token"
  let token := formToken <|> headerToken

  -- Get expected token from session
  let expected := ctx.session.get? "csrf_token"

  match token, expected with
  | some t, some e =>
    if constantTimeCompare t e then
      handler ctx
    else
      forbidden "Invalid CSRF token"
  | _, _ =>
    forbidden "CSRF token missing"
```

### Constant-Time Comparison

Prevent timing attacks:

```lean
def constantTimeCompare (a b : String) : Bool :=
  if a.length != b.length then
    false
  else
    let pairs := a.data.zip b.data
    let diffs := pairs.map fun (x, y) => if x == y then 0 else 1
    diffs.foldl (· + ·) 0 == 0
```

### Token Generation

```lean
def generateCsrfToken : IO String := do
  let bytes ← IO.getRandomBytes 32
  return bytes.toHex

def ensureCsrfToken (session : Session) : IO (String × Session) := do
  match session.get? "csrf_token" with
  | some token => return (token, session)
  | none =>
    let token ← generateCsrfToken
    return (token, session.insert "csrf_token" token)
```

### HTMX Integration

HTMX requests need CSRF token in header:

```lean
-- In Layout.lean
script [] do
  rawText """
    document.body.addEventListener('htmx:configRequest', function(evt) {
      evt.detail.headers['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').content;
    });
  """

head do
  meta [name "csrf-token", content csrfToken]
```

### Double-Submit Cookie Pattern

Optional: Additional protection layer:

```lean
def doubleSubmitCookie : Middleware := fun handler => fun ctx => do
  let cookieToken := ctx.request.cookie? "csrf_cookie"
  let headerToken := ctx.request.header? "X-CSRF-Token"

  match cookieToken, headerToken with
  | some c, some h =>
    if constantTimeCompare c h then
      handler ctx
    else
      forbidden "CSRF validation failed"
  | _, _ =>
    forbidden "CSRF tokens missing"
```

### Form Helper Update

Ensure all forms include CSRF:

```lean
def form (attrs : List Attr) (content : HtmlM Unit) : HtmlM Unit := do
  let method := attrs.find? (·.name == "method") |>.map (·.value)
  Html.form attrs do
    -- Auto-include CSRF for non-GET forms
    when (method.map String.toLower != some "get") do
      csrfTokenInput
    content

def csrfTokenInput : HtmlM Unit := do
  let token ← getCsrfToken
  input [type "hidden", name "_csrf", value token]
```

## Acceptance Criteria

- [ ] All POST/PUT/DELETE routes have CSRF validation
- [ ] CSRF middleware rejects invalid tokens
- [ ] Constant-time comparison for tokens
- [ ] HTMX requests include CSRF header
- [ ] Forms auto-include CSRF token
- [ ] Token regenerated on login
- [ ] Clear error message on CSRF failure

## Technical Notes

- Session-bound tokens preferred over stateless
- Regenerate token on login to prevent fixation
- Consider SameSite cookie attribute
- Double-submit optional for extra security

## Priority

High - Security requirement

## Estimate

Small - Mostly verification and small fixes
