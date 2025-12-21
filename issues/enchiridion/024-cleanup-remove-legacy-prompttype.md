# Remove Legacy PromptType

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
`PromptType` enum in `AI/Prompts.lean` is marked as legacy with a comment "use AIWritingAction instead" but is still present and used by `buildPrompt`.

## Rationale
Remove the `PromptType` enum, remove the `buildPrompt` function that uses it, and ensure all callers use `buildWritingActionPrompt` instead.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/AI/Prompts.lean` (lines 83-115, 118-139)
