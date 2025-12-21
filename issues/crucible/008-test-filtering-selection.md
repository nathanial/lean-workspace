# Test Filtering / Selection

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description

Add command-line arguments or configuration for running specific tests or suites.

## Rationale

During development, it's useful to run only specific tests rather than the entire suite. Common patterns include name matching, tag filtering, or suite selection.

## Affected Files

- `Crucible/Core.lean` - Add `runTestsFiltered` with name pattern matching
- New file `Crucible/CLI.lean` - Command-line argument parsing
