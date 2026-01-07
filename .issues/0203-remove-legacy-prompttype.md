---
id: 203
title: Remove Legacy PromptType
status: open
priority: high
created: 2026-01-07T01:10:31
updated: 2026-01-07T01:10:31
labels: [cleanup]
assignee: 
project: enchiridion
blocks: []
blocked_by: []
---

# Remove Legacy PromptType

## Description
PromptType enum in AI/Prompts.lean is marked as legacy with comment 'use AIWritingAction instead' but is still present and used by buildPrompt. Remove PromptType enum and buildPrompt function, ensure all callers use buildWritingActionPrompt.

