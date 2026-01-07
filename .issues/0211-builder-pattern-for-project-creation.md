---
id: 211
title: Builder Pattern for Project Creation
status: open
priority: medium
created: 2026-01-07T01:10:47
updated: 2026-01-07T01:10:47
labels: [api]
assignee: 
project: enchiridion
blocks: []
blocked_by: []
---

# Builder Pattern for Project Creation

## Description
Creating a project with all optional fields requires many struct updates. A builder pattern would improve ergonomics: Novel.builder "Title" |>.author "Name" |>.genre "Fantasy" |>.build

