---
id: 206
title: Inefficient File Existence Check
status: open
priority: medium
created: 2026-01-07T01:10:32
updated: 2026-01-07T01:10:32
labels: [cleanup]
assignee: 
project: enchiridion
blocks: []
blocked_by: []
---

# Inefficient File Existence Check

## Description
Storage.fileExists reads the entire file to check if it exists, which is inefficient. Use IO.FS.metadata or similar to check file existence without reading content.

