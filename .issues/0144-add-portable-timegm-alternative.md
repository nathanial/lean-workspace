---
id: 144
title: Add portable timegm alternative
status: open
priority: low
created: 2026-01-07T00:02:31
updated: 2026-01-07T00:02:31
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Add portable timegm alternative

## Description
timegm() is a BSD/GNU extension, not available on all platforms. Add portable fallback using TZ='' + mktime workaround. Location: ffi/chronos_ffi.c:165

