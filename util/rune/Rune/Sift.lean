/-
  Rune - Sift Parser Combinator Integration

  Provides combinators for using Rune regexes within Sift parsers.
-/

import Sift
import Rune.API

namespace Rune

/-- Match a compiled regex at the current position.
    Returns the matched text on success.

    Example:
    ```lean
    let re := Rune.Regex.compile! "[a-z]+"
    let parseWord : Sift.Parser Unit String := Rune.regex re
    ```
-/
def regex {σ : Type} (re : Regex) : Sift.Parser σ String := fun s =>
  match re.matchAt s.input s.pos with
  | some m =>
    let matched := m.text
    -- Update position to end of match, tracking line/column changes
    let newState := matched.foldl (fun st c =>
      if c == '\n' then { st with line := st.line + 1, column := 1 }
      else { st with column := st.column + 1 }
    ) { s with pos := m.stop }
    .ok (matched, newState)
  | none =>
    .error (Sift.ParseError.fromState s s!"regex '{re.getPattern}' did not match")

/-- Match a compiled regex at the current position.
    Returns the full Match object, allowing access to capture groups.

    Example:
    ```lean
    let re := Rune.Regex.compile! "([a-z]+)@([a-z]+)"
    let parseEmail : Sift.Parser Unit Match := Rune.regexMatch re
    match Sift.Parser.run parseEmail "user@domain" with
    | .ok m =>
      IO.println (m.group 1)  -- some "user"
      IO.println (m.group 2)  -- some "domain"
    | .error _ => pure ()
    ```
-/
def regexMatch {σ : Type} (re : Regex) : Sift.Parser σ Match := fun s =>
  match re.matchAt s.input s.pos with
  | some m =>
    let matched := m.text
    let newState := matched.foldl (fun st c =>
      if c == '\n' then { st with line := st.line + 1, column := 1 }
      else { st with column := st.column + 1 }
    ) { s with pos := m.stop }
    .ok (m, newState)
  | none =>
    .error (Sift.ParseError.fromState s s!"regex '{re.getPattern}' did not match")

/-- Match a compiled regex at the current position.
    Returns a tuple of (matched text, capture groups array).

    Captures are 1-indexed in the regex but 0-indexed in the returned array.
    So capture group 1 is at index 0 in the array.

    Example:
    ```lean
    let re := Rune.Regex.compile! "([a-z]+)@([a-z]+)"
    let parseEmail := Rune.regexCaptures re
    match Sift.Parser.run parseEmail "user@domain" with
    | .ok (text, captures) =>
      -- text = "user@domain"
      -- captures[0] = some "user"
      -- captures[1] = some "domain"
    | .error _ => pure ()
    ```
-/
def regexCaptures {σ : Type} (re : Regex) : Sift.Parser σ (String × Array (Option String)) := fun s =>
  match re.matchAt s.input s.pos with
  | some m =>
    let matched := m.text
    let newState := matched.foldl (fun st c =>
      if c == '\n' then { st with line := st.line + 1, column := 1 }
      else { st with column := st.column + 1 }
    ) { s with pos := m.stop }
    -- Extract captures (1-indexed in regex, convert to 0-indexed array)
    let captures := (List.range m.numCaptures).map (fun i => m.group (i + 1)) |>.toArray
    .ok ((matched, captures), newState)
  | none =>
    .error (Sift.ParseError.fromState s s!"regex '{re.getPattern}' did not match")

end Rune
