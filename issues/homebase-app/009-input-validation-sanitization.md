# Add Input Validation and Sanitization

## Summary

The application lacks comprehensive input validation beyond basic empty-string checks. Add proper validation for all user inputs to prevent security issues and improve UX.

## Current State

Current validation in actions:

```lean
-- Auth.lean
if email.isEmpty || password.isEmpty then
  flash "error" "Email and password required"
```

```lean
-- Kanban.lean
if name.isEmpty then
  flash "error" "Column name is required"
```

No validation for:
- Email format
- Password strength
- String length limits
- XSS prevention
- SQL injection (N/A with Ledger, but good practice)
- Special characters

## Requirements

### Validation Module

Create `HomebaseApp/Validation.lean`:

```lean
namespace Validation

structure ValidationError where
  field : String
  message : String
  deriving Repr, BEq

def ValidationResult := Except (List ValidationError)

-- Email validation
def validateEmail (email : String) : ValidationResult String := do
  if email.isEmpty then
    throw [{ field := "email", message := "Email is required" }]
  if !email.containsSubstr "@" then
    throw [{ field := "email", message := "Invalid email format" }]
  if email.length > 255 then
    throw [{ field := "email", message := "Email too long" }]
  pure email

-- Password validation
def validatePassword (password : String) : ValidationResult String := do
  if password.length < 8 then
    throw [{ field := "password", message := "Password must be at least 8 characters" }]
  if password.length > 128 then
    throw [{ field := "password", message := "Password too long" }]
  pure password

-- Generic string validation
def validateRequired (field : String) (value : String) : ValidationResult String := do
  if value.trim.isEmpty then
    throw [{ field, message := s!"{field} is required" }]
  pure value.trim

def validateMaxLength (field : String) (max : Nat) (value : String) : ValidationResult String := do
  if value.length > max then
    throw [{ field, message := s!"{field} must be {max} characters or less" }]
  pure value

-- Combine validators
def validateAll (validators : List (ValidationResult α)) : ValidationResult (List α) := ...

end Validation
```

### Sanitization Module

Create `HomebaseApp/Sanitization.lean`:

```lean
namespace Sanitization

-- Strip HTML tags (basic XSS prevention)
-- Note: Scribe auto-escapes, but sanitize stored data too
def stripHtml (s : String) : String := ...

-- Normalize whitespace
def normalizeWhitespace (s : String) : String :=
  s.trim.splitOn "  " |>.filter (!·.isEmpty) |> String.intercalate " "

-- Remove control characters
def removeControlChars (s : String) : String := ...

-- Sanitize for safe storage
def sanitizeInput (s : String) : String :=
  s |> stripHtml |> normalizeWhitespace |> removeControlChars

end Sanitization
```

### Field-Specific Validators

```lean
-- Kanban
def validateColumnName (name : String) : ValidationResult String := do
  let name ← validateRequired "name" name
  let name ← validateMaxLength "name" 100 name
  pure (sanitizeInput name)

def validateCardTitle (title : String) : ValidationResult String := do
  let title ← validateRequired "title" title
  let title ← validateMaxLength "title" 200 title
  pure (sanitizeInput title)

def validateCardDescription (desc : String) : ValidationResult String := do
  let desc ← validateMaxLength "description" 5000 desc
  pure (sanitizeInput desc)

-- Auth
def validateRegistration (email password name : String) : ValidationResult (String × String × String) := do
  let email ← validateEmail email
  let password ← validatePassword password
  let name ← validateRequired "name" name
  let name ← validateMaxLength "name" 100 name
  pure (email, password, sanitizeInput name)
```

### View Integration

```lean
-- Show validation errors in forms
def validationErrors (errors : List ValidationError) : HtmlM Unit := do
  unless errors.isEmpty do
    div [class "validation-errors"] do
      for err in errors do
        div [class "error"] do
          span [class "field"] do text err.field
          text ": "
          text err.message
```

## Acceptance Criteria

- [ ] All form inputs validated before processing
- [ ] Email format validation
- [ ] Password strength requirements (8+ chars)
- [ ] Maximum length limits on all string fields
- [ ] HTML/script tags stripped from inputs
- [ ] Validation errors displayed in forms
- [ ] Whitespace normalized (trim, collapse multiple spaces)
- [ ] Control characters removed

## Technical Notes

- Scribe already HTML-escapes output, but sanitize on input too
- Consider validation library extraction to separate package
- Length limits prevent DoS via large payloads
- Unicode normalization may be needed (NFC)

## Priority

High - Security and UX improvement

## Estimate

Medium - New module + integration with all forms
