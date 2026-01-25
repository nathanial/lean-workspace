---
id: 403
title: expose chat request options in AgentConfig
status: closed
priority: medium
created: 2026-01-25T01:57:22
updated: 2026-01-25T02:50:05
labels: []
assignee: 
project: oracle
blocks: []
blocked_by: []
---

# expose chat request options in AgentConfig

## Description
Agent loop hard-codes toolChoice .auto and doesn't expose sampling/stop/parallel_tool_calls; allow AgentConfig or runAgentLoop to pass through ChatRequest options (Oracle/Agent/Types.lean, Oracle/Agent/Loop.lean, Oracle/Request/ChatRequest.lean).

## Progress
- [2026-01-25T02:50:05] Closed: Implemented AgentRequestOptions/AgentConfig passthrough to ChatRequest and added tests (commit 4d29872).
