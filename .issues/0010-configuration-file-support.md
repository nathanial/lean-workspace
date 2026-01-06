---
id: 10
title: Configuration file support
status: open
priority: medium
created: 2026-01-06T14:47:48
updated: 2026-01-06T14:47:48
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Configuration file support

## Description
Allow CLI arguments to be read from configuration files (TOML, JSON). Many CLI tools support config files (e.g., .prettierrc, cargo.toml). New files: Config/Loader.lean, Config/Toml.lean. Affects: Core/Types.lean (add config path), Parse/Parser.lean (merge config values)

