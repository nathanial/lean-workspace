---
id: 550
title: Phase 3: Messaging
status: open
priority: high
created: 2026-01-31T01:16:12
updated: 2026-01-31T01:16:12
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# Phase 3: Messaging

## Description
Implement core messaging tools:

- send_message: Send markdown message with to/cc/bcc, attachments, importance, ack_required
- reply_message: Reply to existing message maintaining thread
- fetch_inbox: Retrieve messages with limit, urgent_only, include_bodies, since_ts filters
- mark_message_read: Mark message as read with timestamp
- acknowledge_message: Acknowledge receipt when ack_required
- Thread management: Thread ID tracking and conversation history

Reference: apps/agent-mail/ROADMAP.md lines 27-36

