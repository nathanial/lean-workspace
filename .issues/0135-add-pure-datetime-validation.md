---
id: 135
title: Add pure DateTime validation
status: open
priority: medium
created: 2026-01-07T00:02:14
updated: 2026-01-07T00:02:14
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Add pure DateTime validation

## Description
DateTime accepts any field values without validation (month=13, day=32 are possible). Add DateTime.isValid, DateTime.validate, DateTime.mk? smart constructor to catch errors early.

