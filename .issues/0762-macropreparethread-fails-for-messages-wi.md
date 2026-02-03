---
id: 762
title: macro_prepare_thread fails for messages without thread_id
status: open
priority: medium
created: 2026-02-03T00:37:37
updated: 2026-02-03T00:37:37
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# macro_prepare_thread fails for messages without thread_id

## Description
Messages can have thread_id: null (e.g., standalone messages not part of a thread). macro_prepare_thread requires thread_id, so it cannot be used to read these messages. Either: (1) allow message_id as an alternative parameter, or (2) auto-assign thread_ids to all messages.

