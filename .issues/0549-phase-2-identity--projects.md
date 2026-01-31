---
id: 549
title: Phase 2: Identity & Projects
status: open
priority: high
created: 2026-01-31T01:16:09
updated: 2026-01-31T01:16:09
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# Phase 2: Identity & Projects

## Description
Implement identity and project management tools:

- health_check: Server readiness probe returning status, environment, HTTP host/port, database URL
- ensure_project: Idempotently create/ensure project from absolute path
- register_agent: Register agent identity with program, model, task description
- whois: Lookup agent details with optional recent commits
- Adjective+noun name generator for memorable agent identities (e.g., GreenCastle, BlueLake)

Reference: apps/agent-mail/ROADMAP.md lines 17-24

