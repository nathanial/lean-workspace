# Consolidate JSON Serialization

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Each model type has manual ToJson/FromJson instances with repetitive boilerplate.

## Rationale
Consider using deriving for JSON instances where possible, or create helper macros to reduce boilerplate.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Core/Json.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Model/Novel.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Model/Character.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Model/WorldNote.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Model/Project.lean`
