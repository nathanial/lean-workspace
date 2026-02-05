/-
  Staple.Json.Naming - Field naming conventions

  Provides transforms between different naming conventions used in JSON:
  - camelCase (default Lean style)
  - snake_case (common in Python/Ruby APIs)
  - kebab-case (common in HTML/CSS)
  - SCREAMING_SNAKE_CASE (constants)
-/
import Staple.Ascii

namespace Staple.Json

/-- Field naming convention for JSON serialization. -/
inductive FieldNaming where
  | preserve       -- Use field names as-is
  | camelCase      -- firstName
  | snakeCase      -- first_name
  | kebabCase      -- first-name
  | screamingSnake -- FIRST_NAME
  deriving Repr, BEq, Inhabited

namespace FieldNaming

/-! ## String Case Detection -/

/-- Check if a character is uppercase ASCII letter -/
private def isUpper (c : Char) : Bool :=
  c.toNat >= 65 && c.toNat <= 90

/-- Check if a character is lowercase ASCII letter -/
private def isLower (c : Char) : Bool :=
  c.toNat >= 97 && c.toNat <= 122

/-- Check if a character is ASCII letter -/
private def isAlpha (c : Char) : Bool :=
  isUpper c || isLower c

/-- Check if a character is ASCII digit -/
private def isDigit (c : Char) : Bool :=
  c.toNat >= 48 && c.toNat <= 57

/-- Convert character to uppercase -/
private def toUpper (c : Char) : Char :=
  if isLower c then Char.ofNat (c.toNat - 32) else c

/-- Convert character to lowercase -/
private def toLower (c : Char) : Char :=
  if isUpper c then Char.ofNat (c.toNat + 32) else c

/-! ## Word Splitting

Splits identifiers into words based on:
- camelCase boundaries (lowercase followed by uppercase)
- Underscores and hyphens as explicit separators
- Digit boundaries (letter to digit or digit to letter)
- Uppercase runs (e.g., "XMLParser" -> ["XML", "Parser"])
-/

/-- Split an identifier into its component words.
    Works with camelCase, snake_case, kebab-case, and mixed formats. -/
def splitWords (s : String) : List String := Id.run do
  if s.isEmpty then return []

  let chars := s.toList
  let mut words : List String := []
  let mut currentWord : List Char := []
  let mut prevWasUpper := false
  let mut prevWasDigit := false

  for c in chars do
    -- Separators start new word
    if c == '_' || c == '-' then
      if !currentWord.isEmpty then
        words := words ++ [String.ofList currentWord.reverse]
        currentWord := []
      prevWasUpper := false
      prevWasDigit := false
    -- Handle uppercase
    else if isUpper c then
      -- Start new word if previous was lowercase (camelCase boundary)
      -- or if we're at the end of an uppercase run followed by lowercase
      if !prevWasUpper && !currentWord.isEmpty then
        words := words ++ [String.ofList currentWord.reverse]
        currentWord := [c]
      else
        currentWord := c :: currentWord
      prevWasUpper := true
      prevWasDigit := false
    -- Handle lowercase
    else if isLower c then
      -- If previous was uppercase and we have more than one char,
      -- the last uppercase belongs to the new word (e.g., XMLParser)
      if prevWasUpper && currentWord.length > 1 then
        let lastUpper := currentWord.head!
        let rest := currentWord.tail!
        if !rest.isEmpty then
          words := words ++ [String.ofList rest.reverse]
        currentWord := [c, lastUpper]
      else
        currentWord := c :: currentWord
      prevWasUpper := false
      prevWasDigit := false
    -- Handle digits
    else if isDigit c then
      -- Start new word if transitioning from letters to digits
      if !prevWasDigit && !currentWord.isEmpty && (isAlpha (currentWord.head!)) then
        words := words ++ [String.ofList currentWord.reverse]
        currentWord := [c]
      else
        currentWord := c :: currentWord
      prevWasUpper := false
      prevWasDigit := true
    -- Other characters are kept
    else
      currentWord := c :: currentWord
      prevWasUpper := false
      prevWasDigit := false

  -- Add final word
  if !currentWord.isEmpty then
    words := words ++ [String.ofList currentWord.reverse]

  return words

