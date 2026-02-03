---
id: 754
title: agent-mail live web app scaffold
status: closed
priority: high
created: 2026-02-02T22:08:48
updated: 2026-02-02T22:47:17
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# agent-mail live web app scaffold

## Description
Create a Loom + Citadel web app for agent-mail with server routes, layout, and asset pipeline. Establish live UI entrypoint and wiring to existing MCP/HTTP server.

## Progress
- [2026-02-02T22:12:14] Reviewed homebase-app and docsite Loom/Citadel patterns: Loom.app config + withStencil (templates/.html.hbs), templates/layouts + public/ assets, pages defined via page/view/action macros with #generate_pages, SSE endpoints + SSE.publishEvent + HX-Request partials used in homebase-app.
- [2026-02-02T22:47:09] Added Loom web UI under /app with handler integration, templates, and public assets. Web UI loads projects/threads and renders read-only views.
- [2026-02-02T22:47:17] Closed: Web UI scaffold under /app is wired into server with Loom templates and assets.
