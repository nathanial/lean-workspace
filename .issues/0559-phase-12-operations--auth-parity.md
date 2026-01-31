---
id: 559
title: Phase 12: Operations & Auth Parity
status: open
priority: medium
created: 2026-01-31T01:25:06
updated: 2026-01-31T01:25:06
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# Phase 12: Operations & Auth Parity

## Description
Port operational/transport parity from Python reference: HTTP auth (bearer token, JWT/JWKS, RBAC role gating), rate limiting (memory/redis token bucket + per-minute caps), CORS, tool filtering profiles, output formatting (toon/text/json defaults), notifications signaling, logging/metrics configuration. Reference: references/mcp_agent_mail/src/mcp_agent_mail/config.py, http.py, app.py

