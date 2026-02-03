---
id: 766
title: MCP tool descriptions lack parameter documentation
status: open
priority: high
created: 2026-02-03T00:39:17
updated: 2026-02-03T00:39:17
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# MCP tool descriptions lack parameter documentation

## Description
The MCP tool descriptions provide no information about required parameters. For example, send_message only says:

  'Send a markdown message to one or more agents.'

But doesn't document:
- project_key (required)
- sender_name (required)  
- to (required, array)
- subject (required)
- body_md (required)
- Optional parameters like cc, bcc, importance, attachments, etc.

This is the root cause of trial-and-error usage. LLMs rely heavily on tool descriptions to construct correct calls. Each MCP tool should have a complete parameter list with types and descriptions in the tool's description field.

Related to #763 but distinct - #763 is about error messages, this is about proactive documentation in the tool schema.

