---
id: 48
title: Retry and Backoff for API Errors
status: open
priority: low
created: 2026-01-06T15:16:12
updated: 2026-01-06T15:16:12
labels: []
assignee: 
project: ask
blocks: []
blocked_by: []
---

# Retry and Backoff for API Errors

## Description
Auto retry with exponential backoff for rate limits (429) and timeouts. Respect Retry-After header from Oracle rateLimitError. Configurable max retries.