/-! ## Case Transforms -/

/-- Convert a string to camelCase.
    First word is lowercase, subsequent words are capitalized.

    Examples:
    - "first_name" -> "firstName"
    - "FIRST_NAME" -> "firstName"
    - "first-name" -> "firstName"
    - "firstName" -> "firstName" -/
def toCamelCase (s : String) : String := Id.run do
  let words := splitWords s
  if words.isEmpty then return ""

  let firstWord := (words.head!).map toLower
  let restWords := words.tail!.map fun w =>
    if w.isEmpty then ""
    else
      let first := toUpper (w.get ⟨0⟩)
      let rest := (w.drop 1).map toLower
      String.singleton first ++ rest

  return firstWord ++ String.join restWords

/-- Convert a string to PascalCase.
    All words are capitalized.

    Examples:
    - "first_name" -> "FirstName"
    - "firstName" -> "FirstName" -/
def toPascalCase (s : String) : String := Id.run do
  let words := splitWords s
  let capitalizedWords := words.map fun w =>
    if w.isEmpty then ""
    else
      let first := toUpper (w.get ⟨0⟩)
      let rest := (w.drop 1).map toLower
      String.singleton first ++ rest
  return String.join capitalizedWords

/-- Convert a string to snake_case.
    All words lowercase, separated by underscores.

    Examples:
    - "firstName" -> "first_name"
    - "FirstName" -> "first_name"
    - "first-name" -> "first_name"
    - "XMLParser" -> "xml_parser" -/
def toSnakeCase (s : String) : String := Id.run do
  let words := splitWords s
  let lowerWords := words.map (·.map toLower)
  return String.intercalate "_" lowerWords

/-- Convert a string to kebab-case.
    All words lowercase, separated by hyphens.

    Examples:
    - "firstName" -> "first-name"
    - "first_name" -> "first-name"
    - "XMLParser" -> "xml-parser" -/
def toKebabCase (s : String) : String := Id.run do
  let words := splitWords s
  let lowerWords := words.map (·.map toLower)
  return String.intercalate "-" lowerWords

/-- Convert a string to SCREAMING_SNAKE_CASE.
    All words uppercase, separated by underscores.

    Examples:
    - "firstName" -> "FIRST_NAME"
    - "first_name" -> "FIRST_NAME"
    - "maxRetries" -> "MAX_RETRIES" -/
def toScreamingSnake (s : String) : String := Id.run do
  let words := splitWords s
  let upperWords := words.map (·.map toUpper)
  return String.intercalate "_" upperWords

/-! ## Apply Naming Convention -/

/-- Apply a naming convention to a field name. -/
def apply (naming : FieldNaming) (fieldName : String) : String :=
  match naming with
  | .preserve => fieldName
  | .camelCase => toCamelCase fieldName
  | .snakeCase => toSnakeCase fieldName
  | .kebabCase => toKebabCase fieldName
  | .screamingSnake => toScreamingSnake fieldName

/-! ## Reverse Transforms (for parsing) -/

/-- Normalize a field name for matching during parsing.
    Converts to lowercase with separators removed, allowing flexible matching. -/
def normalize (s : String) : String := Id.run do
  let mut result := ""
  for c in s.toList do
    if c == '_' || c == '-' then
      continue
    else
      result := result.push (toLower c)
  return result

/-- Check if two field names match under different naming conventions.
    This allows parsing JSON with different naming than the Lean field names. -/
def namesMatch (leanName jsonName : String) : Bool :=
  normalize leanName == normalize jsonName

end FieldNaming

end Staple.Json
