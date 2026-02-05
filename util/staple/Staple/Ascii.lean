/-
  Staple.Ascii - ASCII character classification and case conversion

  Provides predicates for classifying ASCII characters and functions
  for case conversion. Includes both Char and UInt8 variants.
-/

namespace Staple.Ascii

/-! ## Character Classification -/

/-- Check if a character is ASCII whitespace (space, tab, newline, carriage return). -/
@[inline] def isWhitespace (c : Char) : Bool :=
  c == ' ' || c == '\t' || c == '\n' || c == '\r'

/-- Check if a character is an ASCII letter (a-z, A-Z). -/
@[inline] def isAlpha (c : Char) : Bool :=
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')

/-- Check if a character is an ASCII digit (0-9). -/
@[inline] def isDigit (c : Char) : Bool :=
  c >= '0' && c <= '9'

/-- Check if a character is alphanumeric (letter or digit). -/
@[inline] def isAlphaNum (c : Char) : Bool :=
  isAlpha c || isDigit c

/-- Check if a character is an octal digit (0-7). -/
@[inline] def isOctalDigit (c : Char) : Bool :=
  c >= '0' && c <= '7'

/-- Check if a character is a binary digit (0 or 1). -/
@[inline] def isBinaryDigit (c : Char) : Bool :=
  c == '0' || c == '1'

/-- Check if a character is a printable ASCII character (0x20-0x7E). -/
@[inline] def isPrintable (c : Char) : Bool :=
  c.toNat >= 0x20 && c.toNat <= 0x7E

/-! ## Case Conversion -/

/-- Convert an ASCII uppercase letter to lowercase. Non-letters are unchanged. -/
@[inline] def toLower (c : Char) : Char :=
  if c >= 'A' && c <= 'Z' then Char.ofNat (c.toNat - 'A'.toNat + 'a'.toNat)
  else c

/-- Convert an ASCII lowercase letter to uppercase. Non-letters are unchanged. -/
@[inline] def toUpper (c : Char) : Char :=
  if c >= 'a' && c <= 'z' then Char.ofNat (c.toNat - 'a'.toNat + 'A'.toNat)
  else c

/-- Convert all ASCII uppercase letters in a string to lowercase. -/
def String.toLowerAscii (s : String) : String := s.map toLower

/-- Convert all ASCII lowercase letters in a string to uppercase. -/
def String.toUpperAscii (s : String) : String := s.map toUpper

/-! ## UInt8 Variants for Byte-Level Parsing -/

/-- Check if a byte is an ASCII digit (0x30-0x39). -/
@[inline] def isDigitByte (b : UInt8) : Bool := b >= 48 && b <= 57

/-- Check if a byte is an ASCII letter (A-Z or a-z). -/
@[inline] def isAlphaByte (b : UInt8) : Bool :=
  (b >= 65 && b <= 90) || (b >= 97 && b <= 122)

/-- Check if a byte is ASCII whitespace (space, tab, LF, CR). -/
@[inline] def isWhitespaceByte (b : UInt8) : Bool :=
  b == 32 || b == 9 || b == 10 || b == 13

/-- Check if a byte is alphanumeric (letter or digit). -/
@[inline] def isAlphaNumByte (b : UInt8) : Bool :=
  isAlphaByte b || isDigitByte b

/-- Check if a byte is a printable ASCII character (0x20-0x7E). -/
@[inline] def isPrintableByte (b : UInt8) : Bool :=
  b >= 0x20 && b <= 0x7E

end Staple.Ascii
