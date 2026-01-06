---
id: 86
title: Test Filtering / Selection
status: closed
priority: medium
created: 2026-01-06T22:57:18
updated: 2026-01-06T23:12:32
labels: [feature]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Test Filtering / Selection

## Description
Add command-line arguments or configuration for running specific tests or suites. During development, it's useful to run only specific tests rather than the entire suite. Common patterns include name matching, tag filtering, or suite selection. Affected files: Crucible/Core.lean (add runTestsFiltered), new Crucible/CLI.lean for argument parsing.

## Progress
- [2026-01-06T23:12:32] Closed: Implemented test filtering via CLI args. Added Filter.lean, CLI.lean, runTestsFiltered, runAllSuitesFiltered. Usage: def main (args : List String) : IO UInt32 := runAllSuitesFiltered args. Supports --test, --suite, --exact, --help flags.
