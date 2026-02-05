/-
  Staple.String - String utilities
-/
namespace Staple

/-- Check if `haystack` contains `needle` as a substring. -/
def String.containsSubstr (haystack needle : String) : Bool :=
  (haystack.splitOn needle).length > 1

/-- Pad a string on the left to reach the specified width. -/
def String.padLeft (s : String) (width : Nat) (c : Char := ' ') : String :=
  if s.length >= width then s
  else String.ofList (List.replicate (width - s.length) c) ++ s

/-- Pad a string on the right to reach the specified width. -/
def String.padRight (s : String) (width : Nat) (c : Char := ' ') : String :=
  if s.length >= width then s
  else s ++ String.ofList (List.replicate (width - s.length) c)

/-- Drop characters from the right while predicate holds. -/
def String.dropRightWhile (s : String) (p : Char → Bool) : String :=
  String.ofList (s.toList.reverse.dropWhile p).reverse

/-- Drop characters from the left while predicate holds. -/
def String.dropLeftWhile (s : String) (p : Char → Bool) : String :=
  String.ofList (s.toList.dropWhile p)

end Staple
