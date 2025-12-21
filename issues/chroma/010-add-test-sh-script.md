# Add test.sh Script

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
No `test.sh` script like other projects have; testing requires manual command.

Action required:
- Create `test.sh` that runs `./build.sh chroma_tests && .lake/build/bin/chroma_tests`
- Mirror pattern from afferent and other sibling projects

## Rationale
Consistent testing workflow across projects.

## Affected Files
Project root (missing file)
