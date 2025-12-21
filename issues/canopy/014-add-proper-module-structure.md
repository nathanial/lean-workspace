# Add Proper Module Structure

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small (structure only)
**Dependencies:** None

## Description
The project has only two files: `Canopy.lean` and `Canopy/Core.lean` with minimal content.

Proposed change: Create a proper module hierarchy reflecting planned features:
```
Canopy/
  Core.lean           -- Re-exports, version, core types
  Widget/             -- Stateful widget system
  Theme/              -- Theming
  Focus/              -- Focus management
  Animation/          -- Animations
  Layout/             -- Layout helpers
  Widgets/            -- Common widgets
  Form/               -- Form handling
  Accessibility/      -- A11y
  DnD/                -- Drag and drop
```

## Rationale
Clear code organization, easier navigation, explicit module boundaries.

## Affected Files
All project files
