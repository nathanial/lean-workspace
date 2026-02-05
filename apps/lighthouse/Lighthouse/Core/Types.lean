/-
  Lighthouse Core Types
  View enums and basic types
-/

namespace Lighthouse

/-- The four main views of the application -/
inductive View where
  | entity        -- Entity browser
  | transaction   -- Transaction log
  | attribute     -- Attribute index
  | query         -- Query interface
  deriving Repr, BEq, Inhabited

/-- Focus within a split-pane view -/
inductive PaneFocus where
  | left          -- Left pane (list/navigation)
  | right         -- Right pane (details)
  deriving Repr, BEq, Inhabited

/-- Search/filter mode -/
inductive InputMode where
  | normal        -- Normal navigation
  | search        -- Search input active
  | query         -- Query input active
  deriving Repr, BEq, Inhabited

end Lighthouse
