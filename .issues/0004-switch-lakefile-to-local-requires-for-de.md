---
id: 4
title: Switch lakefile to local requires for development
status: closed
priority: medium
created: 2026-01-06T13:11:55
updated: 2026-01-06T13:17:37
labels: [dev]
assignee: 
blocks: []
blocked_by: []
---

# Switch lakefile to local requires for development

## Description
The tracker lakefile currently uses GitHub URLs for dependencies:

```lean
require terminus from git "https://github.com/nathanial/terminus" @ "v0.0.1"
require parlance from git "https://github.com/nathanial/parlance" @ "v0.0.1"
require chronos from git "https://github.com/nathanial/chronos-lean" @ "v0.0.1"
```

For local development, switch to local path requires:

```lean
require terminus from "../../../graphics/terminus"
require parlance from "../../../util/parlance"
require chronos from "../../../util/chronos"
```

This allows faster iteration when developing tracker alongside its dependencies.

Note: Before releasing, switch back to GitHub URLs with version tags.

## Progress
- [2026-01-06T13:17:37] Closed: Switched lakefile to local path requires for terminus, parlance, and chronos dependencies
