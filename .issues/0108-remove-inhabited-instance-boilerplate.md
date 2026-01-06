---
id: 108
title: Remove Inhabited Instance Boilerplate
status: open
priority: low
created: 2026-01-06T23:28:57
updated: 2026-01-06T23:28:57
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Remove Inhabited Instance Boilerplate

## Description
Multiple structures define default values both as an Inhabited instance and as explicit default/empty/zero functions. Use deriving Inhabited with @[default_instance] where possible. Affected files: Flex.lean, Grid.lean, Types.lean. Effort: Small

