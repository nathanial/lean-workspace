---
id: 764
title: send_message parameter names are non-intuitive
status: open
priority: medium
created: 2026-02-03T00:38:59
updated: 2026-02-03T00:38:59
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# send_message parameter names are non-intuitive

## Description
When calling send_message, the parameter names are hard to guess correctly:

- Used 'from_agent' but API wanted 'sender_name'
- Used 'to_agents' but API wanted 'to'  
- Used 'body' but API wanted 'body_md'

This required 3 failed attempts to discover the correct names. Consider:
1. Accepting common aliases (from_agent, from, sender_name all work)
2. Using more predictable names that match the domain (from/to are email-like and intuitive)
3. Better error messages that suggest the correct parameter name when a close match is provided

