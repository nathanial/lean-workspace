---
id: 32
title: Conversation History Persistence
status: closed
priority: high
created: 2026-01-06T15:15:10
updated: 2026-01-06T23:00:33
labels: []
assignee: 
project: ask
blocks: []
blocked_by: []
---

# Conversation History Persistence

## Description
Save and load conversation history to/from files. Add /save and /load commands, auto-save to ~/.ask/history/, use JSON format.

## Progress
- [2026-01-06T22:59:40] Implemented History.lean module, updated Repl.lean with /save, /load, /list commands and auto-save on exit, updated Main.lean with --load and --no-autosave flags. Build successful.
- [2026-01-06T23:00:33] Closed: Implemented conversation history persistence:\n- Created Ask/History.lean with ConversationMetadata and SavedConversation types, JSON serialization, and file I/O\n- Added /save [name], /load [name], /list REPL commands\n- Added auto-save on exit (disable with --no-autosave)\n- Added --load/-L flag to load conversation at startup\n- Conversations saved as JSON in ~/.ask/history/
