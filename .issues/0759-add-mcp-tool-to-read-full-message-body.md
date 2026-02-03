---
id: 759
title: Add MCP tool to read full message body
status: open
priority: high
created: 2026-02-03T00:37:31
updated: 2026-02-03T00:37:31
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# Add MCP tool to read full message body

## Description
fetch_inbox and search_messages only return message metadata (from, subject, id, importance, thread_id) but not the actual message body content. There's no get_message or read_message tool to retrieve the full content of a message. This makes it impossible for agents to actually read their mail.

