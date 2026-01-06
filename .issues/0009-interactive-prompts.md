---
id: 9
title: Interactive prompts
status: open
priority: medium
created: 2026-01-06T14:47:47
updated: 2026-01-06T14:50:38
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: [3]
---

# Interactive prompts

## Description
Add support for interactive prompts when required values are missing: confirmation, text input, selection, password. Modern CLI tools like npm, gh, pnpm provide interactive fallbacks. New files: Prompt/Text.lean, Prompt/Confirm.lean, Prompt/Select.lean, Prompt/Password.lean. Depends on REPL support for readline infrastructure.

