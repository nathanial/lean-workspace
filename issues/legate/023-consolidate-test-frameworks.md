# Consolidate Test Frameworks

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The project has two test framework components: `Crucible` (the shared test framework) and a local `Tests/Framework.lean` with duplicated functionality.

## Rationale
Either migrate fully to Crucible or document why both exist. The local framework appears to be for integration tests while Crucible is for unit tests.

## Affected Files
- `Tests/Framework.lean`
- Uses `Crucible` in `Tests/Main.lean`
