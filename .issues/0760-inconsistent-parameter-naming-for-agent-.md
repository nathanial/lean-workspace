---
id: 760
title: Inconsistent parameter naming for agent registration
status: open
priority: medium
created: 2026-02-03T00:37:33
updated: 2026-02-03T00:37:33
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# Inconsistent parameter naming for agent registration

## Description
When calling register_agent, the parameter to specify the agent's name is 'name', but it's easy to assume it would be 'agent_name' for consistency with other tools that use 'agent_name'. The error messages don't clarify what parameters are expected - just says 'missing required param'. Consider either: (1) accepting both 'name' and 'agent_name', or (2) standardizing on one naming convention across all tools.

