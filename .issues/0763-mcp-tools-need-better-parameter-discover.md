---
id: 763
title: MCP tools need better parameter discovery/documentation
status: open
priority: medium
created: 2026-02-03T00:37:40
updated: 2026-02-03T00:37:40
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# MCP tools need better parameter discovery/documentation

## Description
When calling MCP tools with missing parameters, the error only says 'missing required param: X' without listing all required parameters. This leads to trial-and-error discovery. For register_agent, I had to discover project_key, name, program, and model one at a time. Consider: (1) returning all missing required params in error, or (2) providing a schema/help tool.

