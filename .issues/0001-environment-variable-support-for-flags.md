---
id: 1
title: Environment variable support for flags
status: open
priority: high
created: 2026-01-06T14:47:03
updated: 2026-01-06T14:47:03
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Environment variable support for flags

## Description
Allow flags to fall back to environment variables when not specified on the command line (e.g., --token falls back to $TOKEN). Essential for containerized deployments and CI/CD pipelines. Affects: Core/Types.lean, Parse/Parser.lean, Command/Help.lean

