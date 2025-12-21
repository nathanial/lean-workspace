# Builder Pattern for Project Creation

**Priority:** Medium
**Section:** API Enhancements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Currently creating a project with all optional fields requires many struct updates. A builder pattern would improve ergonomics.

## Rationale
Example:
```lean
-- Current
let novel := { novel with genre := "Fantasy", synopsis := "..." }

-- Proposed
let novel := Novel.builder "Title" |>.author "Name" |>.genre "Fantasy" |>.build
```

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Model/Novel.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Model/Project.lean`
