---
id: 761
title: macro_start_session requires project_key but should accept project_path
status: open
priority: medium
created: 2026-02-03T00:37:35
updated: 2026-02-03T00:37:35
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# macro_start_session requires project_key but should accept project_path

## Description
The macro_start_session tool requires project_key as a parameter, but a new agent doesn't know the project_key until after calling ensure_project. The macro should accept project_path and call ensure_project internally, making it a true one-shot session setup.

