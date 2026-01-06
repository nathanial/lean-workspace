---
id: 27
title: Derived commands from types
status: open
priority: low
created: 2026-01-06T14:48:37
updated: 2026-01-06T14:48:37
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Derived commands from types

## Description
Use Lean metaprogramming to derive CLI commands from structure types. Proposed: structure Options where verbose : Bool; output : FilePath; deriving Command. New file: Derive.lean

