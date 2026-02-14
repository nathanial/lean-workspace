/-
  Arbor Draw Types
  Shared draw datatypes used by immediate-mode rendering.
-/
import Afferent.UI.Arbor.Core.Types

namespace Afferent.Arbor

/-- Text horizontal alignment. -/
inductive TextAlign where
  | left
  | center
  | right
deriving Repr, BEq, Inhabited

/-- Text vertical alignment. -/
inductive TextVAlign where
  | top
  | middle
  | bottom
deriving Repr, BEq, Inhabited

end Afferent.Arbor
