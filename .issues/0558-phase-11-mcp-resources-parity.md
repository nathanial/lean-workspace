---
id: 558
title: Phase 11: MCP Resources Parity
status: closed
priority: medium
created: 2026-01-31T01:25:00
updated: 2026-02-01T02:04:06
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# Phase 11: MCP Resources Parity

## Description
Port MCP resources exposed by the Python reference server. Required resources include: config/tooling (resource://config/environment, resource://tooling/{directory,schemas,metrics,locks,capabilities,recent}), discovery (resource://projects, resource://project/{slug}, resource://agents/{project_key}, resource://identity/{project}), mail views (resource://message/{id}, resource://thread/{id}, resource://mailbox/{agent}, resource://mailbox-with-commits/{agent}, resource://outbox/{agent}, resource://views/{urgent-unread,ack-required,acks-stale,ack-overdue}), file reservations (resource://file_reservations/{slug}), and product (resource://product/{key}). Reference: references/mcp_agent_mail/src/mcp_agent_mail/app.py

## Progress
- [2026-02-01T02:03:39] Reopened
