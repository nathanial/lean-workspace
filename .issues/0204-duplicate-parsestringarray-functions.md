---
id: 204
title: Duplicate parseStringArray Functions
status: open
priority: medium
created: 2026-01-07T01:10:31
updated: 2026-01-07T01:10:31
labels: [cleanup]
assignee: 
project: enchiridion
blocks: []
blocked_by: []
---

# Duplicate parseStringArray Functions

## Description
Helper function parseStringArray is defined identically in both Character.lean and WorldNote.lean. Move the function to Core/Json.lean and export it for shared use.

