---
id: 548
title: Phase 1: Core Infrastructure
status: open
priority: high
created: 2026-01-31T01:16:06
updated: 2026-01-31T01:16:06
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# Phase 1: Core Infrastructure

## Description
Build foundation for agent-mail MCP server in Lean 4:

- Data models (Project, Agent, Message, FileReservation structures)
- SQLite storage via quarry library
- JSON serialization/deserialization (ToJson, FromJson instances)
- HTTP server foundation using citadel (MCP protocol over JSON-RPC 2.0)

Dependencies: quarry, citadel, herald, collimator

Reference: apps/agent-mail/ROADMAP.md, references/mcp_agent_mail/src/mcp_agent_mail/

