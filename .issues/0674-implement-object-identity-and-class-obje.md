---
id: 674
title: implement object identity and class objects/metaclasses
status: closed
priority: high
created: 2026-02-02T04:55:50
updated: 2026-02-02T06:04:44
labels: []
assignee: 
project: smalltalk
blocks: []
blocked_by: []
---

# implement object identity and class objects/metaclasses

## Description
Introduce object IDs, proper identity semantics, class objects + metaclasses, and class-side method dispatch. Remove the special-case new and use class-side behavior.

## Progress
- [2026-02-02T06:04:40] Implemented object IDs, class objects with metaclasses, class-side method dispatch, updated parser/AST/image, added tests and class-side syntax.
- [2026-02-02T06:04:44] Closed: Added object IDs, class objects/metaclasses with class-side dispatch, parser/AST updates, image format bump, and tests; lake test passes.
