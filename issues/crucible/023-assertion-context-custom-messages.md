# Assertion Context / Custom Messages

**Priority:** Medium
**Section:** API Enhancements
**Estimated Effort:** Small
**Dependencies:** None

## Description

Allow adding custom context messages to any assertion.

## Example

```lean
(actual ≡ expected) |> withContext "checking user authentication"
```

## Affected Files

- `Crucible/Core.lean`
