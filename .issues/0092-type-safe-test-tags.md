---
id: 92
title: Type-Safe Test Tags
status: open
priority: medium
created: 2026-01-06T22:57:28
updated: 2026-01-06T22:57:28
labels: [improvement]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Type-Safe Test Tags

## Description
No tagging system currently exists for categorizing tests. Add a tag system using a custom type or string array, enabling test filtering by category (unit, integration, slow, etc.). Provides better organization and selective test runs. Affected files: Crucible/Core.lean (add tags to TestCase), Crucible/Macros.lean (add tag syntax). Medium effort.

