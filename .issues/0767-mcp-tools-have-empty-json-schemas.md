---
id: 767
title: MCP tools have empty JSON schemas
status: open
priority: high
created: 2026-02-03T00:39:26
updated: 2026-02-03T00:39:26
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# MCP tools have empty JSON schemas

## Description
The MCP tools are registered with empty JSON schemas:

  {"additionalProperties": true, "properties": {}, "type": "object"}

This means:
1. Claude/LLMs can't infer parameter types or names from the schema
2. No validation happens on the client side
3. IDE tooling can't provide autocomplete or type hints

The MCP server should provide complete JSON schemas with:
- All required and optional properties defined
- Types specified (string, array, boolean, etc.)
- Descriptions for each parameter
- Default values where applicable

This is likely the root cause of #766 - if schemas were properly defined, the descriptions would be auto-generated or at least the schema would be inspectable.

