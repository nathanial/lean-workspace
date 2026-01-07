---
id: 238
title: Potential adoption by workspace projects
status: open
priority: medium
created: 2026-01-07T03:51:57
updated: 2026-01-07T03:51:57
labels: [integration]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Potential adoption by workspace projects

## Description
Several workspace projects implement custom parsers that could potentially use Sift:

1. totem (TOML parser) - Has own parser primitives (Totem/Parser/Primitives.lean)
2. markup (HTML parser) - Has own error types and position tracking
3. herald (HTTP parser) - Could use Sift for header parsing
4. rune (regex) - Regex pattern parser could use Sift

Benefits of adoption:
- Consistent error handling across workspace
- Reduced code duplication
- Shared bug fixes and improvements

Action required:
1. Evaluate API compatibility with existing parsers
2. Document migration path
3. Consider backwards-compatible adapter layer

Effort: Large (per project)

