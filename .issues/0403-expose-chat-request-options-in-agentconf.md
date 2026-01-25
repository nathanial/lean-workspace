---
id: 403
title: expose chat request options in AgentConfig
status: open
priority: medium
created: 2026-01-25T01:57:22
updated: 2026-01-25T01:57:22
labels: []
assignee: 
project: oracle
blocks: []
blocked_by: []
---

# expose chat request options in AgentConfig

## Description
Agent loop hard-codes toolChoice .auto and doesn't expose sampling/stop/parallel_tool_calls; allow AgentConfig or runAgentLoop to pass through ChatRequest options (Oracle/Agent/Types.lean, Oracle/Agent/Loop.lean, Oracle/Request/ChatRequest.lean).

