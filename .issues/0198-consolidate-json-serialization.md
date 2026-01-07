---
id: 198
title: Consolidate JSON Serialization
status: open
priority: medium
created: 2026-01-07T01:10:02
updated: 2026-01-07T01:10:02
labels: [improvement]
assignee: 
project: enchiridion
blocks: []
blocked_by: []
---

# Consolidate JSON Serialization

## Description
Each model type has manual ToJson/FromJson instances with repetitive boilerplate. Consider using deriving for JSON instances where possible, or create helper macros to reduce boilerplate.

