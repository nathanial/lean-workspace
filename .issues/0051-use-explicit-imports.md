---
id: 51
title: Use Explicit Imports
status: open
priority: low
created: 2026-01-06T15:16:13
updated: 2026-01-06T15:16:13
labels: []
assignee: 
project: ask
blocks: []
blocked_by: []
---

# Use Explicit Imports

## Description
Main.lean uses open Parlance/Oracle (lines 11-12) which imports many symbols. Consider selective imports or qualified names to prevent future conflicts.

