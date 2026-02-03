---
id: 765
title: ensure_project requires unclear 'human_key' parameter
status: open
priority: medium
created: 2026-02-03T00:39:06
updated: 2026-02-03T00:39:06
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# ensure_project requires unclear 'human_key' parameter

## Description
When calling ensure_project, the required 'human_key' parameter is not intuitive:

1. First attempted with just 'path' - got error about missing 'human_key'
2. Unclear what 'human_key' means - is it a project name? A slug? An identifier?
3. The returned object has both 'human_key' and 'slug' which appear to have the same value

Suggestions:
1. Rename to something clearer like 'project_name' or 'project_id'
2. Make it optional and derive from the path basename if not provided
3. Document what human_key is for and how it differs from slug

