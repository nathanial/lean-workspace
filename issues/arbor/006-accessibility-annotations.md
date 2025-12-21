# Accessibility Annotations

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add accessibility metadata to widgets for screen readers and assistive technologies.

## Rationale
Widget semantics (role, label, state) should be captured for accessibility purposes, even if backends implement the actual accessibility APIs.

## Affected Files
- `Arbor/Core/Accessibility.lean` (new file)
- `Arbor/Widget/Core.lean` - add accessibility props to widgets

## Proposed API
```lean
inductive AccessibilityRole where
  | button | link | heading | list | listItem | textInput | ...

structure AccessibilityProps where
  role : Option AccessibilityRole
  label : Option String
  description : Option String
  hidden : Bool := false
  live : Option LiveRegion := none
```
