/-
  Rune - Public API for regular expressions
-/

import Rune.Core.Error
import Rune.AST.Types
import Rune.Parser.Parser
import Rune.NFA.Types
import Rune.NFA.Compiler
import Rune.Match.Types
import Rune.Match.Simulation

namespace Rune

/-- A compiled regular expression -/
structure Regex where
  private mk ::
  nfa : NFA.NFA
  pattern : String
  deriving Repr, Inhabited

namespace Regex

/-- Compile a regex pattern string -/
def compile (pattern : String) : Except ParseError Regex := do
  let ast ← Parser.parse pattern
  let nfa := NFA.compile ast
  return { nfa, pattern }

/-- Compile a regex pattern (panics on invalid pattern).
    Use `regex%` macro for compile-time validation, or
    `compile` for dynamic patterns. -/
def compile! (pattern : String) : Regex :=
  match compile pattern with
  | .ok re => re
  | .error e => panic! s!"Regex.compile! failed: {e}"

/-- Escape all regex metacharacters in a string for use as a literal pattern.

    Example:
    ```lean
    Regex.escape "hello.world" == "hello\\.world"
    Regex.escape "[test]" == "\\[test\\]"
    ```
-/
def escape (s : String) : String :=
  s.foldl (fun acc c =>
    if "\\[](){}*+?.|^$".contains c then
      acc ++ "\\" ++ c.toString
    else
      acc.push c
  ) ""

/-- Get the original pattern string -/
def getPattern (re : Regex) : String :=
  re.pattern

/-- Get the number of capture groups -/
def captureCount (re : Regex) : Nat :=
  re.nfa.captureCount

/-- Check if the entire string matches the pattern -/
def isMatch (re : Regex) (input : String) : Option Match :=
  Match.matchFull re.nfa input

/-- Find the first match anywhere in the string -/
def find (re : Regex) (input : String) : Option Match :=
  Match.find re.nfa input

/-- Find a match starting at a specific position.
    Unlike `find`, this does not search further if no match starts at `startPos`.
    Useful for parser combinator integration where you need to match at the current position.

    Example:
    ```lean
    let re := Regex.compile! "[a-z]+"
    re.matchAt "123abc" 0    -- none (no match at position 0)
    re.matchAt "123abc" 3    -- some (Match "abc" starting at 3)
    ```
-/
def matchAt (re : Regex) (input : String) (startPos : Nat) : Option Match :=
  Match.findMatchAt re.nfa input startPos

/-- Match at the start of the string (position 0).
    Equivalent to `matchAt re input 0`.

    Unlike `isMatch`, this does not require the match to consume the entire string.

    Example:
    ```lean
    let re := Regex.compile! "[a-z]+"
    re.matchPrefix "hello123"  -- some (Match "hello")
    re.matchPrefix "123hello"  -- none
    re.isMatch "hello123"      -- none (doesn't match entire string)
    ```
-/
def matchPrefix (re : Regex) (input : String) : Option Match :=
  matchAt re input 0

/-- Find all non-overlapping matches -/
def findAll (re : Regex) (input : String) : List Match :=
  Match.findAll re.nfa input

/-- Test if pattern matches anywhere in string -/
def test (re : Regex) (input : String) : Bool :=
  Match.test re.nfa input

/-- Count number of matches -/
def count (re : Regex) (input : String) : Nat :=
  Match.count re.nfa input

end Regex

end Rune
