# Image Render Command

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add render commands for displaying images and textures.

## Rationale
The current render command set lacks image drawing capabilities. While backends would implement the actual image loading, Arbor should define the abstract command.

## Affected Files
- `Arbor/Core/Types.lean` - add `ImageId` type
- `Arbor/Render/Command.lean` - add image commands
- `Arbor/Widget/Core.lean` - add image widget variant

## Proposed API
```lean
structure ImageId where
  id : Nat
  path : Option String  -- for debug/identification

inductive RenderCommand where
  | ... -- existing commands
  | drawImage (imageId : ImageId) (rect : Rect) (tint : Option Color := none)
  | drawImageSliced (imageId : ImageId) (rect : Rect) (slices : NineSlice)
```
